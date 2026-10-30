import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../repositories/application_repository.dart';

class CancelApplicationUseCase {
  const CancelApplicationUseCase({required this.repository});

  final ApplicationRepository repository;

  Future<Either<Failure, void>> call({
    required String applicationId,
    required String applicantId,
  }) {
    return repository.cancelApplication(
      applicationId: applicationId,
      applicantId: applicantId,
    );
  }
}
