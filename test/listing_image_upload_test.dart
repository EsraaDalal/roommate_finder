import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rommate_finder/core/errors/exception.dart';
import 'package:rommate_finder/core/errors/failure.dart';
import 'package:rommate_finder/features/hosting/data/datasources/listing_image_upload_data_source.dart';
import 'package:rommate_finder/core/models/listing_model.dart';
import 'package:rommate_finder/features/hosting/data/repositories/listing_image_repository_impl.dart';
import 'package:rommate_finder/core/domain/entities/listing_entity.dart';
import 'package:rommate_finder/core/domain/entities/listing_host.dart';
import 'package:rommate_finder/features/hosting/domain/entities/listing_image_upload_result.dart';
import 'package:rommate_finder/core/domain/entities/roommate.dart';

ListingModel buildModel({
  String id = 'listing-1',
  List<String> photoPaths = const [],
  List<String> photoUrls = const [],
}) {
  return ListingModel(
    id: id,
    title: 'Bright room near campus',
    description: 'A calm, sun-filled room.',
    priceMonthly: 680,
    area: 'Downtown, Austin',
    roomType: RoomType.apartment,
    category: ListingCategory.apartment,
    furnished: true,
    peopleCount: 3,
    spacesRemaining: 1,
    rules: const <String>['No smoking'],
    roommates: const <Roommate>[],
    host: const ListingHost(
      initials: 'SM',
      name: 'Sarah Miller',
      responseTime: 'Usually responds within an hour',
    ),
    photoCount: photoPaths.length,
    ownerId: 'user-alex',
    photoPaths: photoPaths,
    photoUrls: photoUrls,
  );
}

/// Fake upload data source that returns a canned result or throws.
class _FakeUploadDataSource implements ListingImageUploadDataSource {
  _FakeUploadDataSource({this.result, this.error});

  final ListingImageUploadResult? result;
  final Object? error;

  /// Paths the repository asked to upload.
  List<String> requestedPaths = <String>[];

  @override
  Future<ListingImageUploadResult> uploadListingImages({
    required List<File> imageFiles,
    String? listingId,
    ProgressCallback? onProgress,
    CancelToken? cancelToken,
  }) async {
    requestedPaths = imageFiles
        .map((File file) => file.path)
        .toList(growable: false);

    if (error != null) {
      throw error!;
    }

    return result!;
  }
}

void main() {
  group('ListingModel photo fields', () {
    test('serialises photoPaths and photoUrls', () {
      final ListingModel model = buildModel(
        photoPaths: const <String>['listings/u/1/a.jpg'],
        photoUrls: const <String>['https://example.test/a.jpg'],
      );

      final Map<String, dynamic> map = model.toMap();

      expect(map['photoPaths'], <String>['listings/u/1/a.jpg']);
      expect(map['photoUrls'], <String>['https://example.test/a.jpg']);
      expect(map['photoCount'], 1);
    });

    test('deserialises documents that have no photoUrls field', () {
      final ListingModel model = ListingModel.fromMap(
        id: 'legacy-1',
        map: <String, dynamic>{
          'title': 'Older listing',
          'photoCount': 3,
          'photoPaths': <String>['listings/u/legacy/a.jpg'],
        },
      );

      expect(model.photoPaths, <String>['listings/u/legacy/a.jpg']);
      expect(model.photoUrls, isEmpty);
      expect(model.photoCount, 3);
    });

    test('round trips the photo fields', () {
      final ListingModel model = buildModel(
        photoPaths: const <String>['listings/u/1/a.jpg', 'listings/u/1/b.jpg'],
        photoUrls: const <String>[
          'https://example.test/a.jpg',
          'https://example.test/b.jpg',
        ],
      );

      final ListingModel restored = ListingModel.fromMap(
        id: model.id,
        map: model.toMap(),
      );

      expect(restored.photoPaths, model.photoPaths);
      expect(restored.photoUrls, model.photoUrls);
      expect(restored.photoCount, model.photoCount);
    });
  });

  group('ListingImageRepositoryImpl', () {
    test('returns the upload result on success', () async {
      const ListingImageUploadResult expected = ListingImageUploadResult(
        listingId: 'folder-1',
        photoPaths: <String>['listings/u/folder-1/a.jpg'],
        photoUrls: <String>['https://example.test/a.jpg'],
      );

      final _FakeUploadDataSource dataSource = _FakeUploadDataSource(
        result: expected,
      );
      final ListingImageRepositoryImpl repository = ListingImageRepositoryImpl(
        uploadDataSource: dataSource,
      );

      final result = await repository.uploadListingImages(
        filePaths: <String>['/tmp/a.jpg'],
      );

      expect(result.isRight(), isTrue);
      expect(
        result.getOrElse(() => throw StateError('unreachable')).listingId,
        'folder-1',
      );
      expect(dataSource.requestedPaths, <String>['/tmp/a.jpg']);
    });

    test('maps a missing authentication to an AuthFailure', () async {
      final _FakeUploadDataSource dataSource = _FakeUploadDataSource(
        error: const ListingAccessException('You must be signed in.'),
      );
      final ListingImageRepositoryImpl repository = ListingImageRepositoryImpl(
        uploadDataSource: dataSource,
      );

      final result = await repository.uploadListingImages(
        filePaths: <String>['/tmp/a.jpg'],
      );

      expect(result.isLeft(), isTrue);
      expect(
        result.fold((Failure failure) => failure, (_) => null),
        isA<AuthFailure>(),
      );
    });

    test('maps an upload failure to a ServerFailure', () async {
      final _FakeUploadDataSource dataSource = _FakeUploadDataSource(
        error: const ListingImageUploadException('The upload timed out.'),
      );
      final ListingImageRepositoryImpl repository = ListingImageRepositoryImpl(
        uploadDataSource: dataSource,
      );

      final result = await repository.uploadListingImages(
        filePaths: <String>['/tmp/a.jpg'],
      );

      expect(result.isLeft(), isTrue);
      final Failure failure = result.fold(
        (Failure value) => value,
        (_) => throw StateError('x'),
      );
      expect(failure, isA<ServerFailure>());
      expect(failure.message, 'The upload timed out.');
    });

    test('does not leak unexpected error details', () async {
      final _FakeUploadDataSource dataSource = _FakeUploadDataSource(
        error: StateError('Authorization: Bearer secret-token'),
      );
      final ListingImageRepositoryImpl repository = ListingImageRepositoryImpl(
        uploadDataSource: dataSource,
      );

      final result = await repository.uploadListingImages(
        filePaths: <String>['/tmp/a.jpg'],
      );

      final Failure failure = result.fold(
        (Failure value) => value,
        (_) => throw StateError('x'),
      );
      expect(failure.message, isNot(contains('secret-token')));
    });
  });
}
