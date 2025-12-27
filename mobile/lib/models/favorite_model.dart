import 'package:hive/hive.dart';

part 'favorite_model.g.dart';

/// Type of favorite item
enum FavoriteType {
  ayah,
  hadith,
  aiResponse,
  conversation,
}

/// Favorite model for saved items
@HiveType(typeId: 4)
class FavoriteModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final String type;
  
  @HiveField(3)
  final String content;
  
  @HiveField(4)
  final String? arabicText;
  
  @HiveField(5)
  final String? translation;
  
  @HiveField(6)
  final String? reference;
  
  @HiveField(7)
  final DateTime createdAt;
  
  @HiveField(8)
  final String? note;
  
  @HiveField(9)
  final List<String> tags;
  
  // Quran specific
  @HiveField(10)
  final int? surahNumber;
  
  @HiveField(11)
  final int? ayahNumber;
  
  @HiveField(12)
  final String? surahName;
  
  // Hadith specific
  @HiveField(13)
  final String? collection;
  
  @HiveField(14)
  final String? hadithNumber;
  
  @HiveField(15)
  final String? narrator;
  
  // AI Response specific
  @HiveField(16)
  final String? conversationId;
  
  @HiveField(17)
  final String? messageId;
  
  @HiveField(18)
  final bool needsSync;

  const FavoriteModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.content,
    this.arabicText,
    this.translation,
    this.reference,
    required this.createdAt,
    this.note,
    this.tags = const [],
    this.surahNumber,
    this.ayahNumber,
    this.surahName,
    this.collection,
    this.hadithNumber,
    this.narrator,
    this.conversationId,
    this.messageId,
    this.needsSync = false,
  });

  /// Create from Firestore document
  factory FavoriteModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return FavoriteModel(
      id: docId,
      userId: data['userId'] as String,
      type: data['type'] as String,
      content: data['content'] as String,
      arabicText: data['arabicText'] as String?,
      translation: data['translation'] as String?,
      reference: data['reference'] as String?,
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      note: data['note'] as String?,
      tags: List<String>.from(data['tags'] ?? []),
      surahNumber: data['surahNumber'] as int?,
      ayahNumber: data['ayahNumber'] as int?,
      surahName: data['surahName'] as String?,
      collection: data['collection'] as String?,
      hadithNumber: data['hadithNumber'] as String?,
      narrator: data['narrator'] as String?,
      conversationId: data['conversationId'] as String?,
      messageId: data['messageId'] as String?,
      needsSync: false,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type,
      'content': content,
      if (arabicText != null) 'arabicText': arabicText,
      if (translation != null) 'translation': translation,
      if (reference != null) 'reference': reference,
      'createdAt': createdAt,
      if (note != null) 'note': note,
      'tags': tags,
      if (surahNumber != null) 'surahNumber': surahNumber,
      if (ayahNumber != null) 'ayahNumber': ayahNumber,
      if (surahName != null) 'surahName': surahName,
      if (collection != null) 'collection': collection,
      if (hadithNumber != null) 'hadithNumber': hadithNumber,
      if (narrator != null) 'narrator': narrator,
      if (conversationId != null) 'conversationId': conversationId,
      if (messageId != null) 'messageId': messageId,
    };
  }

  /// Create a copy with updated fields
  FavoriteModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? content,
    String? arabicText,
    String? translation,
    String? reference,
    DateTime? createdAt,
    String? note,
    List<String>? tags,
    int? surahNumber,
    int? ayahNumber,
    String? surahName,
    String? collection,
    String? hadithNumber,
    String? narrator,
    String? conversationId,
    String? messageId,
    bool? needsSync,
  }) {
    return FavoriteModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      content: content ?? this.content,
      arabicText: arabicText ?? this.arabicText,
      translation: translation ?? this.translation,
      reference: reference ?? this.reference,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
      tags: tags ?? this.tags,
      surahNumber: surahNumber ?? this.surahNumber,
      ayahNumber: ayahNumber ?? this.ayahNumber,
      surahName: surahName ?? this.surahName,
      collection: collection ?? this.collection,
      hadithNumber: hadithNumber ?? this.hadithNumber,
      narrator: narrator ?? this.narrator,
      conversationId: conversationId ?? this.conversationId,
      messageId: messageId ?? this.messageId,
      needsSync: needsSync ?? this.needsSync,
    );
  }

  /// Create from ayah
  factory FavoriteModel.fromAyah({
    required String id,
    required String userId,
    required int surahNumber,
    required int ayahNumber,
    required String surahName,
    required String arabicText,
    required String translation,
  }) {
    return FavoriteModel(
      id: id,
      userId: userId,
      type: 'ayah',
      content: translation,
      arabicText: arabicText,
      translation: translation,
      reference: 'Quran $surahNumber:$ayahNumber',
      createdAt: DateTime.now(),
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      surahName: surahName,
      needsSync: true,
    );
  }

  /// Create from hadith
  factory FavoriteModel.fromHadith({
    required String id,
    required String userId,
    required String collection,
    required String hadithNumber,
    required String arabicText,
    required String translation,
    String? narrator,
  }) {
    return FavoriteModel(
      id: id,
      userId: userId,
      type: 'hadith',
      content: translation,
      arabicText: arabicText,
      translation: translation,
      reference: '$collection $hadithNumber',
      createdAt: DateTime.now(),
      collection: collection,
      hadithNumber: hadithNumber,
      narrator: narrator,
      needsSync: true,
    );
  }

  /// Create from AI response
  factory FavoriteModel.fromAiResponse({
    required String id,
    required String userId,
    required String content,
    required String conversationId,
    required String messageId,
  }) {
    return FavoriteModel(
      id: id,
      userId: userId,
      type: 'aiResponse',
      content: content,
      createdAt: DateTime.now(),
      conversationId: conversationId,
      messageId: messageId,
      needsSync: true,
    );
  }

  bool get isAyah => type == 'ayah';
  bool get isHadith => type == 'hadith';
  bool get isAiResponse => type == 'aiResponse';
}
