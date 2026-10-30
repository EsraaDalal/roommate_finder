import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/domain/entities/listing_entity.dart';
import '../repositories/listing_repository.dart';

class GetListingByIdUseCase {
  final ListingRepository repository;

  GetListingByIdUseCase({
    required this.repository,
  });

  Future<Either<Failure, ListingEntity>> call({
    required String listingId,
  }) {
    return repository.getListingById(
      listingId: listingId,
    );
  }
}