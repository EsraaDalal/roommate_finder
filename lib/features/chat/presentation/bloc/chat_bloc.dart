
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';


import '../../../../core/domain/entities/user_entity.dart';
import '../../domain/usecases/get_conversations_usecase.dart';
import '../../domain/usecases/get_messages_usecase.dart';
import '../../domain/usecases/get_or_create_conversation_usecase.dart';
import '../../domain/usecases/get_user_by_uid_usecase.dart';
import '../../domain/usecases/send_message_usecase.dart';
import 'chat_event.dart';
import 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final GetConversationsUseCase getConversationsUseCase;
  final GetMessagesUseCase getMessagesUseCase;
  final GetOrCreateConversationUseCase getOrCreateConversationUseCase;
  final SendMessageUseCase sendMessageUseCase;
final GetUserByUidUseCase getUserByUidUseCase;

UserEntity? _participant;
UserEntity? get participant => _participant;
  StreamSubscription? _conversationsSubscription;
  StreamSubscription? _messagesSubscription;

  final Map<String, UserEntity> _usersByUid = {};
final Set<String> _loadingUserIds = {};

  ChatBloc({
    required this.getConversationsUseCase,
    required this.getMessagesUseCase,
    required this.getOrCreateConversationUseCase,
    required this.sendMessageUseCase, required this.getUserByUidUseCase,
  }) : super(const ChatInitial()) {
    on<WatchConversationsEvent>(_onWatchConversations);
    on<WatchMessagesEvent>(_onWatchMessages);
    on<OpenConversationEvent>(_onOpenConversation);
    on<SendMessageEvent>(_onSendMessage);
on<LoadUserByUidEvent>(_onLoadUserByUid);
on<LoadConversationUsersEvent>(_onLoadConversationUsers);
 on<ConversationsUpdatedEvent>((event, emit) {
  emit(
    ConversationsLoaded(
      event.conversations,
      usersByUid: Map.unmodifiable(_usersByUid),
    ),
  );
});

  on<MessagesUpdatedEvent>((event, emit) {
  emit(
    MessagesLoaded(
      conversationId: event.conversationId,
      messages: event.messages,
      participant: _participant,
    ),
  );
});

    on<ChatFailureEvent>((event, emit) {
      emit(ChatError(event.message));
    });
  }



  Future<void> _onWatchConversations(
    WatchConversationsEvent event,
    Emitter<ChatState> emit,
  ) async {
    await _conversationsSubscription?.cancel();

    _conversationsSubscription = getConversationsUseCase().listen(
      (result) {
        result.fold(
          (failure) {
            if (!isClosed) {
              add(ChatFailureEvent(failure.message));
            }
          },
          (conversations) {
            if (!isClosed) {
              add(ConversationsUpdatedEvent(conversations));
            }
          },
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!isClosed) {
          add(ChatFailureEvent(error.toString()));
        }
      },
    );
  }

  Future<void> _onWatchMessages(
    WatchMessagesEvent event,
    Emitter<ChatState> emit,
  ) async {
    await _messagesSubscription?.cancel();

    _messagesSubscription = getMessagesUseCase(
      event.conversationId,
    ).listen(
      (result) {
        result.fold(
          (failure) {
            if (!isClosed) {
              add(ChatFailureEvent(failure.message));
            }
          },
          (messages) {
            if (!isClosed) {
              add(MessagesUpdatedEvent(
                conversationId: event.conversationId,
                messages: messages,
              ));
            }
          },
        );
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!isClosed) {
          add(ChatFailureEvent(error.toString()));
        }
      },
    );
  }

  Future<void> _onOpenConversation(
    OpenConversationEvent event,
    Emitter<ChatState> emit,
  ) async {
    emit(const ChatLoading());

    final result = await getOrCreateConversationUseCase(
      otherUserId: event.otherUserId,
      listingId: event.listingId,
    );

    result.fold(
      (failure) => emit(ChatError(failure.message)),
      (conversationId) => emit(ConversationOpened(conversationId)),
    );
  }

 Future<void> _onSendMessage(
  SendMessageEvent event,
  Emitter<ChatState> emit,
) async {
  if (event.text.trim().isEmpty) return;

  final result = await sendMessageUseCase(
    conversationId: event.conversationId,
    text: event.text.trim(),
  );

  result.fold(
    (failure) {
      emit(ChatError(failure.message));
    },
      (_) => emit(const ChatActionSuccess()),
    );
  }

  Future<void> _onLoadUserByUid(
  LoadUserByUidEvent event,
  Emitter<ChatState> emit,
) async {
  _participant = null;
  emit(const ChatParticipantLoading());

  final result = await getUserByUidUseCase(event.uid);

  if (emit.isDone) return;

  result.fold(
    (failure) {
      emit(ChatParticipantError(failure.message));
    },
 (user) {
  _participant = user;
  emit(ChatParticipantLoaded(user));
}
  );
}

Future<void> _onLoadConversationUsers(
  LoadConversationUsersEvent event,
  Emitter<ChatState> emit,
) async {
final otherUserIds = event.conversations
    .map(
      (conversation) =>
          conversation.otherParticipant(event.currentUserId),
    )
    .whereType<String>()
    .where((uid) => uid.trim().isNotEmpty)
    .toSet();

  final missingUserIds = otherUserIds
      .where(
        (uid) =>
            !_usersByUid.containsKey(uid) &&
            !_loadingUserIds.contains(uid),
      )
      .toList();

  if (missingUserIds.isEmpty) return;

  _loadingUserIds.addAll(missingUserIds);

  try {
    await Future.wait(
      missingUserIds.map((uid) async {
        try {
          final result = await getUserByUidUseCase(uid);

          result.fold(
            (_) {},
            (user) {
              _usersByUid[uid] = user;
            },
          );
        } finally {
          _loadingUserIds.remove(uid);
        }
      }),
    );
  } finally {
    _loadingUserIds.removeAll(missingUserIds);
  }

  if (emit.isDone) return;

  emit(
    ConversationsLoaded(
      event.conversations,
      usersByUid: Map.unmodifiable(_usersByUid),
    ),
  );
}

  @override
  Future<void> close() async {
    await _conversationsSubscription?.cancel();
    await _messagesSubscription?.cancel();
    return super.close();
  }
}
