
abstract class Failure {
  final String message;

  const Failure({required this.message});
}

class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'An unexpected server error occurred.',
  });
}

class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Authentication failed.',
  });
}
