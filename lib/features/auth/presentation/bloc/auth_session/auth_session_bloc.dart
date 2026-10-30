
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/domain/entities/user_entity.dart';
import '../../../domain/usecases/auth_state_changes_use_case.dart';
import 'auth_session_event.dart';
import 'auth_session_state.dart';

class AuthSessionBloc
    extends Bloc<AuthSessionEvent, AuthSessionState> {
  final AuthStateChangesUseCase authStateChangesUseCase;

  StreamSubscription<UserEntity?>? _sessionSubscription;

  AuthSessionBloc({
    required this.authStateChangesUseCase,
  }) : super( AuthSessionInitial()) {
    on<AuthSessionStarted>(_onStarted);
    on<AuthSessionChanged>(_onSessionChanged);
    on<AuthSessionFailed>(_onSessionFailed);
  }

  Future<void> _onStarted(
    AuthSessionStarted event,
    Emitter<AuthSessionState> emit,
  ) async {
    // Prevent duplicate subscriptions if monitoring starts again.
    await _sessionSubscription?.cancel();

    emit( AuthSessionLoading());

    _sessionSubscription = authStateChangesUseCase().listen(
      (user) {
        add(AuthSessionChanged(user));
      },
      onError: (Object error, StackTrace stackTrace) {
        add(AuthSessionFailed(_getErrorMessage(error)));
      },
    );
  }

  void _onSessionChanged(
    AuthSessionChanged event,
    Emitter<AuthSessionState> emit,
  ) {
    final user = event.user;

    if (user == null) {
      emit( AuthSessionUnauthenticated());
    } else {
      emit(AuthSessionAuthenticated(user));
    }
  }

  void _onSessionFailed(
    AuthSessionFailed event,
    Emitter<AuthSessionState> emit,
  ) {
    emit(AuthSessionError(event.message));
  }

  String _getErrorMessage(Object error) {
    final message = error.toString();

    if (message.contains('Unable to retrieve user data.')) {
      return 'Unable to retrieve user data. Please try again.';
    }

    if (message.contains('Unable to monitor the authentication session.')) {
      return 'Unable to monitor your session. Please try again.';
    }

    return 'An unexpected error occurred while checking your session.';
  }

  @override
  Future<void> close() async {
    await _sessionSubscription?.cancel();
    return super.close();
  }
}
