import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/config/supabase_config.dart';
import '../models/notification_model.dart';

abstract class NotificationRemoteDataSource {
  Future<void> sendNotification(NotificationModel notification);

  Stream<List<NotificationModel>> getNotifications(String userId);

  Future<void> markAsRead(String notificationId);

  Future<void> markAllAsRead(String userId);

  Future<void> saveFcmToken(String userId, String token);

  /// Invokes the Supabase Edge Function `send-notification` with the current user's Firebase ID token.
  Future<void> triggerPushNotification({Map<String, dynamic>? payload});
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore firestore;
  final Dio? dio;
  final FirebaseAuth? firebaseAuth;

  NotificationRemoteDataSourceImpl({
    required this.firestore,
    this.dio,
    this.firebaseAuth,
  });

  CollectionReference<Map<String, dynamic>> get _notificationsCollection =>
      firestore.collection('notifications');

  
@override
Future<void> triggerPushNotification({
  Map<String, dynamic>? payload,
}) async {
  final client = dio;
  final user = firebaseAuth?.currentUser;

  if (!SupabaseConfig.isConfigured) {
    log('[Push Debug] Supabase is not configured.');
    return;
  }

  if (client == null) {
    log('[Push Debug] Dio is null.');
    return;
  }

  if (user == null) {
    log('[Push Debug] No Firebase user is signed in.');
    return;
  }

  try {
    final idToken = await user.getIdToken();

    if (idToken == null || idToken.isEmpty) {
      log('[Push Debug] Firebase ID token is empty.');
      return;
    }

    final functionName = SupabaseConfig.sendNotificationFunction;
    final url =
        '${SupabaseConfig.url}/functions/v1/$functionName';

    log('[Push Debug] Calling Edge Function: $functionName');

    final response = await client.post<dynamic>(
      url,
      data: payload ?? <String, dynamic>{},
      options: Options(
        headers: <String, dynamic>{
          'apikey': SupabaseConfig.publishableKey,
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        validateStatus: (status) =>
            status != null && status >= 200 && status < 600,
      ),
    );

    log('[Push Debug] HTTP status: ${response.statusCode}');
    log('[Push Debug] Response: ${response.data}');
  } on DioException catch (e) {
    log('[Push Debug] Request failed: ${e.message}');
    log('[Push Debug] HTTP status: ${e.response?.statusCode}');
    log('[Push Debug] Response: ${e.response?.data}');
  } catch (e) {
    log('[Push Debug] Unexpected error: $e');
  }
}


  @override
  Future<void> sendNotification(NotificationModel notification) async {
    final docRef = notification.id.isNotEmpty
        ? _notificationsCollection.doc(notification.id)
        : _notificationsCollection.doc();

    await docRef.set(notification.toMap());
  }

  @override
  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _notificationsCollection
        .where('recipientId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final list = snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
          .toList();

      // Sort descending by createdAt in Dart to avoid needing composite indexes
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _notificationsCollection.doc(notificationId).update({
      'isRead': true,
    });
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _notificationsCollection
        .where('recipientId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  @override
  Future<void> saveFcmToken(String userId, String token) async {
    await firestore.collection('users').doc(userId).set({
      'fcmToken': token,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
