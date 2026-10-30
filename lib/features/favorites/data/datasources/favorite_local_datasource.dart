

import 'package:hive_flutter/hive_flutter.dart';

import '../models/favorite_model.dart';

class FavoriteLocalDataSource {
  final Box<FavoriteModel> favoriteBox;

  FavoriteLocalDataSource({
    required this.favoriteBox,
  });

  List<FavoriteModel> getFavoriteListings({
    required String? userId,
  }) {
    return favoriteBox.values
        .where((favorite) => favorite.userId == userId)
        .toList();
  }

  Future<bool> toggleFavorite({
    required FavoriteModel favorite,
  }) async {
    final key = _favoriteKey(
      userId: favorite.userId,
      listingId: favorite.id,
    );

    if (favoriteBox.containsKey(key)) {
      await favoriteBox.delete(key);
      return false;
    }

    await favoriteBox.put(key, favorite);
    return true;
  }

  String _favoriteKey({
    required String? userId,
    required String listingId,
  }) {
    return '${userId}_$listingId';
  }
}
