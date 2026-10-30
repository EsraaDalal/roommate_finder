
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/domain/entities/listing_entity.dart';
import '../repositories/listing_repository.dart';

class UpdateListingUseCase {
  const UpdateListingUseCase({
    required this.repository,
  });

  final ListingRepository repository;

  Future<Either<Failure, ListingEntity>> call({
    required ListingEntity listing,
  }) {
    return repository.updateListing(
      listing: listing,
    );
  }
}
