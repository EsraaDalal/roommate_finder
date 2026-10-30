
import '../../../../core/domain/entities/user_entity.dart';

abstract class ProfileState {
  const ProfileState();
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final UserEntity user;

  const ProfileLoaded(this.user);
}

class ProfileUpdating extends ProfileState {
  final UserEntity user;

  const ProfileUpdating(this.user);
}

class ProfileUpdateSuccess extends ProfileState {
  final UserEntity user;

  const ProfileUpdateSuccess(this.user);
}

class ProfileFailureState extends ProfileState {
  final String message;

  const ProfileFailureState(this.message);
}
