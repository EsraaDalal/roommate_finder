
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/chat_message_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.text,
    required super.sentAt,
  });

  factory ChatMessageModel.fromMap({
    required String id,
    required String conversationId,
    required Map<String, dynamic> map,
  }) {
    return ChatMessageModel(
      id: id,
      conversationId: conversationId,
      senderId: map['senderId'] as String? ?? '',
      text: map['text'] as String? ?? '',
      sentAt: _parseDate(map['sentAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'text': text,
      'sentAt': Timestamp.fromDate(sentAt),
    };
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}
