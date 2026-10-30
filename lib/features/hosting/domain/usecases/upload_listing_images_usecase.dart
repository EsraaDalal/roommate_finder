import 'package:dartz/dartz.dart';

import '../../../../core/errors/failure.dart';
import '../entities/listing_image_upload_result.dart';
import '../repositories/listing_image_repository.dart';

class UploadListingImagesUseCase {
  const UploadListingImagesUseCase({required this.repository});

  final ListingImageRepository repository;

  Future<Either<Failure, ListingImageUploadResult>> call({
    required List<String> filePaths,
  }) {
    return repository.uploadListingImages(filePaths: filePaths);
  }
}
