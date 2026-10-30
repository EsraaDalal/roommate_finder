import 'package:flutter/foundation.dart';
import 'package:rommate_finder/features/favorites/domain/entities/favorite_listing_host.dart';
import 'package:rommate_finder/features/favorites/domain/entities/favorite_listong_roommate.dart';

enum FavoriteListingCategory { apartment, university }

enum FavoriteRoomType {
  apartment('Apartment'),
  house('House'),
  studio('Studio'),
  universityRoom('University room');

  const FavoriteRoomType(this.label);

  final String label;
}

@immutable
class FavoriteListingEntity {
  const FavoriteListingEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.priceMonthly,
    required this.area,
    required this.roomType,
    required this.category,
    required this.furnished,
    required this.peopleCount,
    required this.spacesRemaining,
    required this.rules,
    required this.roommates,
    required this.host,
    required this.photoCount,
    required this.ownerId,
    required this.userId,
    this.photoPaths = const [],
    this.photoUrls = const [],
 
  });

  final String id;
  final String title;
  final String description;
  final int priceMonthly;
  final String area;

  final FavoriteRoomType roomType;
  final FavoriteListingCategory category;
  final bool furnished;

  final int peopleCount;
  final int spacesRemaining;
  final String? userId;

  final List<String> rules;
  final List<FavoriteListongRoommate> roommates;
  final FavoriteListingHost host;

  /// Paths of uploaded images in Supabase Storage.
  final List<String> photoPaths;

  /// Publicly reachable URLs of the uploaded images.
  ///
  /// Empty for listings created without photos, and for documents written
  /// before this field existed.
  final List<String> photoUrls;

  /// Kept for compatibility with existing code.
  final int photoCount;


  final String ownerId;

  String get furnishedLabel => furnished ? 'Furnished' : 'Unfurnished';

  /// Returns a copy of this listing with the given fields replaced.
  ///
  /// Null arguments keep the current value. Used by the creation flow to
  /// apply the identifiers and photo fields returned by the image upload.
  FavoriteListingEntity copyWith({
    String? id,
    String? title,
    String? description,
    int? priceMonthly,
    String? area,
    FavoriteRoomType? roomType,
    FavoriteListingCategory? category,
    bool? furnished,
    int? peopleCount,
    int? spacesRemaining,
    List<String>? rules,
    List<FavoriteListongRoommate>? roommates,
    FavoriteListingHost? host,
    int? photoCount,
    String? ownerId,
    List<String>? photoPaths,
    List<String>? photoUrls,
    bool? isPublished,
  }) {
    return FavoriteListingEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priceMonthly: priceMonthly ?? this.priceMonthly,
      area: area ?? this.area,
      roomType: roomType ?? this.roomType,
      category: category ?? this.category,
      furnished: furnished ?? this.furnished,
      peopleCount: peopleCount ?? this.peopleCount,
      spacesRemaining: spacesRemaining ?? this.spacesRemaining,
      rules: rules ?? this.rules,
      roommates: roommates ?? this.roommates,
      host: host ?? this.host,
      photoCount: photoCount ?? this.photoCount,
      ownerId: ownerId ?? this.ownerId,
      photoPaths: photoPaths ?? this.photoPaths,
      photoUrls: photoUrls ?? this.photoUrls,
   
       userId: userId,
    );
  }
}
