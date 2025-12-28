// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SourceReferenceAdapter extends TypeAdapter<SourceReference> {
  @override
  final int typeId = 3;

  @override
  SourceReference read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SourceReference(
      type: fields[0] as String,
      surah: fields[1] as String?,
      ayah: fields[2] as int?,
      collection: fields[3] as String?,
      hadithNumber: fields[4] as String?,
      narrator: fields[5] as String?,
      scholar: fields[6] as String?,
      book: fields[7] as String?,
      arabicText: fields[8] as String?,
      translation: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SourceReference obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.surah)
      ..writeByte(2)
      ..write(obj.ayah)
      ..writeByte(3)
      ..write(obj.collection)
      ..writeByte(4)
      ..write(obj.hadithNumber)
      ..writeByte(5)
      ..write(obj.narrator)
      ..writeByte(6)
      ..write(obj.scholar)
      ..writeByte(7)
      ..write(obj.book)
      ..writeByte(8)
      ..write(obj.arabicText)
      ..writeByte(9)
      ..write(obj.translation);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SourceReferenceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MessageModelAdapter extends TypeAdapter<MessageModel> {
  @override
  final int typeId = 2;

  @override
  MessageModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MessageModel(
      id: fields[0] as String,
      conversationId: fields[1] as String,
      role: fields[2] as String,
      content: fields[3] as String,
      createdAt: fields[4] as DateTime,
      references: (fields[5] as List).cast<SourceReference>(),
      isSaved: fields[6] as bool,
      structuredContent: fields[7] as String?,
      isLoading: fields[8] as bool,
      errorMessage: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MessageModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.conversationId)
      ..writeByte(2)
      ..write(obj.role)
      ..writeByte(3)
      ..write(obj.content)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.references)
      ..writeByte(6)
      ..write(obj.isSaved)
      ..writeByte(7)
      ..write(obj.structuredContent)
      ..writeByte(8)
      ..write(obj.isLoading)
      ..writeByte(9)
      ..write(obj.errorMessage);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MessageModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
