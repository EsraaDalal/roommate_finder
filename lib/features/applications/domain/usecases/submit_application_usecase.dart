import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../entities/application_entity.dart';
import '../repositories/application_repository.dart';

class SubmitApplicationUseCase {
  const SubmitApplicationUseCase({required this.repository});

  final ApplicationRepository repository;

  Future<Either<Failure, ApplicationEntity>> call({
    required String listingId,
    required String applicantId,
    required DateTime requestedMoveIn,
    required String message,
  }) {
    return repository.submitApplication(
      listingId: listingId,
      applicantId: applicantId,
      requestedMoveIn: requestedMoveIn,
      message: message,
    );
  }
}
