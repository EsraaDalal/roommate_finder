import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/config/supabase_config.dart';
import '../../../../core/errors/exception.dart';
import '../../domain/entities/listing_image_upload_result.dart';

/// Name of the Supabase Edge Function that performs authenticated uploads.
const String kUploadListingImagesFunction = 'upload-listing-images';

/// Multipart field name expected by the deployed Edge Function.
const String kUploadListingImagesField = 'files';

/// Multipart field used to suggest a storage folder name to the function.
const String kUploadListingImagesListingIdField = 'listingId';

/// Maximum number of images accepted in a single upload.
const int kMaxListingImages = 6;

/// Maximum size, in bytes, of a single image accepted by the Edge Function.
const int kMaxListingImageBytes = 5 * 1024 * 1024;

/// File extensions accepted by the Edge Function.
const Set<String> kAllowedListingImageExtensions = <String>{
  '.jpg',
  '.jpeg',
  '.png',
  '.webp',
};

/// Uploads listing images through the Supabase Edge Function.
abstract class ListingImageUploadDataSource {
  /// Uploads [imageFiles] and returns the stored paths and public URLs.
  ///
  /// The deployed Edge Function generates the storage folder identifier
  /// itself, so [listingId] is only an optional hint and is normally left
  /// unset. Callers must always use the returned
  /// [ListingImageUploadResult.listingId], which is authoritative.
  ///
  /// [onProgress] and [cancelToken] are optional hooks so the presentation
  /// layer can later show upload progress and allow the user to abort.
  ///
  /// Throws [ListingAccessException] when there is no authenticated user or
  /// no usable ID token, and [ListingImageUploadException] for every other
  /// failure.
  Future<ListingImageUploadResult> uploadListingImages({
    required List<File> imageFiles,
    String? listingId,
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  });
}

/// Dio based implementation of [ListingImageUploadDataSource].
///
/// The request is authenticated with a Firebase ID token in the
/// `Authorization: Bearer <token>` header. The Edge Function verifies that
/// token server-side and derives the user id from it, so no uid is ever
/// trusted from the client.
class ListingImageUploadDataSourceImpl implements ListingImageUploadDataSource {
  final Dio dio;
  final FirebaseAuth firebaseAuth;

  ListingImageUploadDataSourceImpl({
    required this.dio,
    required this.firebaseAuth,
  });

  /// Endpoint of the deployed Edge Function, derived from the Supabase
  /// configuration so the project url is never hard-coded here.
  String get _functionUrl =>
      '${SupabaseConfig.url}/functions/v1/$kUploadListingImagesFunction';

  @override
  Future<ListingImageUploadResult> uploadListingImages({
    required List<File> imageFiles,
    String? listingId,
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    if (!SupabaseConfig.isConfigured) {
      throw const ListingImageUploadException(
        'Image storage is not configured for this build.',
      );
    }

    _validateFiles(imageFiles);

    final String idToken = await _resolveIdToken();

    final FormData formData = FormData();
    for (final File file in imageFiles) {
      formData.files.add(
        MapEntry<String, MultipartFile>(
          kUploadListingImagesField,
          await MultipartFile.fromFile(
            file.path,
            filename: _fileNameOf(file),
            contentType: MultipartFile.lookupMediaType(file.path),
          ),
        ),
      );
    }

    final String? requestedFolder = listingId?.trim();
    if (requestedFolder != null && requestedFolder.isNotEmpty) {
      // The deployed function is documented as generating its own folder
      // identifier. This field is sent as a hint only and the caller must
      // use the identifier returned in the response.
      formData.fields.add(
        MapEntry<String, String>(
          kUploadListingImagesListingIdField,
          requestedFolder,
        ),
      );
    }

    final Response<dynamic> response;
    try {
      response = await dio.post<dynamic>(
        _functionUrl,
        data: formData,
        options: Options(
          headers: <String, dynamic>{
            'apikey': SupabaseConfig.publishableKey,
            'Authorization': 'Bearer $idToken',
          },
          // Content-Type is deliberately not set so Dio can add the multipart
          // boundary itself.
        ),
        onSendProgress: onProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (error) {
      throw _mapDioException(error);
    }

    return _parseResult(response.data);
  }

  /// Returns a valid Firebase ID token for the signed-in user.
  ///
  /// [User.getIdToken] refreshes the token automatically when it has expired,
  /// so the token is always current at the moment of the request.
  Future<String> _resolveIdToken() async {
    final User? user = firebaseAuth.currentUser;

    if (user == null) {
      throw const ListingAccessException(
        'You must be signed in to upload listing photos.',
      );
    }

    final String? token = await user.getIdToken();

    if (token == null || token.isEmpty) {
      throw const ListingAccessException(
        'Your session has expired. Please sign in again to upload photos.',
      );
    }

    return token;
  }

  /// Mirrors the limits documented for the Edge Function.
  ///
  /// These checks only give fast feedback; the server remains the authority
  /// on the accepted file types and sizes.
  void _validateFiles(List<File> imageFiles) {
    if (imageFiles.isEmpty) {
      throw const ListingImageUploadException(
        'Select at least one photo to upload.',
      );
    }

    if (imageFiles.length > kMaxListingImages) {
      throw ListingImageUploadException(
        'You can upload up to $kMaxListingImages photos at a time.',
      );
    }

    for (final File file in imageFiles) {
      if (!file.existsSync()) {
        throw const ListingImageUploadException(
          'One of the selected photos is no longer available.',
        );
      }

      if (file.lengthSync() > kMaxListingImageBytes) {
        throw const ListingImageUploadException(
          'Each photo must be smaller than 5 MB.',
        );
      }

      if (!kAllowedListingImageExtensions.contains(_extensionOf(file.path))) {
        throw const ListingImageUploadException(
          'Photos must be JPEG, PNG, or WebP files.',
        );
      }
    }
  }

  /// Converts a Dio failure into a typed, user-safe error.
  ///
  /// The Dio exception itself is never surfaced because its string form
  /// contains the request options, including the `Authorization` header.
  ListingImageUploadException _mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const ListingImageUploadException(
          'The upload timed out. Please check your connection and try again.',
        );
      case DioExceptionType.cancel:
        return const ListingImageUploadException('The upload was cancelled.');
      case DioExceptionType.connectionError:
        return const ListingImageUploadException(
          'Could not reach the image service. Please check your connection.',
        );
      case DioExceptionType.badResponse:
        return ListingImageUploadException(
          _serverMessage(error.response?.data) ??
              'The image service rejected the upload '
                  '(HTTP ${error.response?.statusCode ?? 0}).',
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.unknown:
        return const ListingImageUploadException(
          'The image upload failed. Please try again.',
        );
    }
  }

  /// Reads the `error` or `message` field of a JSON error body.
  ///
  /// Only these known fields are echoed back, so no request data can leak
  /// into a user facing message.
  String? _serverMessage(dynamic data) {
    if (data is! Map) {
      return null;
    }

    final Object? value = data['error'] ?? data['message'];
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    return null;
  }

  /// Validates and maps the Edge Function response body.
  ListingImageUploadResult _parseResult(dynamic data) {
    if (data is! Map) {
      throw const ListingImageUploadException(
        'The image service returned an unexpected response.',
      );
    }

    final Object? listingId = data['listingId'];
    if (listingId is! String || listingId.trim().isEmpty) {
      throw const ListingImageUploadException(
        'The image service did not return a listing identifier.',
      );
    }

    final List<String> paths = _stringList(data['photoPaths']);
    final List<String> urls = _stringList(data['photoUrls']);

    if (paths.isEmpty || urls.isEmpty || paths.length != urls.length) {
      throw const ListingImageUploadException(
        'The image service returned an incomplete list of uploaded images.',
      );
    }

    return ListingImageUploadResult(
      listingId: listingId.trim(),
      photoPaths: paths,
      photoUrls: urls,
    );
  }

  List<String> _stringList(dynamic value) {
    if (value is! List) {
      return const <String>[];
    }

    return value
        .whereType<String>()
        .where((String item) => item.trim().isNotEmpty)
        .toList(growable: false);
  }

  String _fileNameOf(File file) {
    final int separator = file.path.lastIndexOf(RegExp(r'[/\\]'));
    if (separator == -1) {
      return file.path;
    }
    return file.path.substring(separator + 1);
  }

  String _extensionOf(String path) {
    final int dotIndex = path.lastIndexOf('.');
    if (dotIndex == -1 || dotIndex == path.length - 1) {
      return '';
    }
    return path.substring(dotIndex).toLowerCase();
  }
}
