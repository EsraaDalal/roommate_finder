import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/di.dart';
import '../../../../core/domain/entities/listing_entity.dart';
import '../../../../core/resources/app_spacing.dart';
import '../../../../core/widgets/pill_search_field.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../applications/presentation/bloc/application_bloc.dart';

import '../../../discovery/presentation/pages/listing_details_page.dart';

import '../../../discovery/presentation/widgets/listing_card.dart';
import '../../../favorites/presentation/bloc/favorite_bloc.dart';
import '../../../favorites/presentation/bloc/favorite_event.dart';
import '../../../favorites/presentation/bloc/favorite_state.dart';
import '../../../favorites/presentation/utils/favorite_listing_mapper.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../../../notifications/presentation/bloc/notification_state.dart';
import '../../../notifications/presentation/pages/notifications_page.dart';
import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

/// Home screen.
///
/// Mirrors `ai/design/home_page.png`: greeting, "Find a place that feels
/// right." headline, search field with a filter shortcut, the "Fresh places"
/// carousel, and the "Popular areas" row.
class HomePage extends StatefulWidget {
  const HomePage({super.key, this.onSeeAll});

  /// Switches the shell to the Explore tab. Supplied by the main shell so the
  /// carousel can hand off without stacking a duplicate Explore page.
  final VoidCallback? onSeeAll;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openDetails(ListingEntity listing) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider(
          create: (_) => getIt<ApplicationBloc>(),
          child: ListingDetailsPage(listing: listing),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return BlocProvider<HomeBloc>(
      create: (_) => getIt<HomeBloc>()..add(const GetHomeListingsEvent()),
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final List<ListingEntity> allListings = state is HomeLoaded
              ? state.listings
              : const <ListingEntity>[];

          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pageHorizontal,
                        AppSpacing.sm,
                        AppSpacing.pageHorizontal,
                        0,
                      ),
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Good morning, Alex',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                            Material(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(AppRadius.md),
                              child: InkWell(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => const NotificationsPage(),
                                  ),
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                child: SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: BlocBuilder<NotificationBloc, NotificationState>(
                                    builder: (context, state) {
                                      final unreadCount = state is NotificationLoaded
                                          ? state.unreadCount
                                          : 0;

                                      return Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Icon(
                                            Icons.notifications_none_rounded,
                                            size: 22,
                                            color: theme.textTheme.titleMedium?.color,
                                          ),
                                          if (unreadCount > 0)
                                            Positioned(
                                              top: 10,
                                              right: 10,
                                              child: Container(
                                                width: 8,
                                                height: 8,
                                                decoration: BoxDecoration(
                                                  color: theme.colorScheme.primary,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(text: 'Find a place that feels '),
                              TextSpan(
                                text: 'right.',
                                style: TextStyle(
                                  color: theme.colorScheme.secondary,
                                ),
                              ),
                            ],
                          ),
                          style: theme.textTheme.displayLarge,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        PillSearchField(
                          controller: _searchController,
                          hint: 'Search by city or area',
                          onChanged: (value) {},
                          onClear: () {},
                          onFilterTap: () {},
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        const SectionLabel('Handpicked for you'),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          children: [
                            Text(
                              'Fresh places',
                              style: theme.textTheme.displayMedium,
                            ),
                            const Spacer(),
                            TextButton(
                              onPressed: widget.onSeeAll ?? () {},
                              child: const Text('See all'),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SizedBox(
                          height: 238,
                          child: BlocBuilder<FavoritesBloc, FavoritesState>(
                            builder: (context, favoritesState) {
                              final favoriteIds =
                                  favoritesState is FavoritesLoaded
                                  ? favoritesState.favorites
                                        .map((item) => item.id)
                                        .toSet()
                                  : <String>{};

                              if (state is HomeLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }

                              return ListView.separated(
                                scrollDirection: Axis.horizontal,
                                clipBehavior: Clip.none,
                                itemCount: allListings.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(width: AppSpacing.sm),
                                itemBuilder: (context, index) {
                                  final listing = allListings[index];
                                  final isFavorite = favoriteIds.contains(
                                    listing.id,
                                  );

                                  return ListingCarouselCard(
                                    listing: listing,
                                    isFavorite: isFavorite,
                                    onFavoriteToggle: () {
                                      final uid = FirebaseAuth
                                          .instance
                                          .currentUser
                                          ?.uid;

                                      context.read<FavoritesBloc>().add(
                                        ToggleFavorite(
                                          listing: toFavoriteListingEntity(
                                            listing: listing,
                                            userId: uid,
                                          ),
                                        ),
                                      );
                                    },
                                    onTap: () => _openDetails(listing),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        const SectionLabel('Explore nearby'),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Popular areas',
                          style: theme.textTheme.displayMedium,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            for (final String area in _kPopularAreas)
                              _AreaChip(label: area),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Areas shown in the "Popular areas" row.
const List<String> _kPopularAreas = ['West Campus', 'North Loop', 'Downtown'];

class _AreaChip extends StatelessWidget {
  const _AreaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InkWell(
        // Area drill-down is a later refinement; the chip is presentational.
        onTap: () {},
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Text(label, style: theme.textTheme.titleMedium),
        ),
      ),
    );
  }
}
