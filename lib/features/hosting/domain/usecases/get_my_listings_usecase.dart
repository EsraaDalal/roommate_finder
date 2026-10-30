
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/domain/entities/listing_entity.dart';
import '../repositories/listing_repository.dart';

class GetMyListingsUseCase {
  const GetMyListingsUseCase({
    required this.repository,
  });

  final ListingRepository repository;

  Future<Either<Failure, List<ListingEntity>>> call({
    required String ownerId,
  }) {
    return repository.getMyListings(
      ownerId: ownerId,
    );
  }
}
