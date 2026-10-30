// lib/features/applications/data/repositories/application_repository_impl.dart
import 'package:dartz/dartz.dart';
import '../../../../core/errors/application_exception.dart';
import '../../../../core/errors/application_failure.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/application_entity.dart';
import '../../domain/repositories/application_repository.dart';
import '../datasources/application_remote_data_source.dart';


class ApplicationRepositoryImpl implements ApplicationRepository {
  final ApplicationRemoteDataSource remoteDataSource;

  ApplicationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ApplicationEntity>> submitApplication({
    required String listingId,
    required String applicantId,
    required DateTime requestedMoveIn,
    required String message,
  }) async {
    try {
      final model = await remoteDataSource.submitApplication(
        listingId: listingId,
        applicantId: applicantId,
        requestedMoveIn: requestedMoveIn,
        message: message,
      );
      return Right(model);
    } on ApplicationAccessException catch (e) {
      return Left(ApplicationFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ApplicationEntity>>> getSubmittedByApplicant({
    required String applicantId,
  }) async {
    try {
      final list = await remoteDataSource.getSubmittedByApplicant(
        applicantId: applicantId,
      );
      return Right(list);
    } on ApplicationAccessException catch (e) {
      return Left(ApplicationFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ApplicationEntity>>> getReceivedByOwner({
    required String ownerId,
  }) async {
    try {
      final list = await remoteDataSource.getReceivedByOwner(ownerId: ownerId);
      return Right(list);
    } on ApplicationAccessException catch (e) {
      return Left(ApplicationFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<Either<Failure, List<ApplicationEntity>>> watchSubmittedByApplicant({required String applicantId}) {
    try {
      return remoteDataSource
          .watchSubmittedByApplicant(applicantId: applicantId)
          .map<Either<Failure, List<ApplicationEntity>>>(
            (items) => Right<Failure, List<ApplicationEntity>>(items),
          );
    } catch (error) {
      return Stream.value(Left<Failure, List<ApplicationEntity>>(
        error is ApplicationAccessException
            ? ApplicationFailure(message: error.message)
            : ServerFailure(),
      ));
    }
  }

  @override
  Stream<Either<Failure, List<ApplicationEntity>>> watchReceivedByOwner({required String ownerId}) {
    try {
      return remoteDataSource
          .watchReceivedByOwner(ownerId: ownerId)
          .map<Either<Failure, List<ApplicationEntity>>>(
            (items) => Right<Failure, List<ApplicationEntity>>(items),
          );
    } catch (error) {
      return Stream.value(Left<Failure, List<ApplicationEntity>>(
        error is ApplicationAccessException
            ? ApplicationFailure(message: error.message)
            : ServerFailure(),
      ));
    }
  }

  @override
  Future<Either<Failure, void>> cancelApplication({
    required String applicationId,
    required String applicantId,
  }) async {
    try {
      await remoteDataSource.cancelApplication(
        applicationId: applicationId,
        applicantId: applicantId,
      );
      return const Right(null);
    } on ApplicationAccessException catch (e) {
      return Left(ApplicationFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> setApplicationStatus({
    required String applicationId,
    required String ownerId,
    required ApplicationStatus newStatus,
  }) async {
    try {
      await remoteDataSource.setApplicationStatus(
        applicationId: applicationId,
        ownerId: ownerId,
        newStatus: newStatus,
      );
      return const Right(null);
    } on ApplicationAccessException catch (e) {
      return Left(ApplicationFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
