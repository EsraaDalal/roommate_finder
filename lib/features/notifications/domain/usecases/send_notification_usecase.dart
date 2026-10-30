import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class SendNotificationUseCase {
  final NotificationRepository repository;

  SendNotificationUseCase({required this.repository});

  Future<Either<Failure, void>> call(NotificationEntity notification) {
    return repository.sendNotification(notification);
  }
}
