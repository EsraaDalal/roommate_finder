import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_notifications_usecase.dart';
import '../../domain/usecases/mark_all_notifications_as_read_usecase.dart';
import '../../domain/usecases/mark_notification_as_read_usecase.dart';
import 'notification_event.dart';
import 'notification_state.dart';

class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final GetNotificationsUseCase getNotificationsUseCase;
  final MarkNotificationAsReadUseCase markNotificationAsReadUseCase;
  final MarkAllNotificationsAsReadUseCase markAllNotificationsAsReadUseCase;

  StreamSubscription? _notificationsSubscription;

  NotificationBloc({
    required this.getNotificationsUseCase,
    required this.markNotificationAsReadUseCase,
    required this.markAllNotificationsAsReadUseCase,
  }) : super(const NotificationInitial()) {
    on<WatchNotificationsEvent>(_onWatchNotifications);
    on<NotificationsUpdatedEvent>(_onNotificationsUpdated);
    on<NotificationErrorEvent>(_onNotificationError);
    on<MarkNotificationAsReadEvent>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsReadEvent>(_onMarkAllNotificationsAsRead);
  }

  Future<void> _onWatchNotifications(
    WatchNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    emit(const NotificationLoading());
    await _notificationsSubscription?.cancel();

    _notificationsSubscription = getNotificationsUseCase(event.userId).listen(
      (result) {
        result.fold(
          (failure) => add(NotificationErrorEvent(failure.message)),
          (notifications) => add(NotificationsUpdatedEvent(notifications)),
        );
      },
      onError: (error) {
        add(NotificationErrorEvent(error.toString()));
      },
    );
  }

  void _onNotificationsUpdated(
    NotificationsUpdatedEvent event,
    Emitter<NotificationState> emit,
  ) {
    final unreadCount = event.notifications.where((n) => !n.isRead).length;
    emit(NotificationLoaded(
      notifications: event.notifications,
      unreadCount: unreadCount,
    ));
  }

  void _onNotificationError(
    NotificationErrorEvent event,
    Emitter<NotificationState> emit,
  ) {
    emit(NotificationErrorState(event.message));
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    await markNotificationAsReadUseCase(event.notificationId);
  }

  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    await markAllNotificationsAsReadUseCase(event.userId);
  }

  @override
  Future<void> close() {
    _notificationsSubscription?.cancel();
    return super.close();
  }
}
