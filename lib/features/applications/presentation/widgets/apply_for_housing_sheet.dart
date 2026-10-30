import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/resources/app_spacing.dart';

import '../../../../core/domain/entities/listing_entity.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:get_it/get_it.dart';


import '../bloc/application_bloc.dart';
import '../bloc/application_event.dart';
import '../bloc/application_state.dart';
import 'application_block.dart';

/// Opens the "Apply for housing" sheet.
///
/// Mirrors `ai/design/apply_hosting_bottom_sheet.png`.

Future<void> showApplyForHousingSheet(
  BuildContext context,
  ListingEntity listing,
) {
  final applicationBloc = context.read<ApplicationBloc>();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      return BlocProvider.value(
        value: applicationBloc,
        child: _ApplyForHousingSheet(listing: listing),
      );
    },
  );
}

class _ApplyForHousingSheet extends StatefulWidget {
  const _ApplyForHousingSheet({required this.listing});

  final ListingEntity listing;

  @override
  State<_ApplyForHousingSheet> createState() => _ApplyForHousingSheetState();
}

class _ApplyForHousingSheetState extends State<_ApplyForHousingSheet> {
  final TextEditingController _messageController = TextEditingController();

  DateTime? _moveInDate;
  bool _submitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String? get _currentUserId =>
      GetIt.instance<firebase.FirebaseAuth>().currentUser?.uid;

  bool get _isOwnListing {
    final userId = _currentUserId;
    return userId != null && widget.listing.ownerId == userId;
  }

  ApplicationBlock? get _blocked {
    if (_currentUserId == null) return null;

    if (_isOwnListing) {
      return ApplicationBlock.ownListing;
    }

    if (!widget.listing.isPublished) {
      return ApplicationBlock.unpublished;
    }

    return null;
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _moveInDate ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365 * 2)),
      helpText: 'Requested move-in date',
    );

    if (picked != null) {
      setState(() => _moveInDate = picked);
    }
  }

  void _submit() {
    final userId = _currentUserId;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to apply for housing.')),
      );
      return;
    }

    if (_moveInDate == null || _blocked != null || _submitting) {
      return;
    }

    setState(() => _submitting = true);

    context.read<ApplicationBloc>().add(
      SubmitApplication(
        listingId: widget.listing.id,
        applicantId: userId,
        requestedMoveIn: _moveInDate!,
        message: _messageController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final ApplicationBlock? blocked = _blocked;
    final bool canSubmit = _moveInDate != null && blocked == null;

    return BlocListener<ApplicationBloc, ApplicationState>(
    listener: (context, state) {
    if (!mounted) return;

    if (state is ApplicationOperationSuccess) {
      setState(() => _submitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application submitted successfully.'),
        ),
      );

      Navigator.of(context).pop();
    } else if (state is ApplicationFailure) {
      setState(() => _submitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
        ),
      );
    }
  },
      child: SafeArea(
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
                    Text(
                      'APPLY FOR HOUSING',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.secondary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'When would you move in?',
                  style: theme.textTheme.displayMedium,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (blocked != null) ...[
                  _BlockedNotice(block: blocked),
                  const SizedBox(height: AppSpacing.lg),
                ] else ...[
                  Text(
                    'Requested move-in date',
                    style: theme.textTheme.labelLarge,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _DateField(date: _moveInDate, onTap: _pickDate),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    children: [
                      Text('Short message', style: theme.textTheme.labelLarge),
                      const Spacer(),
                      Text('Optional', style: theme.textTheme.bodySmall),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextField(
                    controller: _messageController,
                    minLines: 3,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Introduce yourself to the owner…',
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: canSubmit && !_submitting ? _submit : null,
                    child: _submitting
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Submitting application...'),
                            ],
                          )
                        : const Text('Submit application'),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: Text(
                    _footerText(blocked),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _footerText(ApplicationBlock? blocked) {
    switch (blocked) {
      case null:
        return 'Your application will be sent to the listing owner '
            'with a Pending status.';
      case ApplicationBlock.ownListing:
        return 'This is your own listing.';
      case ApplicationBlock.unpublished:
        return 'This listing is still a draft and is not open yet.';
      case ApplicationBlock.duplicate:
        return 'You already have an active application for this place.';
    }
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.date, required this.onTap});

  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String text = date == null
        ? 'mm/dd/yyyy'
        : '${date!.month.toString().padLeft(2, '0')}/'
              '${date!.day.toString().padLeft(2, '0')}/${date!.year}';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: InputDecorator(
        decoration: const InputDecoration(
          suffixIcon: Icon(Icons.calendar_today_rounded, size: 18),
        ),
        child: Text(
          text,
          style: date == null
              ? theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color,
                )
              : theme.textTheme.bodyLarge,
        ),
      ),
    );
  }
}

class _BlockedNotice extends StatelessWidget {
  const _BlockedNotice({required this.block});

  final ApplicationBlock block;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: theme.colorScheme.secondary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              block == ApplicationBlock.ownListing
                  ? 'You cannot apply to your own listing.'
                  : block == ApplicationBlock.unpublished
                  ? 'This listing is a draft and is not open for '
                        'applications yet.'
                  : 'You already have an active application for this place.',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
