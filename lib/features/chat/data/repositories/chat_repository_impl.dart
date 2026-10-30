
import 'dart:async';

import 'package:dartz/dartz.dart';

import 'package:rommate_finder/core/domain/entities/user_entity.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/chat_message_entity.dart';
import '../../domain/entities/conversation_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../datasource/chat_remote_data_source.dart';


class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;

  ChatRepositoryImpl({
    required this.remoteDataSource,
  });

  Failure _mapError(Object error) {
    if (error is StateError &&
        error.message == 'User is not authenticated.') {
      return const AuthFailure();
    }

    if (error is ArgumentError) {
      return ServerFailure(message: error.message.toString());
    }

    return const ServerFailure();
  }

  @override
  Stream<Either<Failure, List<ConversationEntity>>>
      getConversations() {
    return remoteDataSource.getConversations().transform(
      StreamTransformer.fromHandlers(
        handleData: (models, sink) {
          sink.add(
            Right<Failure, List<ConversationEntity>>(
              models
                  .map<ConversationEntity>((model) => model)
                  .toList(),
            ),
          );
        },
        handleError: (error, stackTrace, sink) {
          sink.add(Left(_mapError(error)));
        },
      ),
    );
  }

  @override
  Stream<Either<Failure, List<ChatMessageEntity>>> getMessages(
    String conversationId,
  ) {
    return remoteDataSource.getMessages(conversationId).transform(
      StreamTransformer.fromHandlers(
        handleData: (models, sink) {
          sink.add(
            Right<Failure, List<ChatMessageEntity>>(
              models
                  .map<ChatMessageEntity>((model) => model)
                  .toList(),
            ),
          );
        },
        handleError: (error, stackTrace, sink) {
          sink.add(Left(_mapError(error)));
        },
      ),
    );
  }

@override
Future<Either<Failure, String>> getOrCreateConversation({
  required String otherUserId,
  String? listingId,
}) async {
  try {
    final conversationId =
        await remoteDataSource.getOrCreateConversation(
      otherUserId: otherUserId,
      listingId: listingId,
    );

    return Right(conversationId);
  } catch (error) {


    return Left(
      ServerFailure(message: error.toString()),
    );
  }
}

  @override
  Future<Either<Failure, ConversationEntity>> getConversationById(
    String conversationId,
  ) async {
    try {
      final conversation =
          await remoteDataSource.getConversationById(conversationId);

      return Right<Failure, ConversationEntity>(conversation);
    } catch (error) {
      return Left<Failure, ConversationEntity>(_mapError(error));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    try {
      await remoteDataSource.sendMessage(
        conversationId: conversationId,
        text: text,
      );

      return const Right(unit);
    } catch (error) {
      return Left(_mapError(error));
    }
  }

@override
Future<Either<Failure, UserEntity>> getUserByUid(
  String uid,
) async {
  try {
    final user = await remoteDataSource.getUserByUid(uid);

    return Right<Failure, UserEntity>(user);
  } catch (error) {
    return Left<Failure, UserEntity>(
      _mapError(error),
    );
  }
}
}
