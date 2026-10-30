

import '../../domain/entities/favorite_listing_entity.dart';

abstract class FavoritesState{
  const FavoritesState();

}

class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

class FavoritesLoading extends FavoritesState {
  const FavoritesLoading();
}

class FavoritesLoaded extends FavoritesState {
  final List<FavoriteListingEntity> favorites;
  final String? message;

  const FavoritesLoaded({
    required this.favorites,
    this.message,
  });

}

class FavoritesError extends FavoritesState {
  final String message;

  const FavoritesError({required this.message});


}