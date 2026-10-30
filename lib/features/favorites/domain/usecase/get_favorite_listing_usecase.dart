
import 'package:dartz/dartz.dart';


import '../../../../core/errors/failure.dart';
import '../entities/favorite_listing_entity.dart';
import '../repositories/favorite_repository.dart';

class GetFavoriteListingUseCase {
  final FavoriteRepository repository;

  GetFavoriteListingUseCase({required this.repository});

  Future<Either<Failure, List<FavoriteListingEntity>>> call({
    required String? userId,
  }) {
    return repository.getFavoriteListings(userId: userId);
  }
}

