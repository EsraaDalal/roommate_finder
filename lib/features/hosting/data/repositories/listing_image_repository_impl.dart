import 'dart:io';

import 'package:dartz/dartz.dart';

import '../../../../core/errors/exception.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/listing_image_upload_result.dart';
import '../../domain/repositories/listing_image_repository.dart';
import '../datasources/listing_image_upload_data_source.dart';

class ListingImageRepositoryImpl implements ListingImageRepository {
  final ListingImageUploadDataSource uploadDataSource;

  ListingImageRepositoryImpl({required this.uploadDataSource});

  @override
  Future<Either<Failure, ListingImageUploadResult>> uploadListingImages({
    required List<String> filePaths,
  }) async {
    try {
      final List<File> imageFiles = filePaths
          .map((String filePath) => File(filePath))
          .toList(growable: false);

      // The deployed Edge Function generates the storage folder identifier
      // itself, so no client supplied id is sent. The returned identifier is
      // authoritative and is reused as the listing document id.
      final ListingImageUploadResult result = await uploadDataSource
          .uploadListingImages(imageFiles: imageFiles);

      return Right(result);
    } on ListingAccessException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ListingImageUploadException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (_) {
      // The message is kept generic on purpose: an unexpected error may
      // carry request details such as the authorization header.
      return const Left(
        ServerFailure(
          message: 'The photos could not be uploaded. Please try again.',
        ),
      );
    }
  }
}
