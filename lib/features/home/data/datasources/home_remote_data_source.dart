
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/models/listing_model.dart';



abstract class HomeRemoteDataSource {
  Future<List<ListingModel>> getHomeListings();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  HomeRemoteDataSourceImpl({
    required this._firestore,
  });

  final FirebaseFirestore _firestore;

  @override
  Future<List<ListingModel>> getHomeListings() async {
    final snapshot = await _firestore.collection('listings').get();

    return snapshot.docs.map((document) {
      return ListingModel.fromMap(
        id: document.id,
        map: document.data(),
      );
    }).toList();
  }
}
