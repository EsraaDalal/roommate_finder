
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rommate_finder/core/errors/failure.dart';
import 'package:rommate_finder/features/notifications/data/models/notification_model.dart';
import 'package:rommate_finder/features/notifications/domain/entities/notification_entity.dart';
import 'package:rommate_finder/features/notifications/domain/repositories/notification_repository.dart';
import 'package:rommate_finder/features/notifications/domain/usecases/get_notifications_usecase.dart';
import 'package:rommate_finder/features/notifications/domain/usecases/mark_all_notifications_as_read_usecase.dart';
import 'package:rommate_finder/features/notifications/domain/usecases/mark_notification_as_read_usecase.dart';
import 'package:rommate_finder/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:rommate_finder/features/notifications/presentation/bloc/notification_event.dart';
import 'package:rommate_finder/features/notifications/presentation/bloc/notification_state.dart';

class MockNotificationRepository implements NotificationRepository {
  List<NotificationEntity> notifications = [];

  @override
  Future<Either<Failure, void>> sendNotification(
    NotificationEntity notification,
  ) async {
    notifications.add(notification);
    return const Right(null);
  }

  @override
  Stream<Either<Failure, List<NotificationEntity>>> getNotifications(
    String userId,
  ) async* {
    yield Right(
      notifications.where((n) => n.recipientId == userId).toList(),
    );
  }

  @override
  Future<Either<Failure, void>> markAsRead(String notificationId) async {
    final index = notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      notifications[index] = notifications[index].copyWith(isRead: true);
    }
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> markAllAsRead(String userId) async {
    notifications = notifications.map((n) {
      if (n.recipientId == userId) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> saveFcmToken(
    String userId,
    String token,
  ) async {
    return const Right(null);
  }
}

void main() {
  group('Notification Model & Entity Tests', () {
    test('NotificationModel converts to and from map correctly', () {
      final now = DateTime.now();
      final model = NotificationModel(
        id: 'notif_1',
        recipientId: 'user_123',
        senderId: 'user_456',
        title: 'New Application',
        body: 'Someone applied to your listing',
        type: NotificationType.newApplication,
        listingId: 'listing_789',
        applicationId: 'app_001',
        conversationId: null,
        createdAt: now,
        isRead: false,
      );

      final map = model.toMap();
      expect(map['recipientId'], 'user_123');
      expect(map['senderId'], 'user_456');
      expect(map['title'], 'New Application');
      expect(map['type'], 'newApplication');
      expect(map['listingId'], 'listing_789');
      expect(map['applicationId'], 'app_001');
      expect(map['isRead'], false);

      final fromMap = NotificationModel.fromMap(map, 'notif_1');
      expect(fromMap.id, 'notif_1');
      expect(fromMap.recipientId, 'user_123');
      expect(fromMap.type, NotificationType.newApplication);
      expect(fromMap.isRead, false);
    });

    test('NotificationEntity copyWith works as expected', () {
      final entity = NotificationEntity(
        id: '1',
        recipientId: 'u1',
        title: 'Title',
        body: 'Body',
        type: NotificationType.newMessage,
        createdAt: DateTime.now(),
        isRead: false,
      );

      final updated = entity.copyWith(isRead: true);
      expect(updated.isRead, true);
      expect(updated.title, 'Title');
    });
  });

  group('NotificationBloc Tests', () {
    late MockNotificationRepository repository;
    late GetNotificationsUseCase getNotificationsUseCase;
    late MarkNotificationAsReadUseCase markNotificationAsReadUseCase;
    late MarkAllNotificationsAsReadUseCase markAllNotificationsAsReadUseCase;
    late NotificationBloc bloc;

    setUp(() {
      repository = MockNotificationRepository();
      getNotificationsUseCase =
          GetNotificationsUseCase(repository: repository);
      markNotificationAsReadUseCase =
          MarkNotificationAsReadUseCase(repository: repository);
      markAllNotificationsAsReadUseCase =
          MarkAllNotificationsAsReadUseCase(repository: repository);

      bloc = NotificationBloc(
        getNotificationsUseCase: getNotificationsUseCase,
        markNotificationAsReadUseCase: markNotificationAsReadUseCase,
        markAllNotificationsAsReadUseCase: markAllNotificationsAsReadUseCase,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('Initial state is NotificationInitial', () {
      expect(bloc.state, isA<NotificationInitial>());
    });

    test('Loads notifications and calculates unread count', () async {
      repository.notifications = [
        NotificationEntity(
          id: 'n1',
          recipientId: 'user_1',
          title: 'App Accepted',
          body: 'Accepted',
          type: NotificationType.applicationAccepted,
          createdAt: DateTime.now(),
          isRead: false,
        ),
        NotificationEntity(
          id: 'n2',
          recipientId: 'user_1',
          title: 'New Msg',
          body: 'Hello',
          type: NotificationType.newMessage,
          createdAt: DateTime.now(),
          isRead: true,
        ),
      ];

      bloc.add(const WatchNotificationsEvent('user_1'));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<NotificationLoading>(),
          predicate<NotificationLoaded>((state) {
            return state.notifications.length == 2 && state.unreadCount == 1;
          }),
        ]),
      );
    });
  });
}
