import 'package:flutter/foundation.dart';

/// Successful outcome of a listing image upload.
///
/// The [listingId] is the identifier assigned by the image storage service.
/// It is authoritative and is reused as the Firestore document id of the
/// listing, so the storage folder and the listing document always share the
/// same id.
@immutable
class ListingImageUploadResult {
  const ListingImageUploadResult({
    required this.listingId,
    required this.photoPaths,
    required this.photoUrls,
  });

  /// Identifier of the storage folder created by the upload service.
  final String listingId;

  /// Bucket-relative storage paths of the uploaded images.
  final List<String> photoPaths;

  /// Publicly reachable URLs of the uploaded images.
  final List<String> photoUrls;
}
