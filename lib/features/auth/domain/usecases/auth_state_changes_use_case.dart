
import '../../../../core/domain/entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class AuthStateChangesUseCase {
  final AuthRepository repository;

  AuthStateChangesUseCase({
    required this.repository,
  });

  Stream<UserEntity?> call() {
    return repository.authStateChanges;
  }
}
