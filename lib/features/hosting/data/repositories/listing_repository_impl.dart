import 'package:dartz/dartz.dart';

import '../../../../core/errors/exception.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/domain/entities/listing_entity.dart';
import '../../domain/repositories/listing_repository.dart';
import '../datasources/listing_remote_data_source.dart';
import '../../../../core/models/listing_model.dart';

class ListingRepositoryImpl implements ListingRepository {
  final ListingRemoteDataSource remoteDataSource;

  ListingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ListingEntity>> createListing({
    required ListingEntity listing,
  }) async {
    try {
      final model = _toModel(listing);

      final result = await remoteDataSource.createListing(listing: model);

      return Right(result);
    } on ListingAccessException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ListingNotFoundException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ListingEntity>>> getMyListings({
    required String ownerId,
  }) async {
    try {
      final result = await remoteDataSource.getMyListings(ownerId: ownerId);

      return Right(result.map<ListingEntity>((model) => model).toList());
    } on ListingAccessException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ListingNotFoundException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ListingEntity>> updateListing({
    required ListingEntity listing,
  }) async {
    try {
      final model = _toModel(listing);

      final result = await remoteDataSource.updateListing(listing: model);

      return Right(result);
    } on ListingAccessException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ListingNotFoundException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteListing({
    required String listingId,
    required String ownerId,
  }) async {
    try {
      await remoteDataSource.deleteListing(
        listingId: listingId,
        ownerId: ownerId,
      );

      return const Right(null);
    } on ListingAccessException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ListingNotFoundException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  ListingModel _toModel(ListingEntity entity) {
    return ListingModel(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      priceMonthly: entity.priceMonthly,
      area: entity.area,
      roomType: entity.roomType,
      category: entity.category,
      furnished: entity.furnished,
      peopleCount: entity.peopleCount,
      spacesRemaining: entity.spacesRemaining,
      rules: entity.rules,
      roommates: entity.roommates,
      host: entity.host,
      photoCount: entity.photoCount,
      photoPaths: entity.photoPaths,
      photoUrls: entity.photoUrls,
      isPublished: entity.isPublished,
      ownerId: entity.ownerId,
    );
  }

  @override
Future<Either<Failure, ListingEntity>> getListingById({
  required String listingId,
}) async {
  try {
    final listing = await remoteDataSource.getListingById(
      listingId: listingId,
    );

    return Right(listing);
  } catch (e) {
    return Left(ServerFailure(message: e.toString()));
  }
}
}
