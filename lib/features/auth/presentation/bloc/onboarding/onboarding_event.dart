
abstract class OnboardingEvent {
  const OnboardingEvent();
}

/// طلب التحقق مما إذا كان المستخدم أكمل Onboarding.
class OnboardingStatusRequested extends OnboardingEvent {
  const OnboardingStatusRequested();
}

/// طلب حفظ أن المستخدم أكمل Onboarding.
class OnboardingCompletedRequested extends OnboardingEvent {
  const OnboardingCompletedRequested();
}
