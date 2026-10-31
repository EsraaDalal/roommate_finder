
import 'dart:convert';


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


import '../../../../core/models/user_model.dart';
import '../../../notifications/data/datasources/notification_remote_data_source.dart';

import '../models/chat_message_model.dart';
import '../models/conversation_model.dart';

abstract class ChatRemoteDataSource {
  Stream<List<ConversationModel>> getConversations();

  Stream<List<ChatMessageModel>> getMessages(
    String conversationId,
  );

  Future<String> getOrCreateConversation({
    required String otherUserId,
    String? listingId,
  });

  /// Reads a single conversation by id (used to resume a thread from a
  /// notification tap). Throws [StateError] when it does not exist.
  Future<ConversationModel> getConversationById(String conversationId);

  Future<void> sendMessage({
    required String conversationId,
    required String text,
  });

  Future<UserModel> getUserByUid(String uid);
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;
  final NotificationRemoteDataSource? notificationRemoteDataSource;

  ChatRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
    this.notificationRemoteDataSource,
  });

  CollectionReference<Map<String, dynamic>> get _conversations =>
      firestore.collection('conversations');

  String get _currentUserId {
    final user = firebaseAuth.currentUser;

    if (user == null) {
      throw StateError('User is not authenticated.');
    }

    return user.uid;
  }

  DocumentReference<Map<String, dynamic>> _conversationRef(
    String conversationId,
  ) {
    return _conversations.doc(conversationId);
  }

  @override
  Stream<List<ConversationModel>> getConversations() {
    final currentUserId = _currentUserId;

    return _conversations
        .where(
          'participantIds',
          arrayContains: currentUserId,
        )
        .snapshots()
        .map((snapshot) {
      final conversations = snapshot.docs.map((document) {
        return ConversationModel.fromMap(
          id: document.id,
          map: document.data(),
        );
      }).toList();

      conversations.sort((a, b) {
        final aDate = a.lastMessageAt ?? a.createdAt;
        final bDate = b.lastMessageAt ?? b.createdAt;

        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;

        return bDate.compareTo(aDate);
      });

      return conversations;
    });
  }

  @override
  Stream<List<ChatMessageModel>> getMessages(
    String conversationId,
  ) {
    return _conversationRef(conversationId)
        .collection('messages')
        .orderBy('sentAt')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((document) {
        return ChatMessageModel.fromMap(
          id: document.id,
          conversationId: conversationId,
          map: document.data(),
        );
      }).toList();
    });
  }

 
@override
Future<String> getOrCreateConversation({
  required String otherUserId,
  String? listingId,
}) async {
  final currentUserId = _currentUserId;

  if (currentUserId == otherUserId) {
    throw ArgumentError(
      'A conversation requires two different users.',
    );
  }

  final participants = [currentUserId, otherUserId]..sort();

  final encodedFirst = base64Url.encode(
    utf8.encode(participants[0]),
  );

  final encodedSecond = base64Url.encode(
    utf8.encode(participants[1]),
  );
 
  final conversationId = 'pair_${encodedFirst}_$encodedSecond';
  final reference = _conversationRef(conversationId);

  // Read the document directly instead of using a transaction.
  final snapshot = await reference.get();

  if (snapshot.exists) {
    final data = snapshot.data()!;
    final existingParticipants =
        List<String>.from(data['participantIds'] ?? []);

    if (existingParticipants.length != 2 ||
        !existingParticipants.contains(currentUserId) ||
        !existingParticipants.contains(otherUserId)) {
      throw StateError(
        'Conversation participants do not match.',
      );
    }

    return conversationId;
  }

  await reference.set({
    'participantIds': participants,
    'listingId': listingId,
    'lastMessage': null,
    'lastMessageAt': null,
    'createdAt': FieldValue.serverTimestamp(),
  });

  return conversationId;
}


  @override
  Future<ConversationModel> getConversationById(
    String conversationId,
  ) async {
    if (conversationId.trim().isEmpty) {
      throw ArgumentError('Conversation ID cannot be empty.');
    }

    final snapshot = await _conversationRef(conversationId).get();

    if (!snapshot.exists) {
      throw StateError('Conversation not found.');
    }

    return ConversationModel.fromMap(
      id: snapshot.id,
      map: snapshot.data()!,
    );
  }

 
@override
Future<void> sendMessage({
  required String conversationId,
  required String text,
}) async {
  final senderId = _currentUserId;
  final trimmedText = text.trim();

  if (trimmedText.isEmpty) return;

  final conversationRef = _conversationRef(conversationId);
  final messageRef = conversationRef.collection('messages').doc();
  final now = DateTime.now();

  final batch = firestore.batch();

  batch.set(messageRef, {
    'senderId': senderId,
    'text': trimmedText,
    'sentAt': Timestamp.fromDate(now),
  });

  batch.update(conversationRef, {
    'lastMessage': trimmedText,
    'lastMessageAt': Timestamp.fromDate(now),
  });

  await batch.commit();

  try {
    final convDoc = await conversationRef.get();

    if (!convDoc.exists) {
      throw StateError('Conversation not found after sending message.');
    }

    final convData = convDoc.data();
    final participantIds =
        List<String>.from(convData?['participantIds'] ?? []);

    final recipientId = participantIds.firstWhere(
      (id) => id != senderId,
      orElse: () => '',
    );

    if (recipientId.isEmpty) {
      throw StateError('Conversation recipient not found.');
    }

    final senderDoc =
        await firestore.collection('users').doc(senderId).get();

    final senderName =
        senderDoc.data()?['fullName'] as String? ?? 'Someone';

    // Keep the existing Firestore notification for the app's notification list.
    final notifDoc = firestore.collection('notifications').doc();

    await notifDoc.set({
      'recipientId': recipientId,
      'senderId': senderId,
      'title': 'New Message',
      'body': '$senderName: $trimmedText',
      'type': 'newMessage',
      'conversationId': conversationId,
      'listingId': convData?['listingId'],
      'createdAt': Timestamp.now(),
      'isRead': false,
    });

    // Invoke Supabase Edge Function for push delivery.
    await notificationRemoteDataSource?.triggerPushNotification(
      payload: {
        'type': 'newMessage',
        'conversationId': conversationId,
        'messageId': messageRef.id,
      },
    );
  } catch (e) {
   
  }
}


  @override
Future<UserModel> getUserByUid(String uid) async {
  if (uid.trim().isEmpty) {
    throw ArgumentError('User UID cannot be empty.');
  }

  final snapshot = await firestore
      .collection('users')
      .doc(uid)
      .get();

  if (!snapshot.exists) {
    throw StateError('User not found.');
  }

  final data = snapshot.data();

  if (data == null) {
    throw StateError('User data is empty.');
  }

  return UserModel.fromMap(
  
    map: data, uid: snapshot.id,
  );
}
}
