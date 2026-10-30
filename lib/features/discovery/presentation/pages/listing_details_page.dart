import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/config/di.dart';
import '../../../../core/resources/app_colors.dart';
import '../../../../core/resources/app_spacing.dart';

import '../../../applications/presentation/widgets/apply_for_housing_sheet.dart';
import '../../../chat/domain/entities/conversation_entity.dart';
import '../../../chat/domain/usecases/get_or_create_conversation_usecase.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../../../core/domain/entities/listing_entity.dart';

import '../widgets/listing_card_widgets.dart';

/// Listing Details.
///
/// Combines `detiles_page.png` (hero, title, price, facts, about) with
/// `continue_detiles_page.png` (roommates and host) into one scrollable
/// screen.
///
/// The Contact and Apply for housing buttons are present to match the design;
/// the application workflow is out of scope for this stage, so they are
/// inactive.
class ListingDetailsPage extends StatefulWidget {
  const ListingDetailsPage({super.key, required this.listing});

  final ListingEntity listing;

  @override
  State<ListingDetailsPage> createState() => _ListingDetailsPageState();
}

class _ListingDetailsPageState extends State<ListingDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final ListingEntity listing = widget.listing;
    final ThemeData theme = Theme.of(context);

    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    final isOwner = currentUserId != null && currentUserId == listing.ownerId;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 280,
                backgroundColor: theme.colorScheme.surface,
                surfaceTintColor: Colors.transparent,
                leading: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xxs),
                  child: _CircleAction(
                    icon: Icons.arrow_back_rounded,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),

                flexibleSpace: FlexibleSpaceBar(
                  background: _PhotoGallery(photoUrls: listing.photoUrls),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(AppRadius.xl),
                    ),
                  ),

                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pageHorizontal,
                    AppSpacing.lg,
                    AppSpacing.pageHorizontal,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatusChip(label: listing.roomType.label),
                      const SizedBox(height: AppSpacing.sm),
                      Text(listing.title, style: theme.textTheme.displayMedium),
                      const SizedBox(height: AppSpacing.xs),
                      LocationLine(area: listing.area),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '\$${listing.priceMonthly}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.xxs),
                          Text('/month', style: theme.textTheme.bodyMedium),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _FactsGrid(listing: listing),
                      const SizedBox(height: AppSpacing.lg),
                      const Divider(),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'About this home',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        listing.description,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text('House rules', style: theme.textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.xs),
                      ...listing.rules.map(
                        (String rule) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.xxs,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 6),
                                child: Icon(
                                  Icons.circle,
                                  size: 5,
                                  color: AppColors.avatarGreen,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  rule,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                   
if (listing.roommates.isNotEmpty) ...[
  const SizedBox(height: AppSpacing.lg),
  Text(
    'Meet your roommates (${listing.roommates.length})',
    style: theme.textTheme.titleLarge,
  ),
  const SizedBox(height: AppSpacing.xs),
  ...listing.roommates.map(
    (roommate) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: _PersonRow(
        initials: roommate.initials,
        name: roommate.name,
        subtitle: roommate.tagline,
        showChevron: true,
      ),
    ),
  ),
],

                      const SizedBox(height: AppSpacing.lg),
                      Text('Hosted by', style: theme.textTheme.titleLarge),
                      const SizedBox(height: AppSpacing.xs),
                      _PersonRow(
                        initials: listing.host.initials,
                        name: listing.host.name,
                        subtitle: listing.host.responseTime,
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: !isOwner
                ? _BottomActionBar(listing: listing)
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  const _CircleAction({
    required this.icon,
    required this.onPressed,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            icon,
            size: 20,
            color: iconColor ?? Theme.of(context).textTheme.titleMedium?.color,
          ),
        ),
      ),
    );
  }
}

/// Horizontally swipeable photo gallery shown in the details app bar.
///
/// Falls back to the shared [ListingPhoto] placeholder when the listing has
/// no uploaded photos, and for any individual photo that cannot be loaded.
class _PhotoGallery extends StatefulWidget {
  const _PhotoGallery({required this.photoUrls});

  final List<String> photoUrls;

  @override
  State<_PhotoGallery> createState() => _PhotoGalleryState();
}

class _PhotoGalleryState extends State<_PhotoGallery> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  @override
  void didUpdateWidget(covariant _PhotoGallery oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Keep the indicator in range when the available photos change.
    if (_currentIndex > widget.photoUrls.length - 1) {
      _currentIndex = widget.photoUrls.isEmpty
          ? 0
          : widget.photoUrls.length - 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> photoUrls = widget.photoUrls;

    if (photoUrls.isEmpty) {
      return const ListingPhoto(borderRadius: 0, iconSize: 48);
    }

    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          controller: _controller,
          itemCount: photoUrls.length,
          onPageChanged: (int index) {
            setState(() => _currentIndex = index);
          },
          itemBuilder: (BuildContext context, int index) {
            return Image.network(
              photoUrls[index],
              fit: BoxFit.cover,
              errorBuilder:
                  (BuildContext context, Object error, StackTrace? stackTrace) {
                    return const ListingPhoto(borderRadius: 0, iconSize: 48);
                  },
              loadingBuilder:
                  (
                    BuildContext context,
                    Widget child,
                    ImageChunkEvent? loadingProgress,
                  ) {
                    if (loadingProgress == null) {
                      return child;
                    }

                    return const Center(child: CircularProgressIndicator());
                  },
            );
          },
        ),
        Positioned(
          right: AppSpacing.md,
          bottom: AppSpacing.md,
          child: _PhotoCounterBadge(
            current: _currentIndex + 1,
            total: photoUrls.length,
          ),
        ),
      ],
    );
  }
}

class _PhotoCounterBadge extends StatelessWidget {
  const _PhotoCounterBadge({required this.current, required this.total});

  /// Position of the visible photo, starting at one.
  final int current;

  /// Number of photos available for the listing.
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        '$current / $total',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// "3 people / live here", "1 space / remaining", "Furnished".
class _FactsGrid extends StatelessWidget {
  const _FactsGrid({required this.listing});

  final ListingEntity listing;

  @override
  Widget build(BuildContext context) {
    final List<Widget> facts = [
      _FactTile(
        icon: Icons.people_alt_rounded,
        value: '${listing.peopleCount} people',
        label: 'live here',
      ),
      _FactTile(
        icon: Icons.home_rounded,
        value:
            '${listing.spacesRemaining} space'
            '${listing.spacesRemaining == 1 ? '' : 's'}',
        label: 'remaining',
      ),
      _FactTile(
        icon: Icons.chair_rounded,
        value: listing.furnishedLabel,
        label: 'status',
      ),
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: facts
          .map(
            (Widget fact) => SizedBox(
              width:
                  (MediaQuery.sizeOf(context).width -
                      AppSpacing.pageHorizontal * 2 -
                      AppSpacing.sm) /
                  2,
              child: fact,
            ),
          )
          .toList(),
    );
  }
}

class _FactTile extends StatelessWidget {
  const _FactTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.avatarGreen),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                Text(label, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({
    required this.initials,
    required this.name,
    required this.subtitle,
    this.showChevron = false,
  });

  final String initials;
  final String name;
  final String subtitle;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.avatarGreen,
            child: Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: theme.textTheme.titleMedium),
                Text(subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          if (showChevron)
            Icon(
              Icons.chevron_right_rounded,
              color: theme.textTheme.bodySmall?.color,
            ),
        ],
      ),
    );
  }
}

/// Sticky "Contact" / "Apply for housing" bar.
class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({required this.listing});

  final ListingEntity listing;

  /// Opens the one-to-one conversation with the listing owner.
  static Future<void> openConversation(
    BuildContext context,
    ListingEntity listing,
  ) async {
    final firebaseAuth = getIt<FirebaseAuth>();
    final currentUserId = firebaseAuth.currentUser?.uid;

    if (currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in to contact the listing owner.'),
        ),
      );
      return;
    }

    final participantId = listing.ownerId;

    // لا تسمح للمستخدم بفتح محادثة مع نفسه.
    if (participantId == currentUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This is your own listing.')),
      );
      return;
    }

    try {
      final result = await getIt<GetOrCreateConversationUseCase>()(
        otherUserId: participantId,
        listingId: listing.id,
      );

      if (!context.mounted) return;

      result.fold(
        (failure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(failure.message)));
        },
        (conversationId) {
          final conversation = ConversationEntity(
            id: conversationId,
            participantIds: [currentUserId, participantId],
            listingId: listing.id,
            lastMessage: null,
            lastMessageAt: null,
            createdAt: DateTime.now(),
          );

          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ChatPage(conversation: conversation),
            ),
          );
        },
      );
    } catch (error, stackTrace) {
      debugPrint('OPEN CONVERSATION ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open conversation: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pageHorizontal,
        AppSpacing.sm,
        AppSpacing.pageHorizontal,
        AppSpacing.sm + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          OutlinedButton.icon(
            onPressed: () =>
                _BottomActionBar.openConversation(context, listing),
            icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
            label: const Text('Contact'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              backgroundColor: AppColors.primaryTint,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: () => showApplyForHousingSheet(context, listing),
              child: const Text('Apply for housing'),
            ),
          ),
        ],
      ),
    );
  }
}
