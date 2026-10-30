import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/chat_repository.dart';

class GetOrCreateConversationUseCase {
  final ChatRepository repository;

  GetOrCreateConversationUseCase({
    required this.repository,
  });

  Future<Either<Failure, String>> call({
    required String otherUserId,
    String? listingId,
  }) {
    return repository.getOrCreateConversation(
      otherUserId: otherUserId,
      listingId: listingId,
    );
  }
}