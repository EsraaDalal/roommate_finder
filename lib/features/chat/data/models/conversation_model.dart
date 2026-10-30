
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/conversation_entity.dart';

class ConversationModel extends ConversationEntity {
  const ConversationModel({
    required super.id,
    required super.participantIds,
    super.listingId,
    super.lastMessage,
    super.lastMessageAt,
    super.createdAt,
  });

  factory ConversationModel.fromMap({
    required String id,
    required Map<String, dynamic> map,
  }) {
    return ConversationModel(
      id: id,
      participantIds: List<String>.from(
        map['participantIds'] ?? const <String>[],
      ),
      listingId: map['listingId'] as String?,
      lastMessage: map['lastMessage'] as String?,
      lastMessageAt: _parseDate(map['lastMessageAt']),
      createdAt: _parseDate(map['createdAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantIds': participantIds,
      'listingId': listingId,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt == null
          ? null
          : Timestamp.fromDate(lastMessageAt!),
      'createdAt': createdAt == null
          ? null
          : Timestamp.fromDate(createdAt!),
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
