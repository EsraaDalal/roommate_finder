import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/conversation_entity.dart';
import '../repositories/chat_repository.dart';

class GetConversationsUseCase {
  final ChatRepository repository;

  GetConversationsUseCase({required this.repository});

  Stream<Either<Failure, List<ConversationEntity>>> call() {
    return repository.getConversations();
  }
}