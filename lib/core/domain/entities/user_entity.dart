
class UserEntity {
  final String uid;
  final String fullName;
  final String email;
  final String city;
  final String bio;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserEntity({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.city,
    required this.bio,

    this.createdAt,
    this.updatedAt,
  });
}
