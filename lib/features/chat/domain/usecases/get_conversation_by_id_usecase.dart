import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/conversation_entity.dart';
import '../repositories/chat_repository.dart';

class GetConversationByIdUseCase {
  final ChatRepository repository;

  GetConversationByIdUseCase({required this.repository});

  Future<Either<Failure, ConversationEntity>> call(
    String conversationId,
  ) {
    return repository.getConversationById(conversationId);
  }
}
