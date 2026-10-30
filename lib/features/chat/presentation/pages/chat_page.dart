import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/config/di.dart';
import '../../../../core/resources/app_colors.dart';
import '../../../../core/resources/app_spacing.dart';

import '../../../discovery/presentation/widgets/listing_card_widgets.dart';
import '../utils/chat_timestamp_formatter.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/conversation_entity.dart';
import '../bloc/chat_bloc.dart';
import '../bloc/chat_event.dart';
import '../bloc/chat_state.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key, required this.conversation});

  final ConversationEntity conversation;

  @override
  Widget build(BuildContext context) {
    final currentUserId = getIt<FirebaseAuth>().currentUser?.uid;

    final otherUserId = currentUserId == null
        ? null
        : conversation.otherParticipant(currentUserId);

    return BlocProvider(
      create: (_) {
        final bloc = getIt<ChatBloc>();

        bloc.add(WatchMessagesEvent(conversation.id));

        if (otherUserId != null) {
          bloc.add(LoadUserByUidEvent(otherUserId));
        }

        return bloc;
      },
      child: _ChatPageContent(conversation: conversation),
    );
  }
}

class _ChatPageContent extends StatefulWidget {
  const _ChatPageContent({required this.conversation});

  final ConversationEntity conversation;

  @override
  State<_ChatPageContent> createState() => _ChatPageContentState();
}

class _ChatPageContentState extends State<_ChatPageContent> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  String? get _currentUserId => getIt<FirebaseAuth>().currentUser?.uid;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to send messages.')),
      );
      return;
    }

    context.read<ChatBloc>().add(
      SendMessageEvent(conversationId: widget.conversation.id, text: text),
    );

    _controller.clear();
    _focusNode.requestFocus();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = _currentUserId;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: BlocBuilder<ChatBloc, ChatState>(
          builder: (context, state) {
             final bloc = context.read<ChatBloc>();

    final participant = state is ChatParticipantLoaded
        ? state.user
        : state is MessagesLoaded
            ? state.participant
            : bloc.participant;

    final name = participant?.fullName.trim();
    final hasName = name != null && name.isNotEmpty;

    final initials = hasName
        ? name
            .split(RegExp(r'\s+'))
            .take(2)
            .map((part) => part[0].toUpperCase())
            .join()
        : '?';
            return Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor:
                    AppColors.avatarGreen,
                  child: Text(
                   initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        participant?.fullName ?? 'Conversation',
                        style: theme.textTheme.titleMedium,
                      ),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: BlocConsumer<ChatBloc, ChatState>(
              buildWhen: (previous, current) {
                return current is ChatInitial ||
                    current is ChatLoading ||
                    current is ChatError ||
                    current is MessagesLoaded;
              },

              listener: (context, state) {
                if (state is ChatError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }

                if (state is MessagesLoaded &&
                    state.conversationId == widget.conversation.id) {
                  _scrollToBottom();
                }
              },

              builder: (context, state) {
                if (state is ChatLoading || state is ChatInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ChatError) {
                  return EmptyResults(
                    title: 'Could not load messages',
                    message: state.message,
                  );
                }

                if (state is MessagesLoaded &&
                    state.conversationId == widget.conversation.id) {
                  final messages = state.messages;

                  if (messages.isEmpty) {
                    return const EmptyResults(
                      title: 'No messages yet',
                      message: 'Say hello to start the conversation.',
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.sm,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final ChatMessageEntity message = messages[index];

                      return _MessageBubble(
                        message: message,
                        isMine: message.senderId == currentUserId,
                        showDaySeparator:
                            index == 0 ||
                            !_isSameDay(
                              messages[index - 1].sentAt,
                              message.sentAt,
                            ),
                      );
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
          _Composer(
            controller: _controller,
            focusNode: _focusNode,
            onSend: _send,
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.showDaySeparator,
  });

  final ChatMessageEntity message;
  final bool isMine;
  final bool showDaySeparator;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showDaySeparator)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Text(
              _dayLabel(message.sentAt),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
            ),
          ),
        Align(
          alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.72,
            ),
            child: Container(
              margin: const EdgeInsets.only(bottom: AppSpacing.xs),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isMine ? AppColors.primary : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                message.text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isMine
                      ? Colors.white
                      : theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
        ),
        Align(
          alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Text(
              formatChatTimestamp(message.sentAt),
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
            ),
          ),
        ),
      ],
    );
  }

  String _dayLabel(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today';
    }

    final yesterday = now.subtract(const Duration(days: 1));
    if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      return 'Yesterday';
    }

    return '${date.day}/${date.month}/${date.year}';
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.xs,
          AppSpacing.md,
          AppSpacing.sm,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                minLines: 1,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Write a message…',
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Material(
              color: AppColors.primary,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onSend,
                customBorder: const CircleBorder(),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
