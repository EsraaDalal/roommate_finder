import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/notification_repository.dart';

class MarkAllNotificationsAsReadUseCase {
  final NotificationRepository repository;

  MarkAllNotificationsAsReadUseCase({required this.repository});

  Future<Either<Failure, void>> call(String userId) {
    return repository.markAllAsRead(userId);
  }
}
