import 'package:flutter/material.dart';

import '../../../../core/resources/app_colors.dart';
import '../../../../core/resources/app_spacing.dart';

/// Listing photo.
///
/// The Figma frames use interior photography that has not been exported as an
/// asset yet, so this renders a tinted placeholder that keeps the composition
/// and rounded shape intact. Swap in `Image.asset` once real photos exist.

class ListingPhoto extends StatelessWidget {
  const ListingPhoto({
    super.key,
    this.imageUrl,
    this.borderRadius = AppRadius.lg,
    this.iconSize = 32,
  });

  final String? imageUrl;
  final double borderRadius;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final String? url = imageUrl?.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.primaryTint,
        ),
        child: SizedBox.expand(
          child: url == null || url.isEmpty
              ? _buildFallback()
              : Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildFallback();
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildFallback() {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.primaryTint,
      ),
      child: Center(
        child: Icon(
          Icons.home_outlined,
          size: iconSize,
          color: AppColors.avatarGreen.withValues(alpha: 0.6),
        ),
      ),
    );
  }
}


/// Circular favorite (heart) button used on cards and on Listing Details.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onPressed,
    this.size = 36,
    this.filled = true,
  });

  final bool isFavorite;
  final VoidCallback onPressed;
  final double size;

  /// Whether the button sits on top of imagery and needs a white backdrop.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final Color background = filled
        ? Colors.white
        : Theme.of(context).colorScheme.surface;
    final Color foreground = isFavorite
        ? AppColors.primary
        : Theme.of(context).textTheme.bodyMedium?.color ?? AppColors.primary;

    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            isFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_outline_rounded,
            size: size * 0.5,
            color: foreground,
          ),
        ),
      ),
    );
  }
}

/// Small label such as "APARTMENT" or "PUBLISHED".
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.color,
    this.backgroundColor,
  });

  final String label;
  final Color? color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final Color foreground = color ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.primaryTint,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

/// Location line: pin icon followed by the area text.
class LocationLine extends StatelessWidget {
  const LocationLine({super.key, required this.area});

  final String area;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.place_outlined,
          size: 14,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        const SizedBox(width: AppSpacing.xxs),
        Flexible(
          child: Text(
            area,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}

/// Price row: green price followed by a muted "/month".
class PriceLabel extends StatelessWidget {
  const PriceLabel({super.key, required this.price});

  final int price;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '\$$price',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppColors.primary,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 2),
        Text('/month', style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

/// Empty state used when search or filters match nothing.
class EmptyResults extends StatelessWidget {
  const EmptyResults({
    super.key,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 40,
              color: AppColors.avatarGreen.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              FilledButton.tonal(
                onPressed: onAction,
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
