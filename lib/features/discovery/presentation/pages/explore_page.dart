import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/di.dart';
import '../../../../core/domain/entities/listing_entity.dart';
import '../../../../core/resources/app_colors.dart';
import '../../../../core/resources/app_spacing.dart';
import '../../../../core/widgets/pill_search_field.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../applications/presentation/bloc/application_bloc.dart';
import '../../../favorites/presentation/bloc/favorite_bloc.dart';
import '../../../favorites/presentation/bloc/favorite_event.dart';
import '../../../favorites/presentation/bloc/favorite_state.dart';
import '../../../favorites/presentation/utils/favorite_listing_mapper.dart';
import '../../domain/entities/listing_filters.dart';
import '../bloc/discovery_bloc.dart';
import '../bloc/discovery_event.dart';
import '../bloc/discovery_state.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../widgets/listing_card.dart';
import '../widgets/listing_card_widgets.dart';
import 'listing_details_page.dart';

/// Explore screen.
///
/// Mirrors `ai/design/explore_page.png`: location eyebrow, "Find your space"
/// heading, search field with a filter button, category chips, a result count
/// with "Best match", and the vertical listing list.
///
/// Listings come from the existing Firestore-backed flow through
/// [DiscoveryBloc]; favorites come from the app-level [FavoritesBloc].
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  final TextEditingController _searchController = TextEditingController();

  /// Favorite ids from the last successful [FavoritesBloc] state.
  ///
  /// Cached so a failed toggle keeps the hearts on screen correct instead of
  /// resetting them all to "not favorited".
  Set<String> _favoriteIds = const <String>{};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // The callbacks below take the [BuildContext] handed to the [BlocBuilder],
  // which sits under the [BlocProvider] created in [build]; the State's own
  // `context` is above that provider and cannot resolve the bloc.

  void _onSearchChanged(BuildContext context, String value) {
    context.read<DiscoveryBloc>().add(SearchQueryChanged(value));
  }

  void _clearSearch(BuildContext context) {
    _searchController.clear();
    context.read<DiscoveryBloc>().add(const SearchQueryChanged(''));
  }

  Future<void> _openFilters(BuildContext context) async {
    // Resolved before the await so the sheet result is dispatched through the
    // bloc rather than through a context used across an async gap.
    final DiscoveryBloc bloc = context.read<DiscoveryBloc>();
    final DiscoveryState state = bloc.state;
    final ListingFilters current = switch (state) {
      DiscoveryLoaded(:final filters) => filters,
      _ => const ListingFilters(),
    };

    final ListingFilters? result = await showListingFilterSheet(
      context,
      current,
    );
    if (result != null && mounted) {
      bloc.add(FiltersChanged(result));
    }
  }

  void _clearAll(BuildContext context) {
    _searchController.clear();
    context.read<DiscoveryBloc>().add(const ClearSearchAndFilters());
  }

  void _retry(BuildContext context) {
    context.read<DiscoveryBloc>().add(const GetDiscoveryListingsEvent());
  }

  void _openDetails(BuildContext context, ListingEntity listing) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        // Same route setup as Home: the details page's "Apply for housing"
        // sheet reads an ApplicationBloc.
        builder: (_) => BlocProvider(
          create: (_) => getIt<ApplicationBloc>(),
          child: ListingDetailsPage(listing: listing),
        ),
      ),
    );
  }

  void _toggleFavorite(BuildContext context, ListingEntity listing) {
    final String? uid = FirebaseAuth.instance.currentUser?.uid;

    context.read<FavoritesBloc>().add(
      ToggleFavorite(
        listing: toFavoriteListingEntity(listing: listing, userId: uid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DiscoveryBloc>(
      create: (_) =>
          getIt<DiscoveryBloc>()..add(const GetDiscoveryListingsEvent()),
      child: BlocBuilder<DiscoveryBloc, DiscoveryState>(
        builder: (context, DiscoveryState state) {
          final ThemeData theme = Theme.of(context);
          final List<ListingEntity> listings = state is DiscoveryLoaded
              ? state.results
              : const <ListingEntity>[];

          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal,
                      AppSpacing.sm,
                      AppSpacing.pageHorizontal,
                      0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionLabel('Austin, Texas'),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Find your space',
                          style: theme.textTheme.displayMedium,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        PillSearchField(
                          controller: _searchController,
                          hint: 'City or area',
                          onChanged: (String value) =>
                              _onSearchChanged(context, value),
                          onClear: () => _clearSearch(context),
                          onFilterTap: () {
                            _openFilters(context);
                          },
                        ),
                        const SizedBox(height: AppSpacing.md),
                       
                        Row(
                          children: [
                            Text(
                              state is DiscoveryLoaded
                                  ? '${listings.length} places'
                                  : '',
                              style: theme.textTheme.titleMedium,
                            ),
                            const Spacer(),
                            Text(
                              'Best match',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                      ],
                    ),
                  ),
                  Expanded(child: _buildResults(context, state, listings)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Renders loading, failure, empty and populated results distinctly so the
  /// empty state is never shown while the listings are still loading.
  Widget _buildResults(
    BuildContext context,
    DiscoveryState state,
    List<ListingEntity> listings,
  ) {
    final ThemeData theme = Theme.of(context);

    if (state is DiscoveryInitial || state is DiscoveryLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is DiscoveryFailure) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.cloud_off_rounded,
                size: 40,
                color: AppColors.avatarGreen.withValues(alpha: 0.5),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Could not load places',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                state.message,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.tonal(
                onPressed: () => _retry(context),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    if (listings.isEmpty) {
      final bool inventoryEmpty = state is DiscoveryEmpty;

      return EmptyResults(
        title: inventoryEmpty ? 'No listings yet' : 'No places found',
        message: inventoryEmpty
            ? 'Homes will show up here as soon as they are published.'
            : 'Try a different search or clear your filters to see '
                  'more listings.',
        actionLabel: inventoryEmpty ? null : 'Clear filters',
        onAction: inventoryEmpty ? null : () => _clearAll(context),
      );
    }

    return BlocConsumer<FavoritesBloc, FavoritesState>(
      listener: (BuildContext context, FavoritesState favoritesState) {
        if (favoritesState is FavoritesError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(favoritesState.message)));
        }
      },
      builder: (BuildContext context, FavoritesState favoritesState) {
        if (favoritesState is FavoritesLoaded) {
          _favoriteIds = favoritesState.favorites
              .map((favorite) => favorite.id)
              .toSet();
        }
        final Set<String> favoriteIds = _favoriteIds;

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pageHorizontal,
            0,
            AppSpacing.pageHorizontal,
            AppSpacing.lg,
          ),
          itemCount: listings.length,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (BuildContext context, int index) {
            final ListingEntity listing = listings[index];

            return ListingListCard(
              listing: listing,
              isFavorite: favoriteIds.contains(listing.id),
              onFavoriteToggle: () => _toggleFavorite(context, listing),
              onTap: () => _openDetails(context, listing),
            );
          },
        );
      },
    );
  }
}


