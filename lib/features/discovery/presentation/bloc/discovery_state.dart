import 'package:flutter/foundation.dart';

import '../../../../core/domain/entities/listing_entity.dart';
import '../../domain/entities/listing_filters.dart';

/// States emitted by the Discovery bloc.
@immutable
sealed class DiscoveryState {
  const DiscoveryState();
}

/// Nothing has been requested yet.
final class DiscoveryInitial extends DiscoveryState {
  const DiscoveryInitial();
}

/// The listings are being requested.
final class DiscoveryLoading extends DiscoveryState {
  const DiscoveryLoading();
}

/// The listings were loaded successfully.
///
/// Holds the unfiltered collection plus the active search, category and
/// sheet filters; [results] is the collection the Explore screen renders.
class DiscoveryLoaded extends DiscoveryState {
  const DiscoveryLoaded({
    required this.allListings,
    required this.query,
    required this.category,
    required this.filters,
  });

  /// Every listing returned by the repository, unfiltered.
  final List<ListingEntity> allListings;

  /// Text typed into the search field.
  final String query;

  /// Selected category chip, or `null` for "All homes".
  final ListingCategory? category;

  /// Selection returned by the filter sheet.
  final ListingFilters filters;

  /// The listings matching the search text, the sheet filters and the
  /// selected category.
  List<ListingEntity> get results {
    // The search field and the filter sheet keep their own text, so both are
    // applied here: [query] is the Explore search field, [ListingFilters.query]
    // is whatever the sheet carried over.
    final List<ListingEntity> byFilters = filters
        .copyWith(query: query)
        .apply(allListings);

    if (category == null) {
      return byFilters;
    }

    return byFilters
        .where((ListingEntity listing) => listing.category == category)
        .toList(growable: false);
  }
}

/// The request succeeded but the repository returned no listings at all.
///
/// Distinct from a [DiscoveryLoaded] state whose [DiscoveryLoaded.results]
/// are empty because the search or filters excluded everything.
final class DiscoveryEmpty extends DiscoveryLoaded {
  const DiscoveryEmpty({
    required super.query,
    required super.category,
    required super.filters,
  }) : super(allListings: const <ListingEntity>[]);
}

/// The listings could not be loaded.
final class DiscoveryFailure extends DiscoveryState {
  /// Message that describes why the request failed.
  final String message;

  const DiscoveryFailure(this.message);
}
