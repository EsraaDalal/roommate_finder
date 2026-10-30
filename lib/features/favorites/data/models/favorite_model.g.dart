// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteModelAdapter extends TypeAdapter<FavoriteModel> {
  @override
  final int typeId = 0;

  @override
  FavoriteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteModel(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      priceMonthly: fields[3] as int,
      area: fields[4] as String,
      roomTypeIndex: fields[5] as int,
      categoryIndex: fields[6] as int,
      furnished: fields[7] as bool,
      peopleCount: fields[8] as int,
      spacesRemaining: fields[9] as int,
      rules: (fields[10] as List).cast<String>(),
      roommatesData: (fields[11] as List)
          .map((dynamic e) => (e as Map).cast<dynamic, dynamic>())
          .toList(),
      hostData: (fields[12] as Map).cast<dynamic, dynamic>(),
      photoCount: fields[13] as int,
      ownerId: fields[14] as String,
      userId: fields[15] as String?,
      addedAt: fields[18] as DateTime,
      photoPaths: (fields[16] as List).cast<String>(),
      photoUrls: (fields[17] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.priceMonthly)
      ..writeByte(4)
      ..write(obj.area)
      ..writeByte(5)
      ..write(obj.roomTypeIndex)
      ..writeByte(6)
      ..write(obj.categoryIndex)
      ..writeByte(7)
      ..write(obj.furnished)
      ..writeByte(8)
      ..write(obj.peopleCount)
      ..writeByte(9)
      ..write(obj.spacesRemaining)
      ..writeByte(10)
      ..write(obj.rules)
      ..writeByte(11)
      ..write(obj.roommatesData)
      ..writeByte(12)
      ..write(obj.hostData)
      ..writeByte(13)
      ..write(obj.photoCount)
      ..writeByte(14)
      ..write(obj.ownerId)
      ..writeByte(15)
      ..write(obj.userId)
      ..writeByte(16)
      ..write(obj.photoPaths)
      ..writeByte(17)
      ..write(obj.photoUrls)
      ..writeByte(18)
      ..write(obj.addedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
