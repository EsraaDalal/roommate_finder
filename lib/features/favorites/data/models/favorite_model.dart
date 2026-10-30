


import 'package:hive_flutter/hive_flutter.dart';

import '../../domain/entities/favorite_listing_entity.dart';
import '../../domain/entities/favorite_listing_host.dart';
import '../../domain/entities/favorite_listong_roommate.dart';


part 'favorite_model.g.dart';

@HiveType(typeId: 0)
class FavoriteModel {
  const FavoriteModel({
    required this.id,
    required this.title,
    required this.description,
    required this.priceMonthly,
    required this.area,
    required this.roomTypeIndex,
    required this.categoryIndex,
    required this.furnished,
    required this.peopleCount,
    required this.spacesRemaining,
    required this.rules,
    required this.roommatesData,
    required this.hostData,
    required this.photoCount,
    required this.ownerId,
    required this.userId,
    required this.addedAt,
    this.photoPaths = const [],
    this.photoUrls = const [],
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final int priceMonthly;

  @HiveField(4)
  final String area;


  @HiveField(5)
  final int roomTypeIndex;

  @HiveField(6)
  final int categoryIndex;

  @HiveField(7)
  final bool furnished;

  @HiveField(8)
  final int peopleCount;

  @HiveField(9)
  final int spacesRemaining;

  @HiveField(10)
  final List<String> rules;

  /// Nested data is stored as Hive-supported maps.
  @HiveField(11)
  final List<Map<dynamic, dynamic>> roommatesData;

  @HiveField(12)
  final Map<dynamic, dynamic> hostData;

  @HiveField(13)
  final int photoCount;

  @HiveField(14)
  final String ownerId;

  @HiveField(15)
  final String? userId;

  @HiveField(16)
  final List<String> photoPaths;

  @HiveField(17)
  final List<String> photoUrls;

  @HiveField(18)
  final DateTime addedAt;


  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priceMonthly': priceMonthly,
      'area': area,
      'roomType': FavoriteRoomType.values[roomTypeIndex].name,
      'category': FavoriteListingCategory.values[categoryIndex].name,
      'furnished': furnished,
      'peopleCount': peopleCount,
      'spacesRemaining': spacesRemaining,
      'rules': rules,
      'roommates': roommatesData
          .map((roommate) => Map<String, dynamic>.from(roommate))
          .toList(),
      'host': Map<String, dynamic>.from(hostData),
      'photoCount': photoCount,
      'ownerId': ownerId,
      'userId': userId,
      'photoPaths': photoPaths,
      'photoUrls': photoUrls,
      'addedAt': addedAt.toIso8601String(),
    };
  }

  factory FavoriteModel.fromMap(Map<String, dynamic> map) {
    final roomTypeName = map['roomType'] as String;
    final categoryName = map['category'] as String;

    return FavoriteModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      priceMonthly: (map['priceMonthly'] as num).toInt(),
      area: map['area'] as String,
      roomTypeIndex: FavoriteRoomType.values.byName(roomTypeName).index,
      categoryIndex:
          FavoriteListingCategory.values.byName(categoryName).index,
      furnished: map['furnished'] as bool,
      peopleCount: (map['peopleCount'] as num).toInt(),
      spacesRemaining: (map['spacesRemaining'] as num).toInt(),
      rules: List<String>.from(map['rules'] as List? ?? const []),
      roommatesData: (map['roommates'] as List? ?? const [])
          .map(
            (item) => Map<dynamic, dynamic>.from(item as Map),
          )
          .toList(),
      hostData: Map<dynamic, dynamic>.from(
        map['host'] as Map,
      ),
      photoCount: (map['photoCount'] as num).toInt(),
      ownerId: map['ownerId'] as String,
      userId: (map['userId'] as num).toString(),
      photoPaths: List<String>.from(
        map['photoPaths'] as List? ?? const [],
      ),
      photoUrls: List<String>.from(
        map['photoUrls'] as List? ?? const [],
      ),
      addedAt: DateTime.parse(map['addedAt'] as String),
    );
  }
  factory FavoriteModel.fromEntity({
  required FavoriteListingEntity entity,
}) {
  return FavoriteModel(
    id: entity.id,
    title: entity.title,
    description: entity.description,
    priceMonthly: entity.priceMonthly,
    area: entity.area,
    roomTypeIndex: entity.roomType.index,
    categoryIndex: entity.category.index,
    furnished: entity.furnished,
    peopleCount: entity.peopleCount,
    spacesRemaining: entity.spacesRemaining,
    rules: entity.rules,
  roommatesData: entity.roommates
    .map(_roommateToMap)
    .toList(),

hostData: _hostToMap(entity.host),
    photoCount: entity.photoCount,
    ownerId: entity.ownerId,
    userId: entity.userId,
    photoPaths: entity.photoPaths,
    photoUrls: entity.photoUrls,
    addedAt: DateTime.now(),
  );
}

FavoriteListingEntity toEntity() {
  return FavoriteListingEntity(
    id: id,
    title: title,
    description: description,
    priceMonthly: priceMonthly,
    area: area,
    roomType: FavoriteRoomType.values[roomTypeIndex],
    category: FavoriteListingCategory.values[categoryIndex],
    furnished: furnished,
    peopleCount: peopleCount,
    spacesRemaining: spacesRemaining,
    userId: userId,
    rules: rules,
  roommates: roommatesData
    .map(_roommateFromMap)
    .toList(),

host: _hostFromMap(hostData),
    photoPaths: photoPaths,
    photoUrls: photoUrls,
    photoCount: photoCount,
    ownerId: ownerId,
  );
}


static Map<String, dynamic> _hostToMap(
  FavoriteListingHost host,
) {
  return {
    'initials': host.initials,
    'name': host.name,
    'responseTime': host.responseTime,
  };
}

static FavoriteListingHost _hostFromMap(
  Map<dynamic, dynamic> map,
) {
  return FavoriteListingHost(
    initials: map['initials'] as String,
    name: map['name'] as String,
    responseTime: map['responseTime'] as String,
  );
}

static Map<String, dynamic> _roommateToMap(
  FavoriteListongRoommate roommate,
) {
  return {
    'initials': roommate.initials,
    'name': roommate.name,
    'tagline': roommate.tagline,
  };
}

static FavoriteListongRoommate _roommateFromMap(
  Map<dynamic, dynamic> map,
) {
  return FavoriteListongRoommate(
    initials: map['initials'] as String,
    name: map['name'] as String,
    tagline: map['tagline'] as String,
  );
}
}