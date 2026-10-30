import 'package:flutter/material.dart';

/// Centralized color tokens for the Roommate Finder app.
///
/// Values were extracted from the Figma screenshots in `ai/design/`.
/// The brand green `#1C6B4B` is the dominant accent across every screen
/// (primary buttons, prices, sent chat bubbles, section labels, logo).
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF1C6B4B);
  static const Color primaryDeep = Color(0xFF145039);
  static const Color primaryTint = Color(0xFFE6F2EC);
  static const Color avatarGreen = Color(0xFF477B68);

  // Light scheme surfaces
  static const Color background = Color(0xFFF7F7F3);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF0F1EB);

  // Light scheme content
  static const Color textPrimary = Color(0xFF111111);
  static const Color textSecondary = Color(0xFF5F6360);
  static const Color textHint = Color(0xFF9CA3A0);
  static const Color border = Color(0xFFE2E4DE);

  // Dark scheme surfaces
  static const Color backgroundDark = Color(0xFF121614);
  static const Color surfaceDark = Color(0xFF1B211E);
  static const Color surfaceMutedDark = Color(0xFF242B27);

  // Dark scheme content
  static const Color textPrimaryDark = Color(0xFFF2F3F1);
  static const Color textSecondaryDark = Color(0xFFAEB5B1);
  static const Color textHintDark = Color(0xFF79817D);
  static const Color borderDark = Color(0xFF2E3531);
  static const Color primaryTintDark = Color(0xFF1E2E27);

  /// Accent used for readable green text/icons on dark surfaces.
  static const Color primaryOnDark = Color(0xFF5FBF95);
}