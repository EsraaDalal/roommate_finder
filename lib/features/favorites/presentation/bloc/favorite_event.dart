

import '../../domain/entities/favorite_listing_entity.dart';

abstract class FavoritesEvent {
  const FavoritesEvent();


}

/// تحميل إعلانات المستخدم المحفوظة في المفضلة.
class LoadFavorites extends FavoritesEvent {
  final String? userId;

  const LoadFavorites({required this.userId});

}

/// إضافة إعلان إلى المفضلة أو إزالته منها.
class ToggleFavorite extends FavoritesEvent {
  final FavoriteListingEntity listing;

  const ToggleFavorite({required this.listing});

}