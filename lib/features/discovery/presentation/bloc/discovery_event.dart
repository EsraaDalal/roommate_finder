import 'package:flutter/foundation.dart';

import '../../../../core/domain/entities/listing_entity.dart';
import '../../domain/entities/listing_filters.dart';

/// Events handled by the Discovery bloc.
@immutable
sealed class DiscoveryEvent {
  const DiscoveryEvent();
}

/// Requests the listings shown on the Explore screen.
///
/// Follows the `GetHomeListingsEvent` naming used by the Home bloc.
final class GetDiscoveryListingsEvent extends DiscoveryEvent {
  const GetDiscoveryListingsEvent();
}

/// The text typed into the Explore search field changed.
final class SearchQueryChanged extends DiscoveryEvent {
  const SearchQueryChanged(this.query);

  final String query;
}

/// A category chip was selected. `null` selects "All homes".
final class CategoryChanged extends DiscoveryEvent {
  const CategoryChanged(this.category);

  final ListingCategory? category;
}

/// The filter sheet returned a new selection.
final class FiltersChanged extends DiscoveryEvent {
  const FiltersChanged(this.filters);

  final ListingFilters filters;
}

/// Clears the search field, the selected category and the sheet filters.
final class ClearSearchAndFilters extends DiscoveryEvent {
  const ClearSearchAndFilters();
}
