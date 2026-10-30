import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../repositories/notification_repository.dart';

class SaveFcmTokenUseCase {
  final NotificationRepository repository;

  SaveFcmTokenUseCase({required this.repository});

  Future<Either<Failure, void>> call({
    required String userId,
    required String token,
  }) {
    return repository.saveFcmToken(userId, token);
  }
}
