import '../domain/entities/listing_entity.dart';
import '../domain/entities/listing_host.dart';
import '../domain/entities/roommate.dart';

class ListingModel extends ListingEntity {
  const ListingModel({
    required super.id,
    required super.title,
    required super.description,
    required super.priceMonthly,
    required super.area,
    required super.roomType,
    required super.category,
    required super.furnished,
    required super.peopleCount,
    required super.spacesRemaining,
    required super.rules,
    required super.roommates,
    required super.host,
    required super.photoCount,
    required super.ownerId,
    super.photoPaths = const [],
    super.photoUrls = const [],
    super.isPublished = true,
  });

  factory ListingModel.fromMap({
    required String id,
    required Map<String, dynamic> map,
  }) {
    return ListingModel(
      id: id,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      priceMonthly: (map['priceMonthly'] as num?)?.toInt() ?? 0,
      area: map['area'] as String? ?? '',
      roomType: _parseRoomType(map['roomType']),
      category: _parseCategory(map['category']),
      furnished: map['furnished'] as bool? ?? false,
      peopleCount: (map['peopleCount'] as num?)?.toInt() ?? 0,
      spacesRemaining: (map['spacesRemaining'] as num?)?.toInt() ?? 0,
      rules: _parseRules(map['rules']),
      roommates: _parseRoommates(map['roommates']),
      host: _parseHost(map['host']),
      photoCount: (map['photoCount'] as num?)?.toInt() ?? 0,
      photoPaths: _parsePhotoPaths(map['photoPaths']),
      photoUrls: _parsePhotoUrls(map['photoUrls']),
      ownerId: map['ownerId'] as String? ?? '',
      isPublished: map['isPublished'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'priceMonthly': priceMonthly,
      'area': area,
      'roomType': roomType.name,
      'category': category.name,
      'furnished': furnished,
      'peopleCount': peopleCount,
      'spacesRemaining': spacesRemaining,
      'rules': rules,
      'roommates': roommates.map((roommate) {
  return {
    'initials': roommate.initials,
    'name': roommate.name,
    'tagline': roommate.tagline,
    'userId': roommate.userId,
  };
}).toList(),
      'host': {
        'initials': host.initials,
        'name': host.name,
        'responseTime': host.responseTime,
      },
      'photoCount': photoCount,
      'photoPaths': photoPaths,
      'photoUrls': photoUrls,
      'isPublished': isPublished,
      'ownerId': ownerId,
    };
  }

  static RoomType _parseRoomType(dynamic value) {
    for (final type in RoomType.values) {
      if (type.name == value) {
        return type;
      }
    }

    return RoomType.apartment;
  }

  static ListingCategory _parseCategory(dynamic value) {
    for (final category in ListingCategory.values) {
      if (category.name == value) {
        return category;
      }
    }

    return ListingCategory.apartment;
  }

  static List<String> _parseRules(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value.whereType<String>().toList();
  }

  static List<String> _parsePhotoPaths(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value.whereType<String>().toList();
  }

  /// Reads the public image urls. Documents written before this field
  /// existed simply deserialize to an empty list.
  static List<String> _parsePhotoUrls(dynamic value) {
    if (value is! List) {
      return const [];
    }

    return value.whereType<String>().toList();
  }

 static List<Roommate> _parseRoommates(dynamic value) {
  if (value is! List) {
    return const [];
  }

  return value.whereType<Map>().map((item) {
    final map = Map<String, dynamic>.from(item);

    return Roommate(
      initials: map['initials'] as String? ?? '',
      name: map['name'] as String? ?? '',
      tagline: map['tagline'] as String? ?? '',
      userId: map['userId'] as String?,
    );
  }).toList();
}

  static ListingHost _parseHost(dynamic value) {
    if (value is! Map) {
      return const ListingHost(initials: '', name: '', responseTime: '');
    }

    final map = Map<String, dynamic>.from(value);

    return ListingHost(
      initials: map['initials'] as String? ?? '',
      name: map['name'] as String? ?? '',
      responseTime: map['responseTime'] as String? ?? '',
    );
  }
}
