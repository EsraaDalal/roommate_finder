
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(const ProfileInitial()) {
    on<ProfileLoadRequested>(_onProfileLoadRequested);
    on<ProfileUpdateRequested>(_onProfileUpdateRequested);
  }

  Future<void> _onProfileLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());

    final result = await getProfileUseCase(uid: event.uid);

    result.fold(
      (failure) => emit(ProfileFailureState(failure.message)),
      (user) => emit(ProfileLoaded(user)),
    );
  }

  Future<void> _onProfileUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;

    if (currentState is ProfileLoaded) {
      emit(ProfileUpdating(currentState.user));
    } else if (currentState is ProfileUpdateSuccess) {
      emit(ProfileUpdating(currentState.user));
    }

    final result = await updateProfileUseCase(
      uid: event.uid,
      fullName: event.fullName,
      city: event.city,
      bio: event.bio,
    );

    result.fold(
      (failure) => emit(ProfileFailureState(failure.message)),
      (user) => emit(ProfileUpdateSuccess(user)),
    );
  }
}
