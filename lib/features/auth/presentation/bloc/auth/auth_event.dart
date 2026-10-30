


abstract class AuthEvent {
  const AuthEvent();
}

class RegisterRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String password;
  final String city;
  final String bio;

  const RegisterRequested({
    required this.fullName,
    required this.email,
    required this.password,
    required this.city,
    required this.bio,
  });
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
