import 'dart:async';
// Repository contract for Applications feature.

import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/application_entity.dart';

abstract class ApplicationRepository {
  /// Submit a new application.
  Future<Either<Failure, ApplicationEntity>> submitApplication({
    required String listingId,
    required String applicantId,
    required DateTime requestedMoveIn,
    required String message,
  });

  /// Retrieve applications submitted by the given applicant.
  Future<Either<Failure, List<ApplicationEntity>>> getSubmittedByApplicant({
    required String applicantId,
  });

  /// Retrieve applications received for listings owned by the given user.
  Future<Either<Failure, List<ApplicationEntity>>> getReceivedByOwner({
    required String ownerId,
  });

  Stream<Either<Failure, List<ApplicationEntity>>> watchSubmittedByApplicant({required String applicantId});

  Stream<Either<Failure, List<ApplicationEntity>>> watchReceivedByOwner({required String ownerId});

  /// Cancel a pending application.
  Future<Either<Failure, void>> cancelApplication({
    required String applicationId,
    required String applicantId,
  });

  /// Owner updates the status of an application (accept/reject).
  Future<Either<Failure, void>> setApplicationStatus({
    required String applicationId,
    required String ownerId,
    required ApplicationStatus newStatus,
  });
}
