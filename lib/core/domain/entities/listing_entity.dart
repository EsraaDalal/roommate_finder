import 'package:flutter/foundation.dart';

import 'listing_host.dart';
import 'roommate.dart';

enum ListingCategory { apartment, university }

enum RoomType {
  apartment('Apartment'),
  house('House'),
  studio('Studio'),
  universityRoom('University room');

  const RoomType(this.label);

  final String label;
}

@immutable
class ListingEntity {
  const ListingEntity({
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
    this.photoPaths = const [],
    this.photoUrls = const [],
    this.isPublished = true,
  });

  final String id;
  final String title;
  final String description;
  final int priceMonthly;
  final String area;

  final RoomType roomType;
  final ListingCategory category;
  final bool furnished;

  final int peopleCount;
  final int spacesRemaining;

  final List<String> rules;
  final List<Roommate> roommates;
  final ListingHost host;

  /// Paths of uploaded images in Supabase Storage.
  final List<String> photoPaths;

  /// Publicly reachable URLs of the uploaded images.
  ///
  /// Empty for listings created without photos, and for documents written
  /// before this field existed.
  final List<String> photoUrls;

  /// Kept for compatibility with existing code.
  final int photoCount;

  final bool isPublished;
  final String ownerId;

  String get furnishedLabel => furnished ? 'Furnished' : 'Unfurnished';

  /// Returns a copy of this listing with the given fields replaced.
  ///
  /// Null arguments keep the current value. Used by the creation flow to
  /// apply the identifiers and photo fields returned by the image upload.
  ListingEntity copyWith({
    String? id,
    String? title,
    String? description,
    int? priceMonthly,
    String? area,
    RoomType? roomType,
    ListingCategory? category,
    bool? furnished,
    int? peopleCount,
    int? spacesRemaining,
    List<String>? rules,
    List<Roommate>? roommates,
    ListingHost? host,
    int? photoCount,
    String? ownerId,
    List<String>? photoPaths,
    List<String>? photoUrls,
    bool? isPublished,
  }) {
    return ListingEntity(
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
      isPublished: isPublished ?? this.isPublished,
    );
  }
}
