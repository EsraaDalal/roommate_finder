
import '../../../../../core/domain/entities/user_entity.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
 
}

class AuthLoading extends AuthState {

}

class AuthSuccess extends AuthState {
  final UserEntity user;

  const AuthSuccess(this.user);
}

class AuthLogoutSuccess extends AuthState {

}

class AuthFailureState extends AuthState {
  final String message;

  const AuthFailureState(this.message);
}
