import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rommate_finder/core/config/di.dart';
import 'package:rommate_finder/core/domain/entities/listing_entity.dart';
import 'package:rommate_finder/core/domain/entities/listing_host.dart';
import 'package:rommate_finder/core/domain/entities/roommate.dart';
import 'package:rommate_finder/core/errors/failure.dart';
import 'package:rommate_finder/features/discovery/presentation/bloc/discovery_bloc.dart';
import 'package:rommate_finder/features/discovery/presentation/pages/explore_page.dart';
import 'package:rommate_finder/features/favorites/domain/entities/favorite_listing_entity.dart';
import 'package:rommate_finder/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:rommate_finder/features/favorites/domain/usecase/get_favorite_listing_usecase.dart';
import 'package:rommate_finder/features/favorites/domain/usecase/toggle_favorite_usecase.dart';
import 'package:rommate_finder/features/favorites/presentation/bloc/favorite_bloc.dart';
import 'package:rommate_finder/features/home/domain/repositories/home_repository.dart';
import 'package:rommate_finder/features/home/domain/usecases/get_home_listings_usecase.dart';

/// Repository double for the listing collection.
class _FakeHomeRepository implements HomeRepository {
  _FakeHomeRepository({this.listings, this.failure, this.pending});

  final List<ListingEntity>? listings;
  final Failure? failure;

  /// When set, the request stays open until the test completes it.
  final Completer<Either<Failure, List<ListingEntity>>>? pending;

  @override
  Future<Either<Failure, List<ListingEntity>>> getListings() {
    final Completer<Either<Failure, List<ListingEntity>>>? completer = pending;

    if (completer != null) {
      return completer.future;
    }

    final Failure? error = failure;
    if (error != null) {
      return Future.value(Left<Failure, List<ListingEntity>>(error));
    }

    return Future.value(
      Right<Failure, List<ListingEntity>>(listings ?? const <ListingEntity>[]),
    );
  }
}

class _FakeFavoriteRepository implements FavoriteRepository {
  @override
  Future<Either<Failure, List<FavoriteListingEntity>>> getFavoriteListings({
    String? userId,
  }) async {
    return const Right<Failure, List<FavoriteListingEntity>>(
      <FavoriteListingEntity>[],
    );
  }

  @override
  Future<Either<Failure, bool>> toggleFavorite({
    required FavoriteListingEntity listing,
  }) async {
    return const Right<Failure, bool>(false);
  }
}

ListingEntity _listing({
  required String id,
  required String title,
  required String area,
  required int priceMonthly,
  required RoomType roomType,
  required ListingCategory category,
  required int peopleCount,
}) {
  return ListingEntity(
    id: id,
    title: title,
    description: 'A description.',
    priceMonthly: priceMonthly,
    area: area,
    roomType: roomType,
    category: category,
    furnished: true,
    peopleCount: peopleCount,
    spacesRemaining: 1,
    rules: const <String>[],
    roommates: const <Roommate>[],
    host: const ListingHost(initials: 'AM', name: 'Alex', responseTime: '1h'),
    photoCount: 0,
    ownerId: 'user-alex',
  );
}

List<ListingEntity> _listings() => <ListingEntity>[
  _listing(
    id: 'downtown-apartment',
    title: 'Downtown apartment',
    area: 'Downtown, Austin',
    priceMonthly: 700,
    roomType: RoomType.apartment,
    category: ListingCategory.apartment,
    peopleCount: 2,
  ),
  _listing(
    id: 'north-loop-studio',
    title: 'North Loop studio',
    area: 'North Loop, Austin',
    priceMonthly: 900,
    roomType: RoomType.studio,
    category: ListingCategory.apartment,
    peopleCount: 1,
  ),
  _listing(
    id: 'west-campus-room',
    title: 'West Campus room',
    area: 'West Campus, Austin',
    priceMonthly: 540,
    roomType: RoomType.universityRoom,
    category: ListingCategory.university,
    peopleCount: 1,
  ),
];

void _registerDiscovery(HomeRepository repository) {
  getIt.registerFactory<DiscoveryBloc>(
    () => DiscoveryBloc(
      getHomeListingsUseCase: GetHomeListingsUseCase(repository),
    ),
  );
}

Future<void> _pumpExplore(WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider<FavoritesBloc>(
        create: (_) => FavoritesBloc(
          getFavoriteListingUseCase: GetFavoriteListingUseCase(
            repository: _FakeFavoriteRepository(),
          ),
          toggleFavoriteUseCase: ToggleFavoriteUseCase(
            repository: _FakeFavoriteRepository(),
          ),
        ),
        child: const ExplorePage(),
      ),
    ),
  );
}

void main() {
  tearDown(() async {
    await getIt.reset();
  });

  testWidgets('shows the loading state without the empty results widget', (
    WidgetTester tester,
  ) async {
    final Completer<Either<Failure, List<ListingEntity>>> pending =
        Completer<Either<Failure, List<ListingEntity>>>();
    _registerDiscovery(_FakeHomeRepository(pending: pending));

    await _pumpExplore(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('No places found'), findsNothing);
    expect(find.text('Find your space'), findsOneWidget);

    pending.complete(Right<Failure, List<ListingEntity>>(_listings()));
    await tester.pumpAndSettle();

    expect(find.text('3 places'), findsOneWidget);
    expect(find.text('Downtown apartment'), findsOneWidget);
    expect(find.text('West Campus room'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('search updates the visible list and the result count', (
    WidgetTester tester,
  ) async {
    _registerDiscovery(_FakeHomeRepository(listings: _listings()));
    await _pumpExplore(tester);
    await tester.pumpAndSettle();

    expect(find.text('3 places'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'west campus');
    await tester.pump();

    expect(find.text('1 places'), findsOneWidget);
    expect(find.text('West Campus room'), findsOneWidget);
    expect(find.text('Downtown apartment'), findsNothing);

    // Clearing the search restores the whole collection.
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pump();

    expect(find.text('3 places'), findsOneWidget);
    expect(find.text('Downtown apartment'), findsOneWidget);
  });

  testWidgets('category chips narrow the results', (WidgetTester tester) async {
    _registerDiscovery(_FakeHomeRepository(listings: _listings()));
    await _pumpExplore(tester);
    await tester.pumpAndSettle();

    await tester.tap(find.text('University'));
    await tester.pump();

    expect(find.text('1 places'), findsOneWidget);
    expect(find.text('West Campus room'), findsOneWidget);
    expect(find.text('Downtown apartment'), findsNothing);

    await tester.tap(find.text('All homes'));
    await tester.pump();

    expect(find.text('3 places'), findsOneWidget);
    expect(find.text('Downtown apartment'), findsOneWidget);
  });

  testWidgets('an unmatched search shows the empty state, not the list', (
    WidgetTester tester,
  ) async {
    _registerDiscovery(_FakeHomeRepository(listings: _listings()));
    await _pumpExplore(tester);
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'zzzz-no-such-place');
    await tester.pump();

    expect(find.text('No places found'), findsOneWidget);
    expect(find.text('0 places'), findsOneWidget);
    expect(find.text('Downtown apartment'), findsNothing);

    // The empty state offers the clear action from the design.
    await tester.tap(find.text('Clear filters'));
    await tester.pump();

    expect(find.text('3 places'), findsOneWidget);
    expect(find.text('Downtown apartment'), findsOneWidget);
  });

  testWidgets('the filter sheet applies its selection to the results', (
    WidgetTester tester,
  ) async {
    _registerDiscovery(_FakeHomeRepository(listings: _listings()));
    await _pumpExplore(tester);
    await tester.pumpAndSettle();

    expect(find.text('3 places'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Filter places'), findsOneWidget);

    // The hint text is painted by the dropdown's input decoration, so the tap
    // lands on the field rather than on the Text widget itself.
    await tester.tap(find.text('Any room type'), warnIfMissed: false);
    await tester.pumpAndSettle();
    await tester.tap(find.text('University room'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Apply filters'));
    await tester.pumpAndSettle();

    expect(find.text('Filter places'), findsNothing);
    expect(find.text('1 places'), findsOneWidget);
    expect(find.text('West Campus room'), findsOneWidget);
    expect(find.text('Downtown apartment'), findsNothing);

    // Reopening the sheet shows the selection that is still active.
    await tester.tap(find.byIcon(Icons.tune_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Filter places'), findsOneWidget);
    expect(find.text('University room'), findsOneWidget);

    // Clearing from the sheet restores the default result set.
    await tester.tap(find.text('Clear'));
    await tester.pumpAndSettle();

    expect(find.text('3 places'), findsOneWidget);
    expect(find.text('Downtown apartment'), findsOneWidget);
  });

  testWidgets('an empty collection shows its own empty state', (
    WidgetTester tester,
  ) async {
    _registerDiscovery(_FakeHomeRepository(listings: const <ListingEntity>[]));
    await _pumpExplore(tester);
    await tester.pumpAndSettle();

    expect(find.text('No listings yet'), findsOneWidget);
    expect(find.text('No places found'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });

  testWidgets('a repository failure shows the failure state with a retry', (
    WidgetTester tester,
  ) async {
    _registerDiscovery(
      _FakeHomeRepository(failure: const ServerFailure(message: 'Offline')),
    );
    await _pumpExplore(tester);
    await tester.pumpAndSettle();

    expect(find.text('Could not load places'), findsOneWidget);
    expect(find.text('Offline'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.text('No places found'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
