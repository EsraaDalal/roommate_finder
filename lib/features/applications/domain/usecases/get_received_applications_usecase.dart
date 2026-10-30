import 'dart:async';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/application_entity.dart';
import '../repositories/application_repository.dart';

class GetReceivedApplicationsUseCase {
  const GetReceivedApplicationsUseCase({required this.repository});

  final ApplicationRepository repository;

  Future<Either<Failure, List<ApplicationEntity>>> call({
    required String ownerId,
  }) {
    return repository.getReceivedByOwner(ownerId: ownerId);
  }

  Stream<Either<Failure, List<ApplicationEntity>>> watch({required String ownerId}) =>
      repository.watchReceivedByOwner(ownerId: ownerId);
}
