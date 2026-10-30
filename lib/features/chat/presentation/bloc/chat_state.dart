import '../../../../core/domain/entities/user_entity.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/conversation_entity.dart';

abstract class ChatState {
  const ChatState();
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class ConversationsLoaded extends ChatState {
  final List<ConversationEntity> conversations;
  final Map<String, UserEntity> usersByUid;

  const ConversationsLoaded(
    this.conversations, {
    this.usersByUid = const {},
  });
}

class MessagesLoaded extends ChatState {
  final String conversationId;
  final List<ChatMessageEntity> messages;
  final UserEntity? participant;

  const MessagesLoaded({
    required this.conversationId,
    required this.messages,
    this.participant,
  });
}

class ConversationOpened extends ChatState {
  final String conversationId;

  const ConversationOpened(this.conversationId);
}

class ChatActionSuccess extends ChatState {
  const ChatActionSuccess();
}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);
}

class ChatParticipantLoading extends ChatState {
  const ChatParticipantLoading();
}

class ChatParticipantLoaded extends ChatState {
  final UserEntity user;

  const ChatParticipantLoaded(this.user);
}

class ChatParticipantError extends ChatState {
  final String message;

  const ChatParticipantError(this.message);
}