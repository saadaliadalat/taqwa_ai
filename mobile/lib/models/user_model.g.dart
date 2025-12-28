// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      id: fields[0] as String,
      email: fields[1] as String?,
      displayName: fields[2] as String?,
      isGuest: fields[3] as bool,
      photoUrl: fields[4] as String?,
      createdAt: fields[5] as DateTime,
      lastActiveAt: fields[6] as DateTime,
      madhhab: fields[7] as String,
      language: fields[8] as String,
      notificationsEnabled: fields[9] as bool,
      dailyAyahEnabled: fields[10] as bool,
      dailyAyahTime: fields[11] as String?,
      darkModeEnabled: fields[12] as bool,
      quranFontSize: fields[13] as int,
      showTranslation: fields[14] as bool,
      translationLanguage: fields[15] as String,
      purposes: (fields[16] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.displayName)
      ..writeByte(3)
      ..write(obj.isGuest)
      ..writeByte(4)
      ..write(obj.photoUrl)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.lastActiveAt)
      ..writeByte(7)
      ..write(obj.madhhab)
      ..writeByte(8)
      ..write(obj.language)
      ..writeByte(9)
      ..write(obj.notificationsEnabled)
      ..writeByte(10)
      ..write(obj.dailyAyahEnabled)
      ..writeByte(11)
      ..write(obj.dailyAyahTime)
      ..writeByte(12)
      ..write(obj.darkModeEnabled)
      ..writeByte(13)
      ..write(obj.quranFontSize)
      ..writeByte(14)
      ..write(obj.showTranslation)
      ..writeByte(15)
      ..write(obj.translationLanguage)
      ..writeByte(16)
      ..write(obj.purposes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
