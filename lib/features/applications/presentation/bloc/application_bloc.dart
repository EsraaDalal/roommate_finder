// lib/features/applications/presentation/bloc/application_bloc.dart

import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

import '../../../../core/domain/entities/listing_entity.dart';
import '../../../hosting/domain/usecases/get_listing_by_id_usecase.dart';
import '../../domain/usecases/submit_application_usecase.dart';
import '../../domain/usecases/cancel_application_usecase.dart';
import '../../domain/usecases/get_submitted_applications_usecase.dart';
import '../../domain/usecases/get_received_applications_usecase.dart';
import '../../domain/usecases/set_application_status_usecase.dart';
import '../../domain/entities/application_entity.dart';
import 'application_event.dart';
import 'application_state.dart';
import '../../../../core/errors/failure.dart';

class ApplicationBloc extends Bloc<ApplicationEvent, ApplicationState> {
  final SubmitApplicationUseCase submitApplicationUseCase;
  final CancelApplicationUseCase cancelApplicationUseCase;
  final GetSubmittedApplicationsUseCase getSubmittedApplicationsUseCase;
  final GetReceivedApplicationsUseCase getReceivedApplicationsUseCase;
  final SetApplicationStatusUseCase setApplicationStatusUseCase;
  final GetListingByIdUseCase getListingByIdUseCase;
  StreamSubscription? _applicationsSubscription;

ApplicationBloc({
  required this.submitApplicationUseCase,
  required this.cancelApplicationUseCase,
  required this.getSubmittedApplicationsUseCase,
  required this.getReceivedApplicationsUseCase,
  required this.setApplicationStatusUseCase,
  required this.getListingByIdUseCase,
}) : super(const ApplicationInitial()) {
  on<LoadMyApplications>(_onLoadMyApplications);
  on<LoadReceivedApplications>(_onLoadReceivedApplications);
  on<SubmitApplication>(_onSubmitApplication);
  on<CancelApplication>(_onCancelApplication);
  on<SetApplicationStatus>(_onSetApplicationStatus);
  on<LoadApplicationListing>(_onLoadApplicationListing);
  on<WatchMyApplications>(_onWatchMyApplications);
  on<WatchReceivedApplications>(_onWatchReceivedApplications);
  on<ApplicationsStreamUpdated>((event, emit) => emit(ApplicationLoaded(event.applications)));
  on<ApplicationsStreamFailed>((event, emit) => emit(ApplicationFailure(event.message)));
}

  Future<void> _onLoadMyApplications(
      LoadMyApplications event, Emitter<ApplicationState> emit) async {
    emit(const ApplicationLoading());
    final uid = _currentUserId();
    if (uid == null) {
      emit(const ApplicationFailure('User not signed in'));
      return;
    }
    final result = await getSubmittedApplicationsUseCase(applicantId: uid);
    result.fold(
      (Failure f) => emit(ApplicationFailure(f.message)),
      (List<ApplicationEntity> apps) => emit(ApplicationLoaded(apps)),
    );
  }

  Future<void> _onLoadReceivedApplications(
      LoadReceivedApplications event, Emitter<ApplicationState> emit) async {
    emit(const ApplicationLoading());
    final uid = _currentUserId();
    if (uid == null) {
      emit(const ApplicationFailure('User not signed in'));
      return;
    }
    final result = await getReceivedApplicationsUseCase(ownerId: uid);
    result.fold(
      (Failure f) => emit(ApplicationFailure(f.message)),
      (List<ApplicationEntity> apps) => emit(ApplicationLoaded(apps)),
    );
  }

  Future<void> _onWatchMyApplications(WatchMyApplications event, Emitter<ApplicationState> emit) async {
    await _applicationsSubscription?.cancel();
    final uid = _currentUserId();
    if (uid == null) { emit(const ApplicationFailure('User not signed in')); return; }
    emit(const ApplicationLoading());
    _applicationsSubscription = getSubmittedApplicationsUseCase.watch(applicantId: uid).listen(
      (result) => result.fold(
        (failure) => add(ApplicationsStreamFailed(failure.message)),
        (applications) => add(ApplicationsStreamUpdated(applications)),
      ),
      onError: (Object error) => add(ApplicationsStreamFailed(error.toString())),
    );
  }

  Future<void> _onWatchReceivedApplications(WatchReceivedApplications event, Emitter<ApplicationState> emit) async {
    await _applicationsSubscription?.cancel();
    final uid = _currentUserId();
    if (uid == null) { emit(const ApplicationFailure('User not signed in')); return; }
    emit(const ApplicationLoading());
    _applicationsSubscription = getReceivedApplicationsUseCase.watch(ownerId: uid).listen(
      (result) => result.fold(
        (failure) => add(ApplicationsStreamFailed(failure.message)),
        (applications) => add(ApplicationsStreamUpdated(applications)),
      ),
      onError: (Object error) => add(ApplicationsStreamFailed(error.toString())),
    );
  }

  Future<void> _onSubmitApplication(
      SubmitApplication event, Emitter<ApplicationState> emit) async {
    emit(const ApplicationLoading());
    final result = await submitApplicationUseCase(
      listingId: event.listingId,
      applicantId: event.applicantId,
      requestedMoveIn: event.requestedMoveIn,
      message: event.message,
    );
    result.fold(
      (Failure f) => emit(ApplicationFailure(f.message)),
      (_) => emit(const ApplicationOperationSuccess()),
    );
  }

  Future<void> _onCancelApplication(
      CancelApplication event, Emitter<ApplicationState> emit) async {
    emit(const ApplicationLoading());
    final result = await cancelApplicationUseCase(
      applicationId: event.applicationId,
      applicantId: event.applicantId,
    );
    result.fold(
      (Failure f) => emit(ApplicationFailure(f.message)),
      (_) => emit(const ApplicationOperationSuccess()),
    );
  }

 Future<void> _onSetApplicationStatus(
  SetApplicationStatus event,
  Emitter<ApplicationState> emit,
) async {
  // Keep the current list visible while updating the status.
  final previousState = state;

  final result = await setApplicationStatusUseCase(
    applicationId: event.applicationId,
    ownerId: event.ownerId,
    newStatus: event.newStatus,
  );

  result.fold(
    (Failure failure) {
      emit(ApplicationFailure(failure.message));

      // Restore the previous list if the operation failed.
      if (previousState is ApplicationLoaded) {
        emit(ApplicationLoaded(previousState.applications));
      }
    },
    (_) {
      // Do not emit ApplicationLoading or ApplicationOperationSuccess.
      // Firestore stream will emit the updated application list.
    },
  );
}

  String? _currentUserId() {
    final firebase.User? user = GetIt.instance<firebase.FirebaseAuth>().currentUser;
    return user?.uid;
  }

  @override
  Future<void> close() async {
    await _applicationsSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadApplicationListing(
  LoadApplicationListing event,
  Emitter<ApplicationState> emit,
) async {
  emit(const ApplicationLoading());

  final result = await getListingByIdUseCase(
    listingId: event.listingId,
  );

  result.fold(
    (Failure failure) => emit(
      ApplicationFailure(failure.message),
    ),
    (ListingEntity listing) => emit(
      ApplicationListingLoaded(listing),
    ),
  );
}
}
