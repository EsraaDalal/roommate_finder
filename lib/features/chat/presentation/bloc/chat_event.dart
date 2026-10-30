import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/conversation_entity.dart';

abstract class ChatEvent {
  const ChatEvent();
}

class WatchConversationsEvent extends ChatEvent {
  const WatchConversationsEvent();
}

class WatchMessagesEvent extends ChatEvent {
  final String conversationId;

  const WatchMessagesEvent(this.conversationId);
}

class OpenConversationEvent extends ChatEvent {
  final String otherUserId;
  final String? listingId;

  const OpenConversationEvent({
    required this.otherUserId,
    this.listingId,
  });
}

class SendMessageEvent extends ChatEvent {
  final String conversationId;
  final String text;

  const SendMessageEvent({
    required this.conversationId,
    required this.text,
  });

  
}
class LoadUserByUidEvent extends ChatEvent {
  final String uid;

  const LoadUserByUidEvent(this.uid);
}

class ConversationsUpdatedEvent extends ChatEvent {
  final List<ConversationEntity> conversations;

  const ConversationsUpdatedEvent(this.conversations);
}

class MessagesUpdatedEvent extends ChatEvent {
  final String conversationId;
  final List<ChatMessageEntity> messages;

  const MessagesUpdatedEvent({
    required this.conversationId,
    required this.messages,
  });
}

class ChatFailureEvent extends ChatEvent {
  final String message;

  const ChatFailureEvent(this.message);
}

class LoadConversationUsersEvent extends ChatEvent {
  final String currentUserId;
  final List<ConversationEntity> conversations;

  const LoadConversationUsersEvent({
    required this.currentUserId,
    required this.conversations,
  });
}