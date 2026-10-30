import 'dart:async';
// lib/features/applications/data/datasources/application_remote_data_source.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/application_exception.dart';
import '../../../notifications/data/datasources/notification_remote_data_source.dart';

import '../models/application_model.dart';
import '../../domain/entities/application_entity.dart';

abstract class ApplicationRemoteDataSource {
  Future<ApplicationModel> submitApplication({
    required String listingId,
    required String applicantId,
    required DateTime requestedMoveIn,
    required String message,
  });

  Future<List<ApplicationModel>> getSubmittedByApplicant({
    required String applicantId,
  });

  Stream<List<ApplicationModel>> watchSubmittedByApplicant({required String applicantId});

  Future<List<ApplicationModel>> getReceivedByOwner({
    required String ownerId,
  });

  Stream<List<ApplicationModel>> watchReceivedByOwner({required String ownerId});

  Future<void> cancelApplication({
    required String applicationId,
    required String applicantId,
  });

  Future<void> setApplicationStatus({
    required String applicationId,
    required String ownerId,
    required ApplicationStatus newStatus,
  });
}

class ApplicationRemoteDataSourceImpl implements ApplicationRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final NotificationRemoteDataSource? notificationRemoteDataSource;

  ApplicationRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
    this.notificationRemoteDataSource,
  });

  CollectionReference<Map<String, dynamic>> get _applicationsCollection =>
      firestore.collection('applications');

  User _requireCurrentUser() {
    final user = firebaseAuth.currentUser;
    if (user == null) {
      throw ApplicationAccessException('User must be signed in.');
    }
    return user;
  }

  @override
  Future<ApplicationModel> submitApplication({
    required String listingId,
    required String applicantId,
    required DateTime requestedMoveIn,
    required String message,
  }) async {

    final user = _requireCurrentUser();
    if (applicantId != user.uid) {
      throw ApplicationAccessException('Applicant ID does not match signed‑in user.');
    }
    // Verify listing ownership via listing document (read once).
    final listingSnap = await firestore.collection('listings').doc(listingId).get();
    if (!listingSnap.exists) {
      throw ApplicationAccessException('Listing does not exist.');
    }
    final listingOwner = listingSnap.data()?['ownerId'] as String? ?? '';
    if (listingOwner.isEmpty) {
      throw ApplicationAccessException('Listing owner missing.');
    }
    // Duplicate check – ensure no pending/accepted application exists for this applicant & listing.
    final duplicateQuery = await _applicationsCollection
        .where('listingId', isEqualTo: listingId)
        .where('applicantId', isEqualTo: applicantId)
        .where('status', whereIn: ['pending', 'accepted'])
        .limit(1)
        .get();
    if (duplicateQuery.docs.isNotEmpty) {
      throw ApplicationAccessException('Duplicate active application.');
    }

    final doc = _applicationsCollection.doc();
    final model = ApplicationModel(
      id: doc.id,
      listingId: listingId,
       ownerId: listingOwner,
      applicantId: applicantId,
      requestedMoveIn: requestedMoveIn,
      message: message,
      status: ApplicationStatus.pending,
      submittedAt: DateTime.now(),
    );
    await doc.set(model.toMap());

    // Create notification for listing owner
    try {
      final applicantSnap =
          await firestore.collection('users').doc(applicantId).get();
      final applicantName =
          applicantSnap.data()?['fullName'] as String? ?? 'An applicant';

      final notifDoc = firestore.collection('notifications').doc();
      await notifDoc.set({
        'recipientId': listingOwner,
        'senderId': applicantId,
        'title': 'New Application',
        'body': '$applicantName applied for your listing.',
        'type': 'newApplication',
        'listingId': listingId,
        'applicationId': doc.id,
        'createdAt': Timestamp.now(),
        'isRead': false,
      });
    await notificationRemoteDataSource?.triggerPushNotification(
    payload: {
    'type': 'newApplication',
    'applicationId': doc.id,
  },
);
    } catch (_) {}

    return model;
  }

  @override
  Future<List<ApplicationModel>> getSubmittedByApplicant({
    required String applicantId,
  }) async {
    final user = _requireCurrentUser();
    if (applicantId != user.uid) {
      throw ApplicationAccessException('Can only query own applications.');
    }
    final snapshot = await _applicationsCollection
        .where('applicantId', isEqualTo: applicantId)
        .orderBy('submittedAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => ApplicationModel.fromMap(id: doc.id, map: doc.data()))
        .toList();
  }


  @override
  Stream<List<ApplicationModel>> watchSubmittedByApplicant({required String applicantId}) {
    final user = _requireCurrentUser();
    if (applicantId != user.uid) {
      throw ApplicationAccessException('Can only watch own applications.');
    }
    return _applicationsCollection
        .where('applicantId', isEqualTo: applicantId)
        .snapshots()
        .map((snapshot) {
      final applications = snapshot.docs
          .map((doc) => ApplicationModel.fromMap(id: doc.id, map: doc.data()))
          .toList();
      applications.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      return applications;
    });
  }

  @override
  Stream<List<ApplicationModel>> watchReceivedByOwner({required String ownerId}) {
    final user = _requireCurrentUser();
    if (ownerId != user.uid) {
      throw ApplicationAccessException('Can only watch own received applications.');
    }
    // submitApplication persists ownerId, so this query updates in real time.
    return _applicationsCollection
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      final applications = snapshot.docs
          .map((doc) => ApplicationModel.fromMap(id: doc.id, map: doc.data()))
          .toList();
      applications.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));
      return applications;
    });
  }

@override
Future<List<ApplicationModel>> getReceivedByOwner({
  required String ownerId,
}) async {
  final user = _requireCurrentUser();

  if (ownerId != user.uid) {
    throw ApplicationAccessException(
      'Can only query own received applications.',
    );
  }

  // Fetch listings owned by the current user.
  final listingsSnap = await firestore
      .collection('listings')
      .where('ownerId', isEqualTo: ownerId)
      .get();

  final listingIds = listingsSnap.docs.map((doc) => doc.id).toList();

  if (listingIds.isEmpty) return [];

  // Fetch only applications belonging to this owner.
  final snapshot = await _applicationsCollection
      .where('listingId', whereIn: listingIds)
      .where('ownerId', isEqualTo: user.uid)
      .orderBy('submittedAt', descending: true)
      .get();

  return snapshot.docs
      .map(
        (doc) => ApplicationModel.fromMap(
          id: doc.id,
          map: doc.data(),
        ),
      )
      .toList();
}

  @override
  Future<void> cancelApplication({
    required String applicationId,
    required String applicantId,
  }) async {
    final user = _requireCurrentUser();
    if (applicantId != user.uid) {
      throw ApplicationAccessException('Applicant ID mismatch.');
    }
    final docRef = _applicationsCollection.doc(applicationId);
    final snap = await docRef.get();
    if (!snap.exists) {
      throw ApplicationAccessException('Application not found.');
    }
    final data = snap.data()!;
    if (data['applicantId'] != applicantId) {
      throw ApplicationAccessException('Not the owner of this application.');
    }
    if (data['status'] != ApplicationStatus.pending.name) {
      throw ApplicationAccessException('Only pending applications can be cancelled.');
    }
await docRef.delete();
  }

  @override
  Future<void> setApplicationStatus({
    required String applicationId,
    required String ownerId,
    required ApplicationStatus newStatus,
  }) async {
    final user = _requireCurrentUser();
    if (ownerId != user.uid) {
      throw ApplicationAccessException('Owner ID mismatch.');
    }
    final docRef = _applicationsCollection.doc(applicationId);
    final snap = await docRef.get();
    if (!snap.exists) {
      throw ApplicationAccessException('Application not found.');
    }
    final data = snap.data()!;
    // Verify listing belongs to the owner.
    final listingId = data['listingId'] as String? ?? '';
    final listingSnap = await firestore.collection('listings').doc(listingId).get();
    if (!listingSnap.exists) {
      throw ApplicationAccessException('Related listing not found.');
    }
    final listingOwner = listingSnap.data()?['ownerId'] as String? ?? '';
    if (listingOwner != ownerId) {
      throw ApplicationAccessException('Owner does not own the listing.');
    }
    // Only pending applications are actionable.
    if (data['status'] != ApplicationStatus.pending.name) {
      throw ApplicationAccessException('Only pending applications can be updated.');
    }
    await docRef.update({'status': newStatus.name});

    // Create notification for the applicant
    try {
      final applicantId = data['applicantId'] as String? ?? '';
      if (applicantId.isNotEmpty) {
        final isAccepted = newStatus == ApplicationStatus.accepted;
        final notifDoc = firestore.collection('notifications').doc();
        await notifDoc.set({
          'recipientId': applicantId,
          'senderId': ownerId,
          'title': isAccepted ? 'Application Accepted' : 'Application Rejected',
          'body': isAccepted
              ? 'Congratulations! Your application has been accepted.'
              : 'Your application for the listing was declined.',
          'type': isAccepted ? 'applicationAccepted' : 'applicationRejected',
          'listingId': listingId,
          'applicationId': applicationId,
          'createdAt': Timestamp.now(),
          'isRead': false,
        });
     await notificationRemoteDataSource?.triggerPushNotification(
  payload: {
    'type': isAccepted
        ? 'applicationAccepted'
        : 'applicationRejected',
    'applicationId': applicationId,
  },
);
      }
    } catch (_) {}
  }
}
