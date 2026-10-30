
import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/favorite_listing_entity.dart';
import '../repositories/favorite_repository.dart';


class ToggleFavoriteUseCase {
  final FavoriteRepository repository;

  ToggleFavoriteUseCase({required this.repository});

  Future<Either<Failure, bool>> call({
    required FavoriteListingEntity listing,
  
  }) {
    return repository.toggleFavorite(listing: listing
      
    );
  }
}
