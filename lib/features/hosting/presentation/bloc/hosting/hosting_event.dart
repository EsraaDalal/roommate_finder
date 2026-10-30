import '../../../../../core/domain/entities/listing_entity.dart';

abstract class HostingEvent {
  const HostingEvent();
}

/// Create a new listing.
class CreateListingEvent extends HostingEvent {
  final ListingEntity listing;

  /// Local paths of the photos selected for this listing.
  ///
  /// They are uploaded before the listing is persisted. When the list is
  /// empty the listing is created without photos.
  final List<String> imageFilePaths;

  const CreateListingEvent({
    required this.listing,
    this.imageFilePaths = const [],
  });
}

/// Fetch listings owned by the current user.
class GetMyListingsEvent extends HostingEvent {
  final String ownerId;

  const GetMyListingsEvent({required this.ownerId});
}

/// Update an existing listing.
class UpdateListingEvent extends HostingEvent {
  final ListingEntity listing;

  const UpdateListingEvent({required this.listing});
}

/// Delete a listing owned by the current user.
class DeleteListingEvent extends HostingEvent {
  final String listingId;
  final String ownerId;

  const DeleteListingEvent({required this.listingId, required this.ownerId});
}
