
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/application_entity.dart';

class ApplicationModel extends ApplicationEntity {
  const ApplicationModel({
    required super.id,
    required super.listingId,
    required super.applicantId,
    required super.ownerId,
    required super.requestedMoveIn,
    required super.message,
    required super.status,
    required super.submittedAt,
  });

  factory ApplicationModel.fromMap({
    required String id,
    required Map<String, dynamic> map,
  }) {
    return ApplicationModel(
      id: id,
      listingId: map['listingId'] as String? ?? '',
      applicantId: map['applicantId'] as String? ?? '',
      ownerId: map['ownerId'] as String? ?? '',
      requestedMoveIn:
          (map['requestedMoveIn'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      message: map['message'] as String? ?? '',
      status: _parseStatus(map['status'] as String?),
      submittedAt:
          (map['submittedAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'listingId': listingId,
      'applicantId': applicantId,
      'ownerId': ownerId,
      'requestedMoveIn': Timestamp.fromDate(requestedMoveIn),
      'message': message,
      'status': status.name,
      'submittedAt': Timestamp.fromDate(submittedAt),
    };
  }

  static ApplicationStatus _parseStatus(String? value) {
    for (final status in ApplicationStatus.values) {
      if (status.name == value) return status;
    }
    return ApplicationStatus.pending;
  }
}
