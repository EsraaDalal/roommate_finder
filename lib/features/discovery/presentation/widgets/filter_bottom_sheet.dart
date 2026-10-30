import 'package:flutter/material.dart';

import '../../../../core/domain/entities/listing_entity.dart';
import '../../../../core/resources/app_spacing.dart';
import '../../domain/entities/listing_filters.dart';

/// Opens the filter sheet and returns the applied selection, or `null` if the
/// user closed it without applying.
///
/// Mirrors `ai/design/filter_bottom_sheet.png`: city/area field, maximum
/// monthly price slider, room type and number of people dropdowns, plus Clear
/// and Apply filters actions.
Future<ListingFilters?> showListingFilterSheet(
  BuildContext context,
  ListingFilters current,
) {
  return showModalBottomSheet<ListingFilters>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext sheetContext) {
      return _FilterSheet(initial: current);
    },
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initial});

  final ListingFilters initial;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late final TextEditingController _areaController;
  late double _maxPrice;
  RoomType? _roomType;
  int? _peopleCount;

  @override
  void initState() {
    super.initState();
    _areaController = TextEditingController(text: widget.initial.areaQuery);
    _maxPrice = widget.initial.maxPrice.toDouble();
    _roomType = widget.initial.roomType;
    _peopleCount = widget.initial.peopleCount;
  }

  @override
  void dispose() {
    _areaController.dispose();
    super.dispose();
  }

  void _clear() {
    Navigator.of(context).pop(ListingFilters(query: widget.initial.query));
  }

  void _apply() {
    Navigator.of(context).pop(
      ListingFilters(
        query: widget.initial.query,
        areaQuery: _areaController.text,
        maxPrice: _maxPrice.round(),
        roomType: _roomType,
        peopleCount: _peopleCount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.xs,
          bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Filter places',
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontSize: 22,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Close'),
                  ),
                ],
              ),
            
              const SizedBox(height: AppSpacing.lg),
              Text('Maximum monthly price', style: theme.textTheme.labelLarge),
              Slider(
                value: _maxPrice,
                min: ListingFilters.kMinPrice.toDouble(),
                max: ListingFilters.kMaxPrice.toDouble(),
                divisions:
                    (ListingFilters.kMaxPrice - ListingFilters.kMinPrice) ~/ 20,
                label: 'Up to \$${_maxPrice.round()}',
                onChanged: (double value) => setState(() => _maxPrice = value),
              ),
              Text(
                'Up to \$${_maxPrice.round()}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Room type', style: theme.textTheme.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              DropdownButtonFormField<RoomType>(
                initialValue: _roomType,
                decoration: const InputDecoration(),
                hint: const Text('Any room type'),
                items: [
                  for (final RoomType type in RoomType.values)
                    DropdownMenuItem<RoomType>(
                      value: type,
                      child: Text(type.label),
                    ),
                ],
                onChanged: (RoomType? value) =>
                    setState(() => _roomType = value),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Number of people', style: theme.textTheme.labelLarge),
              const SizedBox(height: AppSpacing.xs),
              DropdownButtonFormField<int>(
                initialValue: _peopleCount,
                decoration: const InputDecoration(),
                hint: const Text('Any'),
                items: [
                  for (int count = 1; count <= 5; count++)
                    DropdownMenuItem<int>(
                      value: count,
                      child: Text(count == 1 ? '1 person' : '$count people'),
                    ),
                ],
                onChanged: (int? value) => setState(() => _peopleCount = value),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: OutlinedButton(
                      onPressed: _clear,
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        foregroundColor: Colors.white,
                        side: BorderSide.none,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    flex: 3,
                    child: FilledButton(
                      onPressed: _apply,
                      child: const Text('Apply filters'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
