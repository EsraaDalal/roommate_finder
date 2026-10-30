
import 'package:shared_preferences/shared_preferences.dart';

abstract class OnboardingLocalDataSource {
  Future<bool> isOnboardingCompleted();

  Future<void> completeOnboarding();
}

class OnboardingLocalDataSourceImpl
    implements OnboardingLocalDataSource {
  final SharedPreferences sharedPreferences;

  OnboardingLocalDataSourceImpl({
    required this.sharedPreferences,
  });

  static const String _onboardingCompletedKey =
      'isOnboardingCompleted';

  @override
  Future<bool> isOnboardingCompleted() async {
    return sharedPreferences.getBool(
          _onboardingCompletedKey,
        ) ??
        false;
  }

  @override
  Future<void> completeOnboarding() async {
    final success = await sharedPreferences.setBool(
      _onboardingCompletedKey,
      true,
    );

    if (!success) {
      throw Exception('Failed to save onboarding status.');
    }
  }
}
