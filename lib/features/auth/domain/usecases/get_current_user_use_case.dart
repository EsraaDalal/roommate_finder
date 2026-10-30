
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/domain/entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;

  GetCurrentUserUseCase({
    required this.repository,
  });

  Future<Either<Failure, UserEntity?>> call() {
    return repository.getCurrentUser();
  }
}
