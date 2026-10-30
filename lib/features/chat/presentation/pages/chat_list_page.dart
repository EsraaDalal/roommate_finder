import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/config/di.dart';
import '../../../../core/domain/entities/user_entity.dart';
import '../../../../core/resources/app_colors.dart';
import '../../../../core/resources/app_spacing.dart';
import '../../../../core/widgets/app_brand_mark.dart';
import '../../../../core/widgets/section_header.dart';

import '../../../discovery/presentation/widgets/listing_card_widgets.dart';
import '../utils/chat_timestamp_formatter.dart';

import '../../domain/entities/conversation_entity.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';
import 'chat_page.dart';

/// Chat list.
///
/// Mirrors `ai/design/chat_list_page.png`: brand mark, "Your conversations"
/// heading with subtitle, then one row per conversation showing the other
/// participant, the latest message, a timestamp, and an unread dot.
class ChatListPage extends StatelessWidget {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChatBloc>()..add(const WatchConversationsEvent()),
      child: Scaffold(
        body: SafeArea(
          child: BlocConsumer<ChatBloc, ChatState>(
            listener: (context, state) {
              if (state is! ConversationsLoaded) return;

              final currentUserId = getIt<FirebaseAuth>().currentUser?.uid;

              if (currentUserId == null) return;

              final needsUsers = state.conversations.any((conversation) {
                final otherId = conversation.otherParticipant(currentUserId);

                return otherId != null &&
                    !state.usersByUid.containsKey(otherId);
              });

              if (!needsUsers) return;

              context.read<ChatBloc>().add(
                LoadConversationUsersEvent(
                  currentUserId: currentUserId,
                  conversations: state.conversations,
                ),
              );
            },
            builder: (context, state) {
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const AppBrandMark(),
                          const SizedBox(height: AppSpacing.lg),
                          const SectionHeader(
                            title: 'Your conversations',
                            subtitle: 'Keep in touch with listing owners.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (state is ChatLoading || state is ChatInitial)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (state is ChatError)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyResults(
                        title: 'Could not load conversations',
                        message: state.message,
                      ),
                    )
                  else if (state is ConversationsLoaded &&
                      state.conversations.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyResults(
                        title: 'No conversations yet',
                        message: 'Messages about a listing will appear here.',
                      ),
                    )
                  else if (state is ConversationsLoaded)
                    SliverList.separated(
                      itemCount: state.conversations.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, indent: 72),
                      itemBuilder: (context, index) {
                        return _ConversationTile(
                          conversation: state.conversations[index],
                        );
                      },
                    )
                  else
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  const _ConversationTile({required this.conversation});

  final ConversationEntity conversation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = getIt<FirebaseAuth>().currentUser?.uid;

    final otherId = currentUserId == null
        ? null
        : conversation.otherParticipant(currentUserId);

    return BlocBuilder<ChatBloc, ChatState>(
      buildWhen: (previous, current) =>
        current is ConversationsLoaded,
      builder: (context, state) {
         final usersByUid = state is ConversationsLoaded
          ? state.usersByUid
          : const <String, UserEntity>{};

      final participant =
          otherId == null ? null : usersByUid[otherId];

      final name = participant?.fullName.trim();
      final hasName = name != null && name.isNotEmpty;

      final initials = hasName
          ? name
              .split(RegExp(r'\s+'))
              .take(2)
              .map((part) => part[0].toUpperCase())
              .join()
          : '?';
        return Material(
          color: theme.colorScheme.surface,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ChatPage(conversation: conversation),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pageHorizontal,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor:
                        AppColors.avatarGreen,
                    child: Text(
                     initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          participant?.fullName ?? 'Conversation',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          conversation.lastMessage ?? 'No messages yet',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    conversation.lastMessageAt == null
                        ? ''
                        : formatChatTimestamp(conversation.lastMessageAt!),
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
