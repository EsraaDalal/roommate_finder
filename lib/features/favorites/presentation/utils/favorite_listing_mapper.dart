


import '../../../../core/domain/entities/listing_entity.dart';
import '../../domain/entities/favorite_listing_entity.dart';
import '../../domain/entities/favorite_listing_host.dart';
import '../../domain/entities/favorite_listong_roommate.dart';

FavoriteListingEntity toFavoriteListingEntity({
  required ListingEntity listing,
  required String? userId,
}) {
  return FavoriteListingEntity(
    id: listing.id,
    title: listing.title,
    description: listing.description,
    priceMonthly: listing.priceMonthly,
    area: listing.area,
  roomType: FavoriteRoomType.values.firstWhere(
  (e) => e.name == listing.roomType.name,
),
category: FavoriteListingCategory.values.firstWhere(
  (e) => e.name == listing.category.name,
),
    furnished: listing.furnished,
    peopleCount: listing.peopleCount,
    spacesRemaining: listing.spacesRemaining,
    userId: userId,
    rules: listing.rules,
    roommates: listing.roommates
        .map(
          (roommate) => FavoriteListongRoommate(
            initials: roommate.initials,
            name: roommate.name,
            tagline: roommate.tagline,
          ),
        )
        .toList(),
    host: FavoriteListingHost(
      initials: listing.host.initials,
      name: listing.host.name,
      responseTime: listing.host.responseTime,
    ),
    photoPaths: listing.photoPaths,
    photoUrls: listing.photoUrls,
    photoCount: listing.photoCount,
    ownerId: listing.ownerId,
  );
}