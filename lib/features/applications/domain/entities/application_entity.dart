// Application entity definition for the Applications feature.
// Mirrors the mock HousingApplication model but is immutable and used throughout the domain layer.

/// Represents the lifecycle status of a housing application.
enum ApplicationStatus {
  pending('Pending'),
  accepted('Accepted'),
  rejected('Rejected'),
  cancelled('Cancelled');

  const ApplicationStatus(this.label);
  final String label;

  /// Whether the owner may still accept or reject the application.
  bool get isActionable => this == ApplicationStatus.pending;

  /// Whether the applicant may still withdraw the application.
  bool get isCancellable => this == ApplicationStatus.pending;
}

/// Immutable domain entity for a housing application.

class ApplicationEntity {
  const ApplicationEntity({
    required this.id,
    required this.listingId,
    required this.applicantId,
    required this.ownerId,
    required this.requestedMoveIn,
    required this.message,
    required this.status,
    required this.submittedAt,
  });

  final String id;
  final String listingId;
  final String applicantId;
  final String ownerId;
  final DateTime requestedMoveIn;
  final String message;
  final ApplicationStatus status;
  final DateTime submittedAt;

  ApplicationEntity copyWith({
    DateTime? requestedMoveIn,
    String? message,
    ApplicationStatus? status,
  }) {
    return ApplicationEntity(
      id: id,
      listingId: listingId,
      applicantId: applicantId,
      ownerId: ownerId,
      requestedMoveIn: requestedMoveIn ?? this.requestedMoveIn,
      message: message ?? this.message,
      status: status ?? this.status,
      submittedAt: submittedAt,
    );
  }
}
