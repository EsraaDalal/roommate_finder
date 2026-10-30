import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/exception.dart';
import '../../../../core/models/listing_model.dart';

abstract class ListingRemoteDataSource {
  Future<ListingModel> createListing({required ListingModel listing});

  Future<List<ListingModel>> getMyListings({required String ownerId});

  Future<ListingModel> updateListing({required ListingModel listing});

  Future<void> deleteListing({
    required String listingId,
    required String ownerId,
  });
  Future<ListingModel> getListingById({
  required String listingId,
});
}

class ListingRemoteDataSourceImpl implements ListingRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth firebaseAuth;

  ListingRemoteDataSourceImpl({
    required this.firestore,
    required this.firebaseAuth,
  });

  CollectionReference<Map<String, dynamic>> get _listingsCollection {
    return firestore.collection('listings');
  }

  User _requireCurrentUser() {
    final user = firebaseAuth.currentUser;

    if (user == null) {
      throw ListingAccessException('You must be signed in to manage listings.');
    }

    return user;
  }

  @override
  Future<ListingModel> createListing({required ListingModel listing}) async {
    final user = _requireCurrentUser();

    // A caller may supply the id that the image storage service assigned, so
    // the storage folder and the listing document share the same id. When no
    // id is supplied the document id is generated in Firestore as before.
    final document = listing.id.isEmpty
        ? _listingsCollection.doc()
        : _listingsCollection.doc(listing.id);

    if (listing.id.isNotEmpty) {
      // Creating must never overwrite an existing listing.
      final snapshot = await document.get();

      if (snapshot.exists) {
        throw ListingAccessException('A listing with this id already exists.');
      }
    }

    // Never trust an ownerId supplied by the UI.
    final model = _copyWithIdentity(
      listing,
      id: document.id,
      ownerId: user.uid,
    );

    await document.set(model.toMap());

    return model;
  }

  @override
  Future<List<ListingModel>> getMyListings({required String ownerId}) async {
    final user = _requireCurrentUser();

    if (ownerId != user.uid) {
      throw ListingAccessException('You can only retrieve your own listings.');
    }

    final snapshot = await _listingsCollection
        .where('ownerId', isEqualTo: user.uid)
        .get();

    return snapshot.docs.map((document) {
      return ListingModel.fromMap(id: document.id, map: document.data());
    }).toList();
  }

  @override
  Future<ListingModel> updateListing({required ListingModel listing}) async {
    final user = _requireCurrentUser();

    if (listing.ownerId != user.uid) {
      throw ListingAccessException('You can only update your own listings.');
    }

    final document = _listingsCollection.doc(listing.id);
    final snapshot = await document.get();

    if (!snapshot.exists) {
      throw ListingNotFoundException('The listing could not be found.');
    }

    final existingData = snapshot.data();

    if (existingData == null || existingData['ownerId'] != user.uid) {
      throw ListingAccessException(
        'You do not have permission to update this listing.',
      );
    }

    // Keep the document ID and owner tied to the verified values.
    final model = _copyWithIdentity(
      listing,
      id: document.id,
      ownerId: user.uid,
    );

    await document.update(model.toMap());

    return model;
  }

  @override
  Future<void> deleteListing({
    required String listingId,
    required String ownerId,
  }) async {
    final user = _requireCurrentUser();

    if (ownerId != user.uid) {
      throw ListingAccessException('You can only delete your own listings.');
    }

    final document = _listingsCollection.doc(listingId);
    final snapshot = await document.get();

    if (!snapshot.exists) {
      throw ListingNotFoundException('The listing could not be found.');
    }

    final existingData = snapshot.data();

    if (existingData == null || existingData['ownerId'] != user.uid) {
      throw ListingAccessException(
        'You do not have permission to delete this listing.',
      );
    }

    await document.delete();
  }

  ListingModel _copyWithIdentity(
    ListingModel listing, {
    required String id,
    required String ownerId,
  }) {
    return ListingModel(
      id: id,
      title: listing.title,
      description: listing.description,
      priceMonthly: listing.priceMonthly,
      area: listing.area,
      roomType: listing.roomType,
      category: listing.category,
      furnished: listing.furnished,
      peopleCount: listing.peopleCount,
      spacesRemaining: listing.spacesRemaining,
      rules: listing.rules,
      roommates: listing.roommates,
      host: listing.host,
      photoCount: listing.photoCount,
      photoPaths: listing.photoPaths,
      photoUrls: listing.photoUrls,
      isPublished: listing.isPublished,
      ownerId: ownerId,
    );
  }

  @override
Future<ListingModel> getListingById({
  required String listingId,
}) async {
  _requireCurrentUser();

  final snapshot = await firestore
      .collection('listings')
      .doc(listingId)
      .get();

  final data = snapshot.data();

  if (!snapshot.exists || data == null) {
    throw Exception('Listing not found');
  }

  return ListingModel.fromMap(
    id: snapshot.id,
    map: data,
  );
}
}
