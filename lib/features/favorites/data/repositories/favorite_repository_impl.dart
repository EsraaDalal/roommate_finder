
import 'package:dartz/dartz.dart';


import '../../../../core/errors/failure.dart';
import '../../domain/entities/favorite_listing_entity.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../datasources/favorite_local_datasource.dart';
import '../models/favorite_model.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final FavoriteLocalDataSource localDataSource;

  FavoriteRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, bool>> toggleFavorite({
    required FavoriteListingEntity listing,
  }) async {
    try {
      final favorite = FavoriteModel.fromEntity(
        entity: listing,
      );

      final isFavorite = await localDataSource.toggleFavorite(
        favorite: favorite,
      );

      return Right(isFavorite);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to update favorite listing: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<FavoriteListingEntity>>>
      getFavoriteListings({
    required String? userId,
  }) async {
    try {
      final models = localDataSource.getFavoriteListings(
        userId: userId,
      );

      final entities = models
          .map<FavoriteListingEntity>((model) => model.toEntity())
          .toList();

      return Right(entities);
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to load favorite listings: $e',
        ),
      );
    }
  }
}
