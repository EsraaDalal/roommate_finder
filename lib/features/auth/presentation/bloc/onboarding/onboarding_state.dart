
abstract class OnboardingState {
  const OnboardingState();
}

/// الحالة الأولية قبل التحقق من حالة Onboarding.
class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

/// أثناء قراءة حالة Onboarding من التخزين.
class OnboardingLoading extends OnboardingState {
  const OnboardingLoading();
}

/// المستخدم أكمل Onboarding سابقًا.
class OnboardingCompleted extends OnboardingState {
  const OnboardingCompleted();
}

/// المستخدم لم يكمل Onboarding بعد.
class OnboardingNotCompleted extends OnboardingState {
  const OnboardingNotCompleted();
}

/// حدث خطأ أثناء قراءة أو حفظ حالة Onboarding.
class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError(this.message);
}
