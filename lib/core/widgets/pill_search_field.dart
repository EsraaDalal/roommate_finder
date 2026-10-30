import 'package:flutter/material.dart';

import '../resources/app_spacing.dart';

/// Rounded pill-shaped search field used by Home and Explore.
///
/// Both screens are in different features but share the same control, so it
/// lives in `core/widgets/` rather than being duplicated per feature.
class PillSearchField extends StatefulWidget {
  const PillSearchField({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.onClear,
    this.onFilterTap,
    this.filterIcon = Icons.tune_rounded,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  /// Shows a trailing filter button when provided.
  final VoidCallback? onFilterTap;
  final IconData filterIcon;

  @override
  State<PillSearchField> createState() => _PillSearchFieldState();
}

class _PillSearchFieldState extends State<PillSearchField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool hasText = widget.controller.text.isNotEmpty;

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 52,
            child: TextField(
              controller: widget.controller,
              onChanged: (String value) {
                widget.onChanged(value);
                _onControllerChanged();
              },
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyLarge?.color,
              ),
              decoration: InputDecoration(
                hintText: widget.hint,
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 40,
                  minHeight: 40,
                ),
                suffixIcon: hasText && widget.onClear != null
                    ? IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: widget.onClear,
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                ),
                border: _pillBorder(Colors.transparent),
                enabledBorder: _pillBorder(Colors.transparent),
                focusedBorder: _pillBorder(
                  theme.colorScheme.secondary,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ),
        if (widget.onFilterTap != null) ...[
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 52,
            height: 52,
            child: FilledButton(
              onPressed: widget.onFilterTap,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(52, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
              child: Icon(widget.filterIcon, size: 20),
            ),
          ),
        ],
      ],
    );
  }

  OutlineInputBorder _pillBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.pill),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}