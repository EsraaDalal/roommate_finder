import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:rommate_finder/core/config/di.dart';

import '../../../../core/domain/entities/listing_entity.dart';

import '../../../../core/resources/app_spacing.dart';
import '../../../../core/widgets/section_header.dart';

import '../../../discovery/presentation/widgets/listing_card_widgets.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/application_entity.dart';
import '../bloc/application_bloc.dart';
import '../bloc/application_event.dart';
import '../bloc/application_state.dart';
import '../widgets/application_card.dart';

/// Applications received for one listing.
///
/// There is no Figma frame for incoming applications, so this reuses the
/// approved My Applications card, chips, and buttons rather than introducing a
/// new visual language.
class ReceivedApplicationsPage extends StatefulWidget {
  const ReceivedApplicationsPage({super.key, required this.listing});

  final ListingEntity listing;

  @override
  State<ReceivedApplicationsPage> createState() =>
      _ReceivedApplicationsPageState();
}

class _ReceivedApplicationsPageState extends State<ReceivedApplicationsPage> {
  @override
  void initState() {
    super.initState();
    // Load received applications for this listing owner
    context.read<ApplicationBloc>().add(const WatchReceivedApplications());
  }

  Future<void> _confirm(
    BuildContext context,
    ApplicationEntity application,
    ApplicationStatus status,
  ) async {
    final isAccept = status == ApplicationStatus.accepted;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            isAccept ? 'Accept this application?' : 'Reject this application?',
          ),
          content: Text(
            isAccept
                ? 'The applicant will be notified that you accepted them.'
                : 'The applicant will be notified that you passed.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Go back'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: isAccept
                    ? Theme.of(dialogContext).colorScheme.secondary
                    : Theme.of(dialogContext).colorScheme.error,
              ),
              child: Text(isAccept ? 'Accept' : 'Reject'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) return;

    final ownerId = getIt<firebase.FirebaseAuth>().currentUser?.uid;

    if (ownerId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to manage applications.')),
      );
      return;
    }

    context.read<ApplicationBloc>().add(
      SetApplicationStatus(
        applicationId: application.id,
        ownerId: ownerId,
        newStatus: status,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Applications'),
      ),
      body: SafeArea(
        child: BlocConsumer<ApplicationBloc, ApplicationState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is ApplicationLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final applications = state is ApplicationLoaded
                ? state.applications
                      .where(
                        (application) =>
                            application.listingId == widget.listing.id,
                      )
                      .toList()
                : <ApplicationEntity>[];
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pageHorizontal,
                      AppSpacing.md,
                      AppSpacing.pageHorizontal,
                      AppSpacing.md,
                    ),
                    child: SectionHeader(
                      title: 'Received applications',
                      subtitle:
                          '${widget.listing.title} · '
                          '${applications.length} received',
                    ),
                  ),
                ),
                if (applications.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyResults(
                      title: 'No applications yet',
                      message: 'Applicants for this space will appear here.',
                    ),
                  )
                else
                  SliverList.separated(
                    itemCount: applications.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (BuildContext context, int index) {
                      final application = applications[index];

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.pageHorizontal,
                        ),
                        child: ApplicationCard(
                          application: application,
                          listing: widget.listing,
                          subtitle:
                              'Move-in: ${formatMoveInDate(application.requestedMoveIn)}',
                          leading: _ApplicantRow(
                            message: application.message.isEmpty
                                ? 'No message'
                                : application.message,
                          ),
                          actions: application.status.isActionable
                              ? [
                                  ApplicationActionButton(
                                    label: 'Accept',
                                    icon: Icons.check_rounded,
                                    emphasized: true,
                                    onTap: () => _confirm(
                                      context,
                                      application,
                                      ApplicationStatus.accepted,
                                    ),
                                  ),
                                  ApplicationActionButton(
                                    label: 'Reject',
                                    icon: Icons.close_rounded,
                                    onTap: () => _confirm(
                                      context,
                                      application,
                                      ApplicationStatus.rejected,
                                    ),
                                  ),
                                ]
                              : const <Widget>[],
                        ),
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ApplicantRow extends StatelessWidget {
  const _ApplicantRow({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            message,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
