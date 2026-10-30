import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rommate_finder/core/domain/entities/listing_entity.dart';
import 'package:rommate_finder/core/domain/entities/listing_host.dart';
import 'package:rommate_finder/core/domain/entities/roommate.dart';
import 'package:rommate_finder/core/errors/failure.dart';
import 'package:rommate_finder/features/discovery/domain/entities/listing_filters.dart';
import 'package:rommate_finder/features/discovery/presentation/bloc/discovery_bloc.dart';
import 'package:rommate_finder/features/discovery/presentation/bloc/discovery_event.dart';
import 'package:rommate_finder/features/discovery/presentation/bloc/discovery_state.dart';
import 'package:rommate_finder/features/home/domain/repositories/home_repository.dart';
import 'package:rommate_finder/features/home/domain/usecases/get_home_listings_usecase.dart';

/// Stand-in for the Firestore-backed home repository so the bloc can be
/// tested without Firebase.
class _FakeHomeRepository implements HomeRepository {
  _FakeHomeRepository({this.listings, this.failure});

  final List<ListingEntity>? listings;
  final Failure? failure;

  @override
  Future<Either<Failure, List<ListingEntity>>> getListings() async {
    final Failure? error = failure;

    if (error != null) {
      return Left<Failure, List<ListingEntity>>(error);
    }

    return Right<Failure, List<ListingEntity>>(
      listings ?? const <ListingEntity>[],
    );
  }
}

ListingEntity _listing({
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
    area: 'Downtown, Austin',
    priceMonthly: 700,
    roomType: RoomType.apartment,
    category: ListingCategory.apartment,
    peopleCount: 2,
  ),
  _listing(
    id: 'west-campus-room',
    area: 'West Campus, Austin',
    priceMonthly: 540,
    roomType: RoomType.universityRoom,
    category: ListingCategory.university,
    peopleCount: 1,
  ),
  _listing(
    id: 'rainey-loft',
    area: 'Rainey Street, Austin',
    priceMonthly: 1240,
    roomType: RoomType.apartment,
    category: ListingCategory.apartment,
    peopleCount: 3,
  ),
];

DiscoveryBloc _buildBloc(HomeRepository repository) {
  return DiscoveryBloc(
    getHomeListingsUseCase: GetHomeListingsUseCase(repository),
  );
}

/// Adds [event] to [bloc] and returns every state it emitted.
Future<List<DiscoveryState>> _emit(
  DiscoveryBloc bloc,
  DiscoveryEvent event,
) async {
  final List<DiscoveryState> states = <DiscoveryState>[];
  final subscription = bloc.stream.listen(states.add);

  bloc.add(event);
  await pumpEventQueue();
  await subscription.cancel();

  return states;
}

void main() {
  group('DiscoveryBloc', () {
    test('loads the listings from the repository', () async {
      final DiscoveryBloc bloc = _buildBloc(
        _FakeHomeRepository(listings: _listings()),
      );

      final List<DiscoveryState> states = await _emit(
        bloc,
        const GetDiscoveryListingsEvent(),
      );

      expect(states.first, isA<DiscoveryLoading>());
      expect(states.last, isA<DiscoveryLoaded>());

      final DiscoveryLoaded loaded = states.last as DiscoveryLoaded;
      expect(loaded.allListings, hasLength(3));
      // The default maximum price keeps the $1240 loft out of the results.
      expect(loaded.results, hasLength(2));
      expect(loaded.query, '');
      expect(loaded.category, isNull);
      expect(loaded.filters, const ListingFilters());

      await bloc.close();
    });

    test('emits the empty state when the repository has nothing', () async {
      final DiscoveryBloc bloc = _buildBloc(
        _FakeHomeRepository(listings: const <ListingEntity>[]),
      );

      final List<DiscoveryState> states = await _emit(
        bloc,
        const GetDiscoveryListingsEvent(),
      );

      expect(states.last, isA<DiscoveryEmpty>());
      expect((states.last as DiscoveryEmpty).results, isEmpty);

      await bloc.close();
    });

    test('emits a failure with the repository message', () async {
      final DiscoveryBloc bloc = _buildBloc(
        _FakeHomeRepository(failure: const ServerFailure(message: 'Offline')),
      );

      final List<DiscoveryState> states = await _emit(
        bloc,
        const GetDiscoveryListingsEvent(),
      );

      expect(states.last, isA<DiscoveryFailure>());
      expect((states.last as DiscoveryFailure).message, 'Offline');

      await bloc.close();
    });

    test('search filters the already loaded collection', () async {
      final DiscoveryBloc bloc = _buildBloc(
        _FakeHomeRepository(listings: _listings()),
      );
      await _emit(bloc, const GetDiscoveryListingsEvent());

      final List<DiscoveryState> states = await _emit(
        bloc,
        const SearchQueryChanged('west campus'),
      );

      final DiscoveryLoaded loaded = states.last as DiscoveryLoaded;
      expect(loaded.query, 'west campus');
      expect(loaded.results.map((ListingEntity l) => l.id).toList(), <String>[
        'west-campus-room',
      ]);

      await bloc.close();
    });

    test('category selection narrows the results', () async {
      final DiscoveryBloc bloc = _buildBloc(
        _FakeHomeRepository(listings: _listings()),
      );
      await _emit(bloc, const GetDiscoveryListingsEvent());

      final List<DiscoveryState> states = await _emit(
        bloc,
        const CategoryChanged(ListingCategory.university),
      );

      final DiscoveryLoaded loaded = states.last as DiscoveryLoaded;
      expect(loaded.category, ListingCategory.university);
      expect(loaded.results.map((ListingEntity l) => l.id).toList(), <String>[
        'west-campus-room',
      ]);

      await bloc.close();
    });

    test('sheet filters narrow the results', () async {
      final DiscoveryBloc bloc = _buildBloc(
        _FakeHomeRepository(listings: _listings()),
      );
      await _emit(bloc, const GetDiscoveryListingsEvent());

      final List<DiscoveryState> states = await _emit(
        bloc,
        const FiltersChanged(ListingFilters(maxPrice: 600)),
      );

      final DiscoveryLoaded loaded = states.last as DiscoveryLoaded;
      expect(loaded.filters.maxPrice, 600);
      expect(loaded.results.map((ListingEntity l) => l.id).toList(), <String>[
        'west-campus-room',
      ]);

      await bloc.close();
    });

    test(
      'clearing search and filters restores the default result set',
      () async {
        final DiscoveryBloc bloc = _buildBloc(
          _FakeHomeRepository(listings: _listings()),
        );
        await _emit(bloc, const GetDiscoveryListingsEvent());
        await _emit(bloc, const SearchQueryChanged('west campus'));
        await _emit(bloc, const CategoryChanged(ListingCategory.university));
        await _emit(bloc, const FiltersChanged(ListingFilters(maxPrice: 600)));

        final List<DiscoveryState> states = await _emit(
          bloc,
          const ClearSearchAndFilters(),
        );

        final DiscoveryLoaded loaded = states.last as DiscoveryLoaded;
        expect(loaded.query, '');
        expect(loaded.category, isNull);
        expect(loaded.filters, const ListingFilters());
        // The default maximum price still applies, so the $1240 loft stays out.
        expect(loaded.results.map((ListingEntity l) => l.id).toList(), <String>[
          'downtown-apartment',
          'west-campus-room',
        ]);

        await bloc.close();
      },
    );

    test('ignores search changes until the listings are loaded', () async {
      final DiscoveryBloc bloc = _buildBloc(
        _FakeHomeRepository(listings: _listings()),
      );

      final List<DiscoveryState> states = await _emit(
        bloc,
        const SearchQueryChanged('west campus'),
      );

      expect(states, isEmpty);
      expect(bloc.state, isA<DiscoveryInitial>());

      await bloc.close();
    });
  });
}
