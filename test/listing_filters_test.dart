import 'package:flutter_test/flutter_test.dart';
import 'package:rommate_finder/core/domain/entities/listing_entity.dart';
import 'package:rommate_finder/core/domain/entities/listing_host.dart';
import 'package:rommate_finder/core/domain/entities/roommate.dart';
import 'package:rommate_finder/features/discovery/domain/entities/listing_filters.dart';
import 'package:rommate_finder/features/discovery/presentation/bloc/discovery_state.dart';

/// Builds a [ListingEntity] the way the Firestore-backed flow produces one.
ListingEntity buildListing({
  required String id,
  required String area,
  required int priceMonthly,
  required RoomType roomType,
  required ListingCategory category,
  required int peopleCount,
}) {
  return ListingEntity(
    id: id,
    title: 'Test place $id',
    description: 'A description.',
    priceMonthly: priceMonthly,
    area: area,
    roomType: roomType,
    category: category,
    furnished: true,
    peopleCount: peopleCount,
    spacesRemaining: 1,
    rules: const <String>['No smoking'],
    roommates: const <Roommate>[],
    host: const ListingHost(
      initials: 'AM',
      name: 'Alex Morgan',
      responseTime: 'Usually responds within an hour',
    ),
    photoCount: 0,
    ownerId: 'user-alex',
  );
}

void main() {
  final List<ListingEntity> listings = <ListingEntity>[
    buildListing(
      id: 'downtown-apartment',
      area: 'Downtown, Austin',
      priceMonthly: 700,
      roomType: RoomType.apartment,
      category: ListingCategory.apartment,
      peopleCount: 2,
    ),
    buildListing(
      id: 'north-loop-studio',
      area: 'North Loop, Austin',
      priceMonthly: 900,
      roomType: RoomType.studio,
      category: ListingCategory.apartment,
      peopleCount: 1,
    ),
    buildListing(
      id: 'west-campus-room',
      area: 'West Campus, Austin',
      priceMonthly: 540,
      roomType: RoomType.universityRoom,
      category: ListingCategory.university,
      peopleCount: 1,
    ),
    buildListing(
      id: 'rainey-loft',
      area: 'Rainey Street, Austin',
      priceMonthly: 1240,
      roomType: RoomType.apartment,
      category: ListingCategory.apartment,
      peopleCount: 3,
    ),
  ];

  List<String> idsOf(List<ListingEntity> results) =>
      results.map((ListingEntity listing) => listing.id).toList();

  group('ListingFilters', () {
    test('search query matches the area label', () {
      const ListingFilters filters = ListingFilters(query: 'west campus');
      final List<ListingEntity> results = filters.apply(listings);

      expect(idsOf(results), <String>['west-campus-room']);
    });

    test('search query is case insensitive', () {
      const ListingFilters filters = ListingFilters(query: 'NORTH LOOP');
      final List<ListingEntity> results = filters.apply(listings);

      expect(idsOf(results), <String>['north-loop-studio']);
    });

    test('returns nothing for an unmatched query', () {
      const ListingFilters filters = ListingFilters(
        query: 'zzzz-no-such-place',
      );

      expect(filters.apply(listings), isEmpty);
    });

    test('area filter matches the area label', () {
      const ListingFilters filters = ListingFilters(areaQuery: 'North Loop');
      final List<ListingEntity> results = filters.apply(listings);

      expect(idsOf(results), <String>['north-loop-studio']);
    });

    test('the default maximum price still narrows the collection', () {
      final List<ListingEntity> results = const ListingFilters().apply(
        listings,
      );

      expect(idsOf(results), <String>[
        'downtown-apartment',
        'north-loop-studio',
        'west-campus-room',
      ]);
    });

    test('applies maximum price', () {
      const ListingFilters filters = ListingFilters(maxPrice: 600);
      final List<ListingEntity> results = filters.apply(listings);

      expect(idsOf(results), <String>['west-campus-room']);
      expect(results.every((ListingEntity l) => l.priceMonthly <= 600), isTrue);
    });

    test('room type filter narrows results', () {
      const ListingFilters filters = ListingFilters(
        roomType: RoomType.universityRoom,
      );
      final List<ListingEntity> results = filters.apply(listings);

      expect(idsOf(results), <String>['west-campus-room']);
    });

    test('people count filter narrows results', () {
      const ListingFilters filters = ListingFilters(peopleCount: 1);
      final List<ListingEntity> results = filters.apply(listings);

      expect(idsOf(results), <String>['north-loop-studio', 'west-campus-room']);
    });

    test('search and filters combine', () {
      const ListingFilters filters = ListingFilters(
        query: 'Austin',
        maxPrice: 800,
        roomType: RoomType.apartment,
      );
      final List<ListingEntity> results = filters.apply(listings);

      expect(idsOf(results), <String>['downtown-apartment']);
    });

    test('hasActiveFilters reflects the default selection', () {
      expect(const ListingFilters().hasActiveFilters, isFalse);
      expect(const ListingFilters(maxPrice: 800).hasActiveFilters, isTrue);
      expect(const ListingFilters(query: 'Austin').hasActiveFilters, isFalse);
    });

    test('copyWith keeps unchanged fields', () {
      const ListingFilters filters = ListingFilters(
        query: 'Austin',
        roomType: RoomType.house,
      );

      final ListingFilters updated = filters.copyWith(maxPrice: 800);

      expect(updated.query, 'Austin');
      expect(updated.maxPrice, 800);
      expect(updated.roomType, RoomType.house);
      expect(updated.peopleCount, isNull);

      final ListingFilters cleared = filters.copyWith(clearRoomType: true);
      expect(cleared.roomType, isNull);
      expect(cleared.query, 'Austin');
    });
  });

  group('DiscoveryLoaded.results', () {
    test('applies the category on top of the sheet filters', () {
      final DiscoveryLoaded state = DiscoveryLoaded(
        allListings: listings,
        query: '',
        category: ListingCategory.university,
        filters: const ListingFilters(),
      );

      expect(state.results.map((ListingEntity l) => l.id).toList(), <String>[
        'west-campus-room',
      ]);
    });
  });
}
