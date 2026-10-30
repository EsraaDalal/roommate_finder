


import '../../../../../core/domain/entities/user_entity.dart';

abstract class AuthSessionState {
  const AuthSessionState();
}

class AuthSessionInitial extends AuthSessionState {

}

class AuthSessionLoading extends AuthSessionState {

}

class AuthSessionAuthenticated extends AuthSessionState {
  final UserEntity user;

  const AuthSessionAuthenticated(this.user);
}

class AuthSessionUnauthenticated extends AuthSessionState {

}

class AuthSessionError extends AuthSessionState {
  final String message;

  const AuthSessionError(this.message);
}
