
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/favorite_listing_entity.dart';

abstract class FavoriteRepository {

    Future<Either<Failure, bool>> toggleFavorite({
    required FavoriteListingEntity listing,
  });



  Future<Either<Failure, List<FavoriteListingEntity>>>
      getFavoriteListings({
    required String? userId,
  });
}
