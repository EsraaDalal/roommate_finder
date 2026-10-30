
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_data_source.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource localDataSource;

  OnboardingRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<bool> isOnboardingCompleted() {
    return localDataSource.isOnboardingCompleted();
  }

  @override
  Future<void> completeOnboarding() {
    return localDataSource.completeOnboarding();
  }
}
