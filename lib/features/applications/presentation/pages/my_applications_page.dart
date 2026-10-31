import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

import 'package:rommate_finder/core/config/di.dart';

import '../../../../core/resources/app_spacing.dart';
import '../../../../core/widgets/section_header.dart';
import '../../../../core/domain/entities/listing_entity.dart';
import '../../../discovery/presentation/pages/listing_details_page.dart';
import '../../../discovery/presentation/widgets/listing_card_widgets.dart';
import '../../domain/entities/application_entity.dart';
import '../bloc/application_bloc.dart';
import '../bloc/application_event.dart';
import '../bloc/application_state.dart';
import '../widgets/application_card.dart';


class MyApplicationsPage extends StatefulWidget {
  const MyApplicationsPage({super.key});

  @override
  State<MyApplicationsPage> createState() => _MyApplicationsPageState();
}

class _MyApplicationsPageState extends State<MyApplicationsPage> {
  List<ApplicationEntity> _applications = [];
  bool _hasLoadedApplications = false;
  bool _openingListing = false;
  String? _listingToOpenId;

  final Map<String, ListingEntity> _listingsById = {};

  @override
  void initState() {
    super.initState();
    context.read<ApplicationBloc>().add(const WatchMyApplications());
  }

  void _openListing(BuildContext context, ApplicationEntity application) {
    final listing = _listingsById[application.listingId];

    if (listing != null) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ListingDetailsPage(listing: listing),
        ),
      );
      return;
    }

    setState(() {
      _openingListing = true;
      _listingToOpenId = application.listingId;
    });

    context.read<ApplicationBloc>().add(
      LoadApplicationListing(listingId: application.listingId),
    );
  }

  Future<void> _confirmCancel(
    BuildContext context,
    ApplicationEntity application,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel this application?'),
        content: const Text(
          'The owner will no longer see this request. '
          'You can apply again later if the space is still open.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep it'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            child: const Text('Cancel application'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    final applicantId = getIt<firebase.FirebaseAuth>().currentUser?.uid;

    if (applicantId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not signed in')));
      return;
    }

    context.read<ApplicationBloc>().add(
      CancelApplication(
        applicationId: application.id,
        applicantId: applicantId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ApplicationBloc, ApplicationState>(
      listener: (context, state) {
        if (state is ApplicationLoaded) {
          setState(() {
            _applications = state.applications;
            _hasLoadedApplications = true;
          });

          for (final application in state.applications) {
            final listingId = application.listingId;

            if (!_listingsById.containsKey(listingId)) {
              context.read<ApplicationBloc>().add(
                LoadApplicationListing(listingId: listingId),
              );
            }
          }
        }

        if (state is ApplicationListingLoaded) {
          setState(() {
            _listingsById[state.listing.id] = state.listing;
          });

      
          if (_openingListing && _listingToOpenId == state.listing.id) {
            _openingListing = false;
            _listingToOpenId = null;

            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ListingDetailsPage(listing: state.listing),
              ),
            );
          }
        }

        if (state is ApplicationFailure) {
          setState(() {
            _openingListing = false;
            _listingToOpenId = null;
          });

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }

      },

      builder: (context, state) {
        if (!_hasLoadedApplications && state is ApplicationLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final applications = state is ApplicationLoaded
            ? state.applications
            : _applications;

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: 'Back',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.pageHorizontal,
                          AppSpacing.md,
                          AppSpacing.pageHorizontal,
                          AppSpacing.md,
                        ),
                        child: const SectionHeader(
                          title: 'Your applications',
                          subtitle: 'Track your housing requests in one place.',
                        ),
                      ),
                    ),
                    if (applications.isEmpty)
                      const SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyResults(
                          title: 'No applications yet',
                          message:
                              'Apply to a place you like and it will show up here.',
                        ),
                      )
                    else
                      SliverList.separated(
                        itemCount: applications.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final application = applications[index];
                          final listing = _listingsById[application.listingId];

                          if (listing == null) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.pageHorizontal,
                            ),
                            child: ApplicationCard(
                              application: application,
                              listing: listing,
                              subtitle:
                                  'Move-in: ${formatMoveInDate(application.requestedMoveIn)}\nnote : ${application.message}',
                              actions: [
                                ApplicationActionButton(
                                  label: 'Open listing',
                                  onTap: () =>
                                      _openListing(context, application),
                                ),
                                if (application.status.isCancellable)
                                  ApplicationActionButton(
                                    label: 'Cancel',
                                    onTap: () =>
                                        _confirmCancel(context, application),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
                if (_openingListing)
                  const Positioned.fill(
                    child: ColoredBox(
                      color: Color(0x33000000),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
