
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/domain/entities/listing_entity.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  HomeRepositoryImpl({
    required this.remoteDataSource,
  });

  final HomeRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<ListingEntity>>> getListings() async {
  try {
  final result = await remoteDataSource.getHomeListings();

  return Right(
    result.map<ListingEntity>((model) => model).toList(),
  );
} on FirebaseException catch (e) {
  return Left(
    ServerFailure(
      message: e.message ?? 'Failed to load listings.',
    ),
  );
} catch (_) {
  return Left(
    ServerFailure(
      message: 'An unexpected error occurred while loading listings.',
    ),
  );
}
  }
}

