import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/application_entity.dart';
import '../repositories/application_repository.dart';

class SetApplicationStatusUseCase {
  const SetApplicationStatusUseCase({required this.repository});

  final ApplicationRepository repository;

  Future<Either<Failure, void>> call({
    required String applicationId,
    required String ownerId,
    required ApplicationStatus newStatus,
  }) {
    return repository.setApplicationStatus(
      applicationId: applicationId,
      ownerId: ownerId,
      newStatus: newStatus,
    );
  }
}
