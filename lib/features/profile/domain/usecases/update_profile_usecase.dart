
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/domain/entities/user_entity.dart';
import '../repositories/profile_repository.dart';

class UpdateProfileUseCase {
  final ProfileRepository repository;

  UpdateProfileUseCase({
    required this.repository,
  });

  Future<Either<Failure, UserEntity>> call({
    required String uid,
    required String fullName,
    required String city,
    required String bio,
  }) {
    return repository.updateProfile(
      uid: uid,
      fullName: fullName,
      city: city,
      bio: bio,
    );
  }
}
