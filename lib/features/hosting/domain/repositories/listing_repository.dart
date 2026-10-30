
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/domain/entities/listing_entity.dart';

abstract class ListingRepository {
  Future<Either<Failure, ListingEntity>> createListing({
    required ListingEntity listing,
  });

  Future<Either<Failure, List<ListingEntity>>> getMyListings({
    required String ownerId,
  });

  Future<Either<Failure, ListingEntity>> updateListing({
    required ListingEntity listing,
  });

  Future<Either<Failure, void>> deleteListing({
    required String listingId,
    required String ownerId,
  });

  Future<Either<Failure, ListingEntity>> getListingById({
  required String listingId,
});
}
