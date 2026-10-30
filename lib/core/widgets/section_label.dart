import 'package:flutter/material.dart';

import '../resources/app_colors.dart';

/// Small uppercase green section label, e.g. "HANDPICKED FOR YOU",
/// "EXPLORE NEARBY", "HOUSING", or "APPEARANCE".
///
/// Shared across features, so it lives in `core/widgets/`.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
    );
  }
}