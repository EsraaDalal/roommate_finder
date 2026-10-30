

import '../../../../../core/domain/entities/listing_entity.dart';

enum HostingStatus {
  initial,
  loading,
  success,
  failure,
}

class HostingState {
  final HostingStatus status;
  final List<ListingEntity> listings;
  final ListingEntity? selectedListing;
  final String? errorMessage;
  final String? successMessage;

  const HostingState({
    this.status = HostingStatus.initial,
    this.listings = const [],
    this.selectedListing,
    this.errorMessage,
    this.successMessage,
  });

  HostingState copyWith({
    HostingStatus? status,
    List<ListingEntity>? listings,
    ListingEntity? selectedListing,
    String? errorMessage,
    String? successMessage,
    bool clearSelectedListing = false,
    bool clearErrorMessage = false,
    bool clearSuccessMessage = false,
  }) {
    return HostingState(
      status: status ?? this.status,
      listings: listings ?? this.listings,
      selectedListing: clearSelectedListing
          ? null
          : selectedListing ?? this.selectedListing,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      successMessage: clearSuccessMessage
          ? null
          : successMessage ?? this.successMessage,
    );
  }

}
