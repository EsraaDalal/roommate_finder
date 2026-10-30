import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entities/listing_entity.dart';
import '../../../../core/errors/failure.dart';
import '../../../home/domain/usecases/get_home_listings_usecase.dart';
import '../../domain/entities/listing_filters.dart';
import 'discovery_event.dart';
import 'discovery_state.dart';

/// Discovery bloc.
///
/// Loads the listings for the Explore screen through the existing
/// [GetHomeListingsUseCase] (the same Firestore-backed flow Home uses) and
/// keeps the search, category and filter selection in memory. The bloc never
/// talks to the data layer directly and never re-queries Firestore while the
/// user is typing or filtering.
class DiscoveryBloc extends Bloc<DiscoveryEvent, DiscoveryState> {
  final GetHomeListingsUseCase getHomeListingsUseCase;

  DiscoveryBloc({required this.getHomeListingsUseCase})
    : super(const DiscoveryInitial()) {
    on<GetDiscoveryListingsEvent>(_onGetListings);
    on<SearchQueryChanged>(_onSearchChanged);
    on<CategoryChanged>(_onCategoryChanged);
    on<FiltersChanged>(_onFiltersChanged);
    on<ClearSearchAndFilters>(_onClearSearchAndFilters);
  }

  /// The unfiltered collection, or `null` until the first successful load.
  List<ListingEntity>? _allListings;

  String _query = '';
  ListingCategory? _category;
  ListingFilters _filters = const ListingFilters();

  Future<void> _onGetListings(
    GetDiscoveryListingsEvent event,
    Emitter<DiscoveryState> emit,
  ) async {
    emit(const DiscoveryLoading());

    try {
      final result = await getHomeListingsUseCase();

      result.fold(
        (Failure failure) => emit(DiscoveryFailure(failure.message)),
        (List<ListingEntity> listings) {
          _allListings = listings;
          _emitCurrent(emit);
        },
      );
    } catch (_) {
      // The repository turns the known errors into failures. This guards
      // against anything unexpected escaping the use case.
      emit(
        const DiscoveryFailure(
          'An unexpected error occurred while loading listings.',
        ),
      );
    }
  }

  void _onSearchChanged(
    SearchQueryChanged event,
    Emitter<DiscoveryState> emit,
  ) {
    _query = event.query;
    _emitCurrent(emit);
  }

  void _onCategoryChanged(CategoryChanged event, Emitter<DiscoveryState> emit) {
    _category = event.category;
    _emitCurrent(emit);
  }

  void _onFiltersChanged(FiltersChanged event, Emitter<DiscoveryState> emit) {
    _filters = event.filters;
    _emitCurrent(emit);
  }

  void _onClearSearchAndFilters(
    ClearSearchAndFilters event,
    Emitter<DiscoveryState> emit,
  ) {
    _query = '';
    _category = null;
    _filters = const ListingFilters();
    _emitCurrent(emit);
  }

  /// Emits the state derived from the current selection.
  ///
  /// Does nothing while the collection has not been loaded yet, so search or
  /// filter changes arriving during the initial request cannot render an
  /// incorrectly empty screen.
  void _emitCurrent(Emitter<DiscoveryState> emit) {
    final List<ListingEntity>? allListings = _allListings;

    if (allListings == null) {
      return;
    }

    if (allListings.isEmpty) {
      emit(
        DiscoveryEmpty(query: _query, category: _category, filters: _filters),
      );
      return;
    }

    emit(
      DiscoveryLoaded(
        allListings: allListings,
        query: _query,
        category: _category,
        filters: _filters,
      ),
    );
  }
}
