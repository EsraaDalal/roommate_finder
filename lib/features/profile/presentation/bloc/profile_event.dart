
abstract class ProfileEvent {
  const ProfileEvent();
}

class ProfileLoadRequested extends ProfileEvent {
  final String uid;

  const ProfileLoadRequested({required this.uid});
}

class ProfileUpdateRequested extends ProfileEvent {
  final String uid;
  final String fullName;
  final String city;
  final String bio;

  const ProfileUpdateRequested({
    required this.uid,
    required this.fullName,
    required this.city,
    required this.bio,
  });
}
