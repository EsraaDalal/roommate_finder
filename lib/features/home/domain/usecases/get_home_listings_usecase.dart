import 'package:dartz/dartz.dart';

import '../../../../core/domain/entities/listing_entity.dart';
import '../../../../core/errors/failure.dart';

import '../repositories/home_repository.dart';

class GetHomeListingsUseCase {
  final HomeRepository repository;

  GetHomeListingsUseCase(this.repository);

  Future<Either<Failure, List<ListingEntity>>> call() {
    return repository.getListings();
  }
}