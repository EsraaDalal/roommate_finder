
import 'package:dartz/dartz.dart';

import '../../../../core/domain/entities/user_entity.dart';
import '../../../../core/errors/failure.dart';
import '../entities/chat_message_entity.dart';
import '../entities/conversation_entity.dart';

abstract class ChatRepository {
  Stream<Either<Failure, List<ConversationEntity>>>
      getConversations();

  Stream<Either<Failure, List<ChatMessageEntity>>> getMessages(
    String conversationId,
  );

  Future<Either<Failure, String>> getOrCreateConversation({
    required String otherUserId,
    String? listingId,
  });

  Future<Either<Failure, ConversationEntity>> getConversationById(
    String conversationId,
  );

  Future<Either<Failure, Unit>> sendMessage({
    required String conversationId,
    required String text,
  });

    Future<Either<Failure, UserEntity>> getUserByUid(String uid);
}
