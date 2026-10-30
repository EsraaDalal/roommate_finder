
import '../repositories/onboarding_repository.dart';

class IsOnboardingCompletedUseCase {
  final OnboardingRepository repository;

  IsOnboardingCompletedUseCase({
    required this.repository,
  });

  Future<bool> call() {
    return repository.isOnboardingCompleted();
  }
}
