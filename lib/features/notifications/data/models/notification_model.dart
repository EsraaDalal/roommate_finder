import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.recipientId,
    super.senderId,
    required super.title,
    required super.body,
    required super.type,
    super.listingId,
    super.applicationId,
    super.conversationId,
    required super.createdAt,
    super.isRead = false,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      }
      if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      }
      return DateTime.now();
    }

    NotificationType parseType(String? value) {
      return NotificationType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => NotificationType.newMessage,
      );
    }

    return NotificationModel(
      id: id,
      recipientId: map['recipientId'] as String? ?? '',
      senderId: map['senderId'] as String?,
      title: map['title'] as String? ?? '',
      body: map['body'] as String? ?? '',
      type: parseType(map['type'] as String?),
      listingId: map['listingId'] as String?,
      applicationId: map['applicationId'] as String?,
      conversationId: map['conversationId'] as String?,
      createdAt: parseDate(map['createdAt']),
      isRead: map['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'recipientId': recipientId,
      'senderId': senderId,
      'title': title,
      'body': body,
      'type': type.name,
      'listingId': listingId,
      'applicationId': applicationId,
      'conversationId': conversationId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      recipientId: entity.recipientId,
      senderId: entity.senderId,
      title: entity.title,
      body: entity.body,
      type: entity.type,
      listingId: entity.listingId,
      applicationId: entity.applicationId,
      conversationId: entity.conversationId,
      createdAt: entity.createdAt,
      isRead: entity.isRead,
    );
  }
}
