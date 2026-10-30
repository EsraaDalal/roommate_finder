
import 'package:flutter/material.dart';

import '../../../../core/resources/app_spacing.dart';
import '../../../discovery/presentation/widgets/listing_card_widgets.dart';
import '../../domain/entities/favorite_listing_entity.dart';

class FavoriteListingCard extends StatelessWidget {
  const FavoriteListingCard({
    super.key,
    required this.favorite,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onTap,
  });

  final FavoriteListingEntity favorite;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final green = theme.colorScheme.primary;

    final imageUrl = favorite.photoUrls.isNotEmpty
        ? favorite.photoUrls.first.trim()
        : '';

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
    // الصورة في اليسار
    SizedBox(
      width: 104,
      height: 104,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _HomePlaceholder(color: green);
                },
              )
            : _HomePlaceholder(color: green),
      ),
    ),

    const SizedBox(width: AppSpacing.sm),

    // تفاصيل الإعلان في الوسط
    Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.xxs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PriceLabel(price: favorite.priceMonthly),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              favorite.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xxs),
            LocationLine(area: favorite.area),
          ],
        ),
      ),
    ),

    const SizedBox(width: AppSpacing.xxs),

    // أيقونة المفضلة في أقصى اليمين
    Material(
      color: green.withValues(alpha: 0.08),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onFavoriteToggle,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(
            isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
            color: green,
            size: 22,
          ),
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

class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color.withValues(alpha: 0.08),
      alignment: Alignment.center,
      child: Icon(
        Icons.home_outlined,
        size: 40,
        color: color,
      ),
    );
  }
}