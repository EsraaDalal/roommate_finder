import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/chat_repository.dart';

class SendMessageUseCase {
  final ChatRepository repository;

  SendMessageUseCase({required this.repository});

  Future<Either<Failure, Unit>> call({
    required String conversationId,
    required String text,
  }) {
    return repository.sendMessage(
      conversationId: conversationId,
      text: text,
    );
  }
}