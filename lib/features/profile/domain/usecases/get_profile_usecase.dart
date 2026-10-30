
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/domain/entities/user_entity.dart';
import '../repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase({
    required this.repository,
  });

  Future<Either<Failure, UserEntity>> call({
    required String uid,
  }) {
    return repository.getProfile(uid: uid);
  }
}
