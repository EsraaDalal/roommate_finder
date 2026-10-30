import 'package:flutter/material.dart';

import '../../../../core/domain/entities/listing_entity.dart';
import '../../../../core/resources/app_spacing.dart';
import 'listing_card_widgets.dart';

/// Horizontal card used in the Home screen's "Fresh places" carousel.
class ListingCarouselCard extends StatelessWidget {
  const ListingCarouselCard({
    super.key,
    required this.listing,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onTap,
  });

  final ListingEntity listing;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SizedBox(
      width: 232,
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  SizedBox(
                    width: 232,
                    height: 140,
                    child:
                        listing.photoUrls.isNotEmpty &&
                            listing.photoUrls.first.trim().isNotEmpty
                        ? Image.network(
                            listing.photoUrls.first,
                            width: 232,
                            height: 140,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                return child;
                              }

                              return const ListingPhoto();
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const ListingPhoto();
                            },
                          )
                        : const ListingPhoto(),
                  ),

                  Positioned(
                    top: AppSpacing.xs,
                    right: AppSpacing.xs,
                    child: FavoriteButton(
                      isFavorite: isFavorite,
                      onPressed: onFavoriteToggle,
                      size: 32,
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PriceLabel(price: listing.priceMonthly),
                    const SizedBox(height: AppSpacing.xxs),
                    Text(
                      listing.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    LocationLine(area: listing.area),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Vertical card used in the Explore results list and the Favorites screen.
class ListingListCard extends StatelessWidget {
  const ListingListCard({
    super.key,
    required this.listing,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onTap,
    this.showFavorite = true,
  });

  final ListingEntity listing;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;
  final bool showFavorite;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child: Stack(
                  children: [
                    Positioned.fill(
  child: ListingPhoto(
    imageUrl: listing.photoUrls.isNotEmpty
        ? listing.photoUrls.first
        : null,
  ),
),
                    if (showFavorite)
                      Positioned(
                        top: AppSpacing.xxs,
                        right: AppSpacing.xxs,
                        child: FavoriteButton(
                          isFavorite: isFavorite,
                          onPressed: onFavoriteToggle,
                          size: 30,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PriceLabel(price: listing.priceMonthly),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        listing.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      LocationLine(area: listing.area),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
