import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/favorite_listing_entity.dart';
import '../../domain/usecase/get_favorite_listing_usecase.dart';
import '../../domain/usecase/toggle_favorite_usecase.dart';
import 'favorite_event.dart';
import 'favorite_state.dart';


class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavoriteListingUseCase getFavoriteListingUseCase;
  final ToggleFavoriteUseCase toggleFavoriteUseCase;

  String? _currentUserId;
  List<FavoriteListingEntity> _favorites = [];

  FavoritesBloc({
    required this.getFavoriteListingUseCase,
    required this.toggleFavoriteUseCase,
  }) : super(const FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    _currentUserId = event.userId;

    emit(const FavoritesLoading());

    final result = await getFavoriteListingUseCase(
      userId: event.userId,
    );

    result.fold(
      (failure) {
        emit(FavoritesError(message: failure.message));
      },
      (favorites) {
        _favorites = List<FavoriteListingEntity>.from(favorites);

        emit(FavoritesLoaded(favorites: _favorites));
      },
    );
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FavoritesState> emit,
  ) async {
    final listing = event.listing;

    final result = await toggleFavoriteUseCase(
      listing: listing,
    );

    result.fold(
      (failure) {
        emit(FavoritesError(message: failure.message));
      },
      (isFavorite) {
        if (isFavorite) {
          final alreadyExists = _favorites.any(
            (favorite) => favorite.id == listing.id,
          );

          if (!alreadyExists) {
            _favorites = [..._favorites, listing];
          }
        } else {
          _favorites = _favorites
              .where((favorite) => favorite.id != listing.id)
              .toList();
        }

        emit(FavoritesLoaded(
          favorites: List.unmodifiable(_favorites),
          message: isFavorite
              ? 'Ad added to favorites'
              : 'Ad removed from favorites',
        ));
      },
    );
  }
}