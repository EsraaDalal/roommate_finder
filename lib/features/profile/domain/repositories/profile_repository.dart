
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/domain/entities/user_entity.dart';

abstract class ProfileRepository {
  /// Retrieves a user's profile by their Firebase UID.
  Future<Either<Failure, UserEntity>> getProfile({
    required String uid,
  });

  /// Updates editable profile fields for the specified user.
  Future<Either<Failure, UserEntity>> updateProfile({
    required String uid,
    required String fullName,
    required String city,
    required String bio,
  });
}
