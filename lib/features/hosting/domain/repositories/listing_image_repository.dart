import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/listing_image_upload_result.dart';

/// Uploads the photos of a listing to the image storage service.
///
/// The service assigns the storage folder identifier and returns it, so the
/// caller can reuse it as the listing document id.
abstract class ListingImageRepository {
  /// Uploads the images located at [filePaths].
  ///
  /// The owner of the uploaded files is derived from the verified
  /// authentication token on the server, never from the caller.
  Future<Either<Failure, ListingImageUploadResult>> uploadListingImages({
    required List<String> filePaths,
  });
}
