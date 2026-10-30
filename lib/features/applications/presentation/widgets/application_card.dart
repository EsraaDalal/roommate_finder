import 'package:flutter/material.dart';

import '../../../../core/domain/entities/listing_entity.dart';
import '../../../../core/resources/app_spacing.dart';
import '../../domain/entities/application_entity.dart';


/// Maps a status to its chip colors.
({Color background, Color foreground}) applicationStatusColors(
  ApplicationStatus status,
  ThemeData theme,
) {
  switch (status) {
    case ApplicationStatus.pending:
      return (
        background: const Color(0xFFFDF1DC),
        foreground: const Color(0xFF8A5A16),
      );
    case ApplicationStatus.accepted:
      return (
        background: AppColorsAccepted.background,
        foreground: AppColorsAccepted.foreground,
      );
    case ApplicationStatus.rejected:
      return (
        background: theme.colorScheme.errorContainer,
        foreground: theme.colorScheme.onErrorContainer,
      );
    case ApplicationStatus.cancelled:
      return (
        background: theme.colorScheme.surfaceContainerHighest,
        foreground: theme.textTheme.bodyMedium?.color ?? Colors.grey,
      );
  }
}

/// Green chip colors reused for the accepted state.
abstract final class AppColorsAccepted {
  static const Color background = Color(0xFFE3F1E9);
  static const Color foreground = Color(0xFF1C6B4B);
}

/// Formats a date the way the designs show it: "September 1".
String formatMoveInDate(DateTime date) {
  const List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return '${months[date.month - 1]} ${date.day}';
}

/// Application card shared by My Applications and the owner review screen.
class ApplicationCard extends StatelessWidget {
  const ApplicationCard({
    super.key,
    required this.application,
    required this.listing,
    this.leading,
    this.subtitle,
    this.onTap,
    this.actions = const <Widget>[],
  });

final ApplicationEntity application;
final ListingEntity listing;

  /// Optional line under the status chip, e.g. the applicant name.
  final Widget? leading;

  /// Optional line above the actions, e.g. "Move-in: September 1".
  final String? subtitle;

  final VoidCallback? onTap;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ({Color background, Color foreground}) colors =
        applicationStatusColors(application.status, theme);

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: const SizedBox(
                      width: 84,
                      height: 84,
                      child: ColoredBox(
                        color: Color(0xFFE6F2EC),
                        child: Icon(
                          Icons.home_outlined,
                          size: 26,
                          color: Color(0xFF477B68),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: colors.background,
                            borderRadius:
                                BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            application.status.label,
                            style: TextStyle(
                              color: colors.foreground,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          listing.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: theme.textTheme.bodySmall,
                          ),
                        if (leading != null) ...[
                          const SizedBox(height: AppSpacing.xxs),
                          leading!,
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (actions.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    for (int i = 0; i < actions.length; i++) ...[
                      if (i > 0) const SizedBox(width: AppSpacing.xs),
                      actions[i],
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}


/// Small pill action button used inside application cards.
class ApplicationActionButton extends StatelessWidget {
  const ApplicationActionButton({
    super.key,
    required this.label,
    required this.onTap,
    this.icon,
    this.emphasized = false,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    final Color background = emphasized
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHighest;

    final Color foreground = emphasized
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurface;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: 6,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 14, color: foreground),
                const SizedBox(width: AppSpacing.xxs),
              ],
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
