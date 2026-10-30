import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/application_entity.dart';
import '../repositories/application_repository.dart';

class GetSubmittedApplicationsUseCase {
  const GetSubmittedApplicationsUseCase({required this.repository});

  final ApplicationRepository repository;

  Future<Either<Failure, List<ApplicationEntity>>> call({
    required String applicantId,
  }) {
    return repository.getSubmittedByApplicant(applicantId: applicantId);
  }

  Stream<Either<Failure, List<ApplicationEntity>>> watch({required String applicantId}) =>
      repository.watchSubmittedByApplicant(applicantId: applicantId);
}
