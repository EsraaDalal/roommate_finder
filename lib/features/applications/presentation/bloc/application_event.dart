// lib/features/applications/presentation/bloc/application_event.dart


import '../../domain/entities/application_entity.dart';

abstract class ApplicationEvent {
  const ApplicationEvent();

}

// Load applications submitted by the current user
class LoadMyApplications extends ApplicationEvent {
  const LoadMyApplications();
}

// Load applications received for listings owned by the current user
class LoadReceivedApplications extends ApplicationEvent {
  const LoadReceivedApplications();
}

// Submit a new application
class SubmitApplication extends ApplicationEvent {
  final String listingId;
  final String applicantId;
  final DateTime requestedMoveIn;
  final String message;

  const SubmitApplication({
    required this.listingId,
    required this.applicantId,
    required this.requestedMoveIn,
    required this.message,
  });

}

// Cancel a pending application (applicant side)
class CancelApplication extends ApplicationEvent {
  final String applicationId;
  final String applicantId;

  const CancelApplication({required this.applicationId, required this.applicantId});

}

// Owner decides to accept or reject an application
class SetApplicationStatus extends ApplicationEvent {
  final String applicationId;
  final String ownerId;
  final ApplicationStatus newStatus;

  const SetApplicationStatus({
    required this.applicationId,
    required this.ownerId,
    required this.newStatus,
  });



}

class LoadApplicationListing extends ApplicationEvent {
  final String listingId;

  const LoadApplicationListing({required this.listingId});
}

class WatchMyApplications extends ApplicationEvent { const WatchMyApplications(); }
class WatchReceivedApplications extends ApplicationEvent { const WatchReceivedApplications(); }
class ApplicationsStreamUpdated extends ApplicationEvent {
  final List<ApplicationEntity> applications;
  const ApplicationsStreamUpdated(this.applications);
}
class ApplicationsStreamFailed extends ApplicationEvent {
  final String message;
  const ApplicationsStreamFailed(this.message);
}
