import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/chat_message_entity.dart';
import '../repositories/chat_repository.dart';

class GetMessagesUseCase {
  final ChatRepository repository;

  GetMessagesUseCase({required this.repository});

  Stream<Either<Failure, List<ChatMessageEntity>>> call(
    String conversationId,
  ) {
    return repository.getMessages(conversationId);
  }
}