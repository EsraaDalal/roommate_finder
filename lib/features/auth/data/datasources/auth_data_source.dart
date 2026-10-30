
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/models/user_model.dart';


abstract class AuthDataSource {
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    required String city,
    required String bio,
  });

  Future<UserModel> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<UserModel?> getCurrentUser();

  Stream<UserModel?> get authStateChanges;
}


class AuthDataSourceImpl implements AuthDataSource {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  AuthDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  @override
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    required String city,
    required String bio,
  }) async {
    final credential =
        await firebaseAuth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('User creation failed.');
    }

    final now = FieldValue.serverTimestamp();

    final userData = <String, dynamic>{
      'fullName': fullName.trim(),
      'email': user.email ?? email.trim(),
      'city': city.trim(),
      'bio': bio.trim(),
      
      'createdAt': now,
      'updatedAt': now,
    };

    try {
      await firestore.collection('users').doc(user.uid).set(userData);

      final snapshot =
          await firestore.collection('users').doc(user.uid).get();

      final data = snapshot.data();

      if (!snapshot.exists || data == null) {
        throw Exception('User profile could not be retrieved.');
      }

      return UserModel.fromMap(
        uid: user.uid,
        map: data,
      );
    } catch (_) {
      // Avoid leaving an authenticated account without its profile.
      try {
        await user.delete();
      } on FirebaseAuthException {
        // Account deletion may fail, for example if reauthentication
        // is required. Preserve the original registration error.
      }

      rethrow;
    }
  }

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final credential =
        await firebaseAuth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception('Login failed.');
    }

    final snapshot =
        await firestore.collection('users').doc(user.uid).get();

    final data = snapshot.data();

    if (!snapshot.exists || data == null) {
      throw Exception('User profile was not found.');
    }

    return UserModel.fromMap(
      uid: user.uid,
      map: data,
    );
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  
  @override
  Future<UserModel?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;

    if (user == null) {
      return null;
    }

    return _loadUserProfile(user.uid);
  }
//
  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) {
        return null;
      }

      return _loadUserProfile(user.uid);
    });
  }

  Future<UserModel> _loadUserProfile(String uid) async {
    final snapshot =
        await firestore.collection('users').doc(uid).get();

    final data = snapshot.data();

    if (!snapshot.exists || data == null) {
      throw StateError(
        'User profile was not found for the current account.',
      );
    }

    return UserModel.fromMap(
      uid: uid,
      map: data,
    );
  }

}
