

import '../../../../../core/domain/entities/user_entity.dart';

abstract class AuthSessionEvent {
  const AuthSessionEvent();
}

/// Starts listening to Firebase authentication changes.
class AuthSessionStarted extends AuthSessionEvent {
  const AuthSessionStarted();
}

/// Internal event emitted when the session stream changes.
class AuthSessionChanged extends AuthSessionEvent {
  final UserEntity? user;

  const AuthSessionChanged(this.user);
}

/// Internal event emitted when listening to the session fails.
class AuthSessionFailed extends AuthSessionEvent {
  final String message;

  const AuthSessionFailed(this.message);
}
