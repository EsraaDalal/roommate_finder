import '../../domain/entities/notification_entity.dart';

abstract class NotificationEvent {
  const NotificationEvent();
}

class WatchNotificationsEvent extends NotificationEvent {
  final String userId;

  const WatchNotificationsEvent(this.userId);
}

class NotificationsUpdatedEvent extends NotificationEvent {
  final List<NotificationEntity> notifications;

  const NotificationsUpdatedEvent(this.notifications);
}

class NotificationErrorEvent extends NotificationEvent {
  final String message;

  const NotificationErrorEvent(this.message);
}

class MarkNotificationAsReadEvent extends NotificationEvent {
  final String notificationId;

  const MarkNotificationAsReadEvent(this.notificationId);
}

class MarkAllNotificationsAsReadEvent extends NotificationEvent {
  final String userId;

  const MarkAllNotificationsAsReadEvent(this.userId);
}
