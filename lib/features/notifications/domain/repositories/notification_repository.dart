import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<Either<Failure, void>> sendNotification(NotificationEntity notification);

  Stream<Either<Failure, List<NotificationEntity>>> getNotifications(String userId);

  Future<Either<Failure, void>> markAsRead(String notificationId);

  Future<Either<Failure, void>> markAllAsRead(String userId);

  Future<Either<Failure, void>> saveFcmToken(String userId, String token);
}
