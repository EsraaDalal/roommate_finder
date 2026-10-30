import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../domain/usecases/get_users_use_case.dart';

import 'users_event.dart';
import 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final GetUsersUseCase getUsersUseCase;

  UsersBloc({
    required this.getUsersUseCase,
  }) : super(const UsersInitial()) {
    on<UsersLoadRequested>(_onLoadRequested);
  }

  Future<void> _onLoadRequested(
    UsersLoadRequested event,
    Emitter<UsersState> emit,
  ) async {
    emit(const UsersLoading());

    try {
      final users = await getUsersUseCase();
      emit(UsersLoaded(users));
    } catch (e) {
      emit(UsersFailure('Could not load users. Please try again.'));
    }
  }
}