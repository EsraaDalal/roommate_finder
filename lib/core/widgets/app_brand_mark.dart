import 'package:flutter/material.dart';

import '../resources/app_colors.dart';

/// Green rounded-square "R" brand mark.
///
/// Appears in the top-left corner across the designs: splash, onboarding,
/// login, register, Favorites, Chat, Profile, My homes, and My applications.
/// It is shared by every feature, so it lives in `core/widgets/`.
class AppBrandMark extends StatelessWidget {
  const AppBrandMark({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Text(
        'R',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}