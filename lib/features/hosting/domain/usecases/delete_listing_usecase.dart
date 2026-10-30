
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/listing_repository.dart';

class DeleteListingUseCase {
  const DeleteListingUseCase({
    required this.repository,
  });

  final ListingRepository repository;

  Future<Either<Failure, void>> call({
    required String listingId,
    required String ownerId,
  }) {
    return repository.deleteListing(
      listingId: listingId,
      ownerId: ownerId,
    );
  }
}
