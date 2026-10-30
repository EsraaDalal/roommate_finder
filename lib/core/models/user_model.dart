import 'package:cloud_firestore/cloud_firestore.dart';

import '../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.fullName,
    required super.email,
    required super.city,
    required super.bio,

    super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromMap({
    required String uid,
    required Map<String, dynamic> map,
  }) {
    return UserModel(
      uid: uid,
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      city: map['city'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
   
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'email': email,
      'city': city,
      'bio': bio,
  
      'createdAt': createdAt == null
          ? null
          : Timestamp.fromDate(createdAt!),
      'updatedAt': updatedAt == null
          ? null
          : Timestamp.fromDate(updatedAt!),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}