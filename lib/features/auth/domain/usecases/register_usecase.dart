import '../../../../core/domain/entities/user_entity.dart';
import '../repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase({required this.repository});

  Future<Either<Failure, UserEntity>> call({
    required String fullName,
    required String email,
    required String password,
    required String city,
    required String bio,
  }) async {
    return await repository.register(
      fullName: fullName,
      email: email,
      password: password,
      city: city,
      bio: bio,
    );
  }
}