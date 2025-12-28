// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ayah_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AyahModelAdapter extends TypeAdapter<AyahModel> {
  @override
  final int typeId = 6;

  @override
  AyahModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AyahModel(
      number: fields[0] as int,
      numberInSurah: fields[1] as int,
      surahNumber: fields[2] as int,
      text: fields[3] as String,
      translation: fields[4] as String?,
      translationLanguage: fields[5] as String?,
      tafsir: fields[6] as String?,
      juz: fields[7] as int,
      page: fields[8] as int,
      hizbQuarter: fields[9] as int,
      sajda: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AyahModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.number)
      ..writeByte(1)
      ..write(obj.numberInSurah)
      ..writeByte(2)
      ..write(obj.surahNumber)
      ..writeByte(3)
      ..write(obj.text)
      ..writeByte(4)
      ..write(obj.translation)
      ..writeByte(5)
      ..write(obj.translationLanguage)
      ..writeByte(6)
      ..write(obj.tafsir)
      ..writeByte(7)
      ..write(obj.juz)
      ..writeByte(8)
      ..write(obj.page)
      ..writeByte(9)
      ..write(obj.hizbQuarter)
      ..writeByte(10)
      ..write(obj.sajda);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AyahModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
