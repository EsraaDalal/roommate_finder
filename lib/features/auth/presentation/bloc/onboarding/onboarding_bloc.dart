
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/is_onboarding_completed_use_case.dart';
import '../../../domain/usecases/complete_onboarding_use_case.dart';

import 'onboarding_event.dart';
import 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final IsOnboardingCompletedUseCase isOnboardingCompletedUseCase;
  final CompleteOnboardingUseCase completeOnboardingUseCase;

  OnboardingBloc({
    required this.isOnboardingCompletedUseCase,
    required this.completeOnboardingUseCase,
  }) : super(const OnboardingInitial()) {
    on<OnboardingStatusRequested>(_onStatusRequested);
    on<OnboardingCompletedRequested>(_onCompletedRequested);
  }

  /// Checks whether the user has completed onboarding before.
  Future<void> _onStatusRequested(
    OnboardingStatusRequested event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingLoading());

    try {
      final bool isCompleted =
          await isOnboardingCompletedUseCase();

      if (isCompleted) {
        emit(const OnboardingCompleted());
      } else {
        emit(const OnboardingNotCompleted());
      }
    } catch (error) {
      emit(
        const OnboardingError(
          'Unable to check onboarding status. Please try again.',
        ),
      );
    }
  }

  /// Saves that the user has completed onboarding.
  Future<void> _onCompletedRequested(
    OnboardingCompletedRequested event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingLoading());

    try {
      await completeOnboardingUseCase();

      emit(const OnboardingCompleted());
    } catch (error) {
      emit(
        const OnboardingError(
          'Unable to complete onboarding. Please try again.',
        ),
      );
    }
  }
}
