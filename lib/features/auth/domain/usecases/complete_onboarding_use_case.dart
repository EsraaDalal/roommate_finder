
import '../repositories/onboarding_repository.dart';

class CompleteOnboardingUseCase {
  final OnboardingRepository repository;

  CompleteOnboardingUseCase({
    required this.repository,
  });

  Future<void> call() {
    return repository.completeOnboarding();
  }
}
