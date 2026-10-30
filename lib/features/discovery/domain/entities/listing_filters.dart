import '../../../../core/domain/entities/listing_entity.dart';

/// Active search and filter selection applied to the Explore results.
///
/// Shared between the Explore screen and its filter sheet. Filtering runs in
/// memory over the [ListingEntity] instances already loaded from the
/// repository, so typing in the search field never triggers another Firestore
/// request.
///
/// The enums used here (`RoomType`) come from `core`, not from the legacy
/// `features/discovery/data/listing.dart` model.
class ListingFilters {
  const ListingFilters({
    this.query = '',
    this.areaQuery = '',
    this.maxPrice = kDefaultMaxPrice,
    this.roomType,
    this.peopleCount,
  });

  static const int kDefaultMaxPrice = 1000;
  static const int kMinPrice = 200;
  static const int kMaxPrice = 1500;

  /// Text typed into the Explore search field.
  ///
  /// Matched against [ListingEntity.area]; listings have no separate city
  /// field, so "city or area" resolves to the area label
  /// (e.g. "Downtown, Austin").
  final String query;

  /// Text typed into the filter sheet's "City / Area" field.
  final String areaQuery;

  /// Maximum monthly price, in the same currency as
  /// [ListingEntity.priceMonthly].
  final int maxPrice;

  /// When set, only listings with this room type are shown.
  final RoomType? roomType;

  /// When set, only listings with exactly this many current occupants are
  /// shown.
  final int? peopleCount;

  bool get hasActiveFilters =>
      areaQuery.isNotEmpty ||
      maxPrice != kDefaultMaxPrice ||
      roomType != null ||
      peopleCount != null;

  ListingFilters copyWith({
    String? query,
    String? areaQuery,
    int? maxPrice,
    RoomType? roomType,
    int? peopleCount,
    bool clearRoomType = false,
    bool clearPeopleCount = false,
  }) {
    return ListingFilters(
      query: query ?? this.query,
      areaQuery: areaQuery ?? this.areaQuery,
      maxPrice: maxPrice ?? this.maxPrice,
      roomType: clearRoomType ? null : (roomType ?? this.roomType),
      peopleCount: clearPeopleCount ? null : (peopleCount ?? this.peopleCount),
    );
  }

  /// Applies this selection to [listings] in memory.
  List<ListingEntity> apply(List<ListingEntity> listings) {
    final String search = query.trim().toLowerCase();
    final String area = areaQuery.trim().toLowerCase();

    return listings
        .where((ListingEntity listing) {
          final String listingArea = listing.area.toLowerCase();

          if (search.isNotEmpty && !listingArea.contains(search)) {
            return false;
          }
          if (area.isNotEmpty && !listingArea.contains(area)) {
            return false;
          }
          if (listing.priceMonthly > maxPrice) {
            return false;
          }
          if (roomType != null && listing.roomType != roomType) {
            return false;
          }
          if (peopleCount != null && listing.peopleCount != peopleCount) {
            return false;
          }
          return true;
        })
        .toList(growable: false);
  }
}
