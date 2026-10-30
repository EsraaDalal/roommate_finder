import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/domain/entities/user_entity.dart';

abstract class UserRemoteDataSource {
  Future<List<UserEntity>> getUsers();
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  UserRemoteDataSourceImpl(this.firestore);

  final FirebaseFirestore firestore;

  @override
  Future<List<UserEntity>> getUsers() async {
    final snapshot = await firestore.collection('users').get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return UserEntity(
        uid: doc.id,
        fullName: data['fullName'] as String? ?? '',
        email: data['email'] as String? ?? '',
        city: data['city'] as String? ?? '',
        bio: data['bio'] as String? ?? '',
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      );
    }).where((user) => user.fullName.trim().isNotEmpty).toList();
  }
}