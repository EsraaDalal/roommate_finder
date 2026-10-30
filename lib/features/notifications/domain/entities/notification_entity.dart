enum NotificationType {
  newApplication,
  applicationAccepted,
  applicationRejected,
  newMessage,
}

class NotificationEntity {
  final String id;
  final String recipientId;
  final String? senderId;
  final String title;
  final String body;
  final NotificationType type;
  final String? listingId;
  final String? applicationId;
  final String? conversationId;
  final DateTime createdAt;
  final bool isRead;

  const NotificationEntity({
    required this.id,
    required this.recipientId,
    this.senderId,
    required this.title,
    required this.body,
    required this.type,
    this.listingId,
    this.applicationId,
    this.conversationId,
    required this.createdAt,
    this.isRead = false,
  });

  NotificationEntity copyWith({
    String? id,
    String? recipientId,
    String? senderId,
    String? title,
    String? body,
    NotificationType? type,
    String? listingId,
    String? applicationId,
    String? conversationId,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      senderId: senderId ?? this.senderId,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      listingId: listingId ?? this.listingId,
      applicationId: applicationId ?? this.applicationId,
      conversationId: conversationId ?? this.conversationId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}
