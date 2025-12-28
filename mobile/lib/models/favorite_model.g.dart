// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteModelAdapter extends TypeAdapter<FavoriteModel> {
  @override
  final int typeId = 4;

  @override
  FavoriteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      type: fields[2] as String,
      content: fields[3] as String,
      arabicText: fields[4] as String?,
      translation: fields[5] as String?,
      reference: fields[6] as String?,
      createdAt: fields[7] as DateTime,
      note: fields[8] as String?,
      tags: (fields[9] as List).cast<String>(),
      surahNumber: fields[10] as int?,
      ayahNumber: fields[11] as int?,
      surahName: fields[12] as String?,
      collection: fields[13] as String?,
      hadithNumber: fields[14] as String?,
      narrator: fields[15] as String?,
      conversationId: fields[16] as String?,
      messageId: fields[17] as String?,
      needsSync: fields[18] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteModel obj) {
    writer
      ..writeByte(19)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.arabicText)
      ..writeByte(5)
      ..write(obj.translation)
      ..writeByte(6)
      ..write(obj.reference)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.note)
      ..writeByte(9)
      ..write(obj.tags)
      ..writeByte(10)
      ..write(obj.surahNumber)
      ..writeByte(11)
      ..write(obj.ayahNumber)
      ..writeByte(12)
      ..write(obj.surahName)
      ..writeByte(13)
      ..write(obj.collection)
      ..writeByte(14)
      ..write(obj.hadithNumber)
      ..writeByte(15)
      ..write(obj.narrator)
      ..writeByte(16)
      ..write(obj.conversationId)
      ..writeByte(17)
      ..write(obj.messageId)
      ..writeByte(18)
      ..write(obj.needsSync);
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
