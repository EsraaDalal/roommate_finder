import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/di.dart';
import '../../../../core/domain/entities/listing_entity.dart';
import '../../../../core/resources/app_spacing.dart';
import '../../../applications/presentation/bloc/application_bloc.dart';
import '../../../applications/presentation/pages/my_applications_page.dart';
import '../../../applications/presentation/pages/received_applications_page.dart';
import '../../../chat/domain/entities/conversation_entity.dart';
import '../../../chat/domain/usecases/get_conversation_by_id_usecase.dart';
import '../../../chat/presentation/pages/chat_page.dart';
import '../../../discovery/presentation/widgets/listing_card_widgets.dart';
import '../../../hosting/domain/usecases/get_listing_by_id_usecase.dart';
import '../../domain/entities/notification_entity.dart';
import '../bloc/notification_bloc.dart';
import '../bloc/notification_event.dart';
import '../bloc/notification_state.dart';
import '../utils/notification_timestamp_formatter.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = getIt<FirebaseAuth>().currentUser;

    // If NotificationBloc is already provided by ancestor (e.g. root MultiBlocProvider),
    // use it; otherwise provide a new instance.
    return BlocProvider<NotificationBloc>(
      create: (ctx) {
        final bloc = getIt<NotificationBloc>();
        if (currentUser != null) {
          bloc.add(WatchNotificationsEvent(currentUser.uid));
        }
        return bloc;
      },
      child: const _NotificationsPageView(),
    );
  }
}

class _NotificationsPageView extends StatelessWidget {
  const _NotificationsPageView();

  Future<void> _open(
    BuildContext context,
    NotificationEntity notification,
  ) async {
    // Mark as read
    context
        .read<NotificationBloc>()
        .add(MarkNotificationAsReadEvent(notification.id));

    // Handle new message -> open ChatPage
    if (notification.type == NotificationType.newMessage &&
        notification.conversationId != null) {
      try {
        final getConversationUseCase = getIt<GetConversationByIdUseCase>();
        final result =
            await getConversationUseCase(notification.conversationId!);

        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not open chat: ${failure.message}')),
            );
          },
          (ConversationEntity conversation) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => ChatPage(conversation: conversation),
              ),
            );
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(notification.title)),
        );
      }
      return;
    }

    // Handle new application -> open ReceivedApplicationsPage
    if (notification.type == NotificationType.newApplication &&
        notification.listingId != null) {
      try {
        final getListingUseCase = getIt<GetListingByIdUseCase>();
        final result = await getListingUseCase(listingId: notification.listingId!);

        result.fold(
          (failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Could not open listing: ${failure.message}')),
            );
          },
          (ListingEntity listing) {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider(
                  create: (_) => getIt<ApplicationBloc>(),
                  child: ReceivedApplicationsPage(listing: listing),
                ),
              ),
            );
          },
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(notification.title)),
        );
      }
      return;
    }

    // Handle application accepted / rejected -> open MyApplicationsPage
    if (notification.type == NotificationType.applicationAccepted ||
        notification.type == NotificationType.applicationRejected) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => BlocProvider(
            create: (_) => getIt<ApplicationBloc>(),
            child: const MyApplicationsPage(),
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(notification.title)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = getIt<FirebaseAuth>().currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Notifications'),
        actions: [
          if (currentUserId != null)
            TextButton(
              onPressed: () {
                context
                    .read<NotificationBloc>()
                    .add(MarkAllNotificationsAsReadEvent(currentUserId));
              },
              child: const Text('Mark read'),
            ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<NotificationBloc, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is NotificationErrorState) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              );
            }

            if (state is NotificationLoaded) {
              final notifications = state.notifications;

              if (notifications.isEmpty) {
                return const EmptyResults(
                  title: 'No notifications yet',
                  message: 'Activity on your homes will show up here.',
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                itemCount: notifications.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, indent: 64),
                itemBuilder: (BuildContext context, int index) {
                  final notification = notifications[index];
                  return _NotificationTile(
                    notification: notification,
                    onTap: () => _open(context, notification),
                  );
                },
              );
            }

            return const EmptyResults(
              title: 'No notifications yet',
              message: 'Activity on your homes will show up here.',
            );
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final NotificationEntity notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final isUnread = !notification.isRead;

    return Material(
      color: isUnread
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.15)
          : theme.colorScheme.surface,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isUnread
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(
                  _iconFor(notification.type),
                  size: 20,
                  color: isUnread
                      ? theme.colorScheme.primary
                      : theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight:
                                  isUnread ? FontWeight.bold : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(left: 4),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      notification.body,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isUnread
                            ? theme.textTheme.bodyMedium?.color
                            : theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                formatNotificationTimestamp(notification.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconFor(NotificationType type) {
    switch (type) {
      case NotificationType.newApplication:
        return Icons.calendar_today_rounded;
      case NotificationType.applicationAccepted:
        return Icons.check_rounded;
      case NotificationType.applicationRejected:
        return Icons.close_rounded;
      case NotificationType.newMessage:
        return Icons.chat_bubble_rounded;
    }
  }
}
