// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hadith_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HadithModelAdapter extends TypeAdapter<HadithModel> {
  @override
  final int typeId = 7;

  @override
  HadithModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HadithModel(
      id: fields[0] as String,
      collection: fields[1] as String,
      hadithNumber: fields[2] as String,
      arabicText: fields[3] as String,
      translation: fields[4] as String,
      narrator: fields[5] as String?,
      chapter: fields[6] as String?,
      book: fields[7] as String?,
      grade: fields[8] as String?,
      gradeSource: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, HadithModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.collection)
      ..writeByte(2)
      ..write(obj.hadithNumber)
      ..writeByte(3)
      ..write(obj.arabicText)
      ..writeByte(4)
      ..write(obj.translation)
      ..writeByte(5)
      ..write(obj.narrator)
      ..writeByte(6)
      ..write(obj.chapter)
      ..writeByte(7)
      ..write(obj.book)
      ..writeByte(8)
      ..write(obj.grade)
      ..writeByte(9)
      ..write(obj.gradeSource);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HadithModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
