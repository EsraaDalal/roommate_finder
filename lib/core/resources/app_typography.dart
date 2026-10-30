import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Typography tokens.
///
/// Text sizes were approximated from the Figma screenshots. The design uses a
/// geometric sans-serif; the platform default is used until a font family is
/// provided by the design files.
abstract final class AppTextStyles {
  /// "Welcome home", "Share your space", "Your homes".
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  /// "Find a Suitable Roommate", "Bright room near campus".
  static const TextStyle displayMedium = TextStyle(
    fontSize: 24,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    color: AppColors.textPrimary,
  );

  /// "About this home", "Meet your roommates".
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Listing titles, notification titles.
  static const TextStyle titleMedium = TextStyle(
    fontSize: 15,
    height: 1.3,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// Body copy and descriptions.
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 15,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 13,
    height: 1.45,
    color: AppColors.textSecondary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    height: 1.4,
    color: AppColors.textSecondary,
  );

  /// Field labels: "Email", "Password", "Monthly price".
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  /// "ROOMMATE FINDER", "APARTMENT", "HOUSING" section headers.
  static const TextStyle overline = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: AppColors.primary,
  );

  /// Price values such as "$680".
  static const TextStyle price = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.primary,
  );

  /// Bottom navigation labels.
  static const TextStyle navLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
  );
}