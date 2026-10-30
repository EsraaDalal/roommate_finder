
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/models/user_model.dart';


class ProfileAccessException implements Exception {
  final String message;

  const ProfileAccessException(this.message);

  @override
  String toString() => message;
}

class ProfileNotFoundException implements Exception {
  final String message;

  const ProfileNotFoundException(this.message);

  @override
  String toString() => message;
}

abstract class ProfileRemoteDataSource {
  Future<UserModel> getProfile({required String uid});

  Future<UserModel> updateProfile({
    required String uid,
    required String fullName,
    required String city,
    required String bio,
  });
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  ProfileRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  CollectionReference<Map<String, dynamic>> get _users =>
      firestore.collection('users');

  @override
  Future<UserModel> getProfile({required String uid}) async {
    final normalizedUid = uid.trim();

    if (normalizedUid.isEmpty) {
      throw const ProfileNotFoundException('User ID is required.');
    }

    final snapshot = await _users.doc(normalizedUid).get();
    final data = snapshot.data();

    if (!snapshot.exists || data == null) {
      throw const ProfileNotFoundException('User profile was not found.');
    }

    return UserModel.fromMap(uid: snapshot.id, map: data);
  }

  @override
  Future<UserModel> updateProfile({
    required String uid,
    required String fullName,
    required String city,
    required String bio,
  }) async {
    final user = firebaseAuth.currentUser;

    if (user == null) {
      throw const ProfileAccessException('You must be signed in.');
    }

    if (user.uid != uid) {
      throw const ProfileAccessException(
        'You can only update your own profile.',
      );
    }

    final document = _users.doc(user.uid);
    final snapshot = await document.get();

    if (!snapshot.exists || snapshot.data() == null) {
      throw const ProfileNotFoundException('User profile was not found.');
    }

    await document.update({
      'fullName': fullName.trim(),
      'city': city.trim(),
      'bio': bio.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final updatedSnapshot = await document.get();
    final updatedData = updatedSnapshot.data();

    if (updatedData == null) {
      throw const ProfileNotFoundException(
        'Updated user profile could not be retrieved.',
      );
    }

    return UserModel.fromMap(
      uid: updatedSnapshot.id,
      map: updatedData,
    );
  }
}
