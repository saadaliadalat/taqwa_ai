import 'package:hive/hive.dart';

part 'message_model.g.dart';

/// Message role enum
enum MessageRole {
  user,
  assistant,
  system,
}

/// Reference type for sources
enum ReferenceType {
  quran,
  hadith,
  scholar,
  book,
}

/// Source reference model
@HiveType(typeId: 3)
class SourceReference {
  @HiveField(0)
  final String type;
  
  @HiveField(1)
  final String? surah;
  
  @HiveField(2)
  final int? ayah;
  
  @HiveField(3)
  final String? collection;
  
  @HiveField(4)
  final String? hadithNumber;
  
  @HiveField(5)
  final String? narrator;
  
  @HiveField(6)
  final String? scholar;
  
  @HiveField(7)
  final String? book;
  
  @HiveField(8)
  final String? arabicText;
  
  @HiveField(9)
  final String? translation;

  const SourceReference({
    required this.type,
    this.surah,
    this.ayah,
    this.collection,
    this.hadithNumber,
    this.narrator,
    this.scholar,
    this.book,
    this.arabicText,
    this.translation,
  });

  factory SourceReference.fromJson(Map<String, dynamic> json) {
    return SourceReference(
      type: json['type'] as String,
      surah: json['surah'] as String?,
      ayah: json['ayah'] as int?,
      collection: json['collection'] as String?,
      hadithNumber: json['hadithNumber'] as String?,
      narrator: json['narrator'] as String?,
      scholar: json['scholar'] as String?,
      book: json['book'] as String?,
      arabicText: json['arabicText'] as String?,
      translation: json['translation'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (surah != null) 'surah': surah,
      if (ayah != null) 'ayah': ayah,
      if (collection != null) 'collection': collection,
      if (hadithNumber != null) 'hadithNumber': hadithNumber,
      if (narrator != null) 'narrator': narrator,
      if (scholar != null) 'scholar': scholar,
      if (book != null) 'book': book,
      if (arabicText != null) 'arabicText': arabicText,
      if (translation != null) 'translation': translation,
    };
  }

  /// Get formatted reference string
  String get formattedReference {
    switch (type) {
      case 'quran':
        return 'Quran ${surah ?? ''}:${ayah ?? ''}';
      case 'hadith':
        return '${collection ?? ''} ${hadithNumber ?? ''}';
      case 'scholar':
        return scholar ?? '';
      case 'book':
        return book ?? '';
      default:
        return '';
    }
  }
}

/// Message model representing a single message in a conversation
@HiveType(typeId: 2)
class MessageModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String conversationId;
  
  @HiveField(2)
  final String role;
  
  @HiveField(3)
  final String content;
  
  @HiveField(4)
  final DateTime createdAt;
  
  @HiveField(5)
  final List<SourceReference> references;
  
  @HiveField(6)
  final bool isSaved;
  
  @HiveField(7)
  final String? structuredContent;
  
  @HiveField(8)
  final bool isLoading;
  
  @HiveField(9)
  final String? errorMessage;

  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.references = const [],
    this.isSaved = false,
    this.structuredContent,
    this.isLoading = false,
    this.errorMessage,
  });

  /// Create from API response
  factory MessageModel.fromApi(Map<String, dynamic> data, String conversationId) {
    final refs = (data['references'] as List<dynamic>?)
        ?.map((r) => SourceReference.fromJson(r as Map<String, dynamic>))
        .toList() ?? [];
    
    return MessageModel(
      id: data['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      conversationId: conversationId,
      role: data['role'] as String? ?? 'assistant',
      content: data['content'] as String? ?? data['message'] as String? ?? '',
      createdAt: DateTime.now(),
      references: refs,
      structuredContent: data['structuredContent'] as String?,
      isLoading: false,
    );
  }

  /// Create from Firestore
  factory MessageModel.fromFirestore(Map<String, dynamic> data, String docId) {
    final refs = (data['references'] as List<dynamic>?)
        ?.map((r) => SourceReference.fromJson(r as Map<String, dynamic>))
        .toList() ?? [];
    
    return MessageModel(
      id: docId,
      conversationId: data['conversationId'] as String,
      role: data['role'] as String,
      content: data['content'] as String,
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      references: refs,
      isSaved: data['isSaved'] as bool? ?? false,
      structuredContent: data['structuredContent'] as String?,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'conversationId': conversationId,
      'role': role,
      'content': content,
      'createdAt': createdAt,
      'references': references.map((r) => r.toJson()).toList(),
      'isSaved': isSaved,
      if (structuredContent != null) 'structuredContent': structuredContent,
    };
  }

  /// Create a copy with updated fields
  MessageModel copyWith({
    String? id,
    String? conversationId,
    String? role,
    String? content,
    DateTime? createdAt,
    List<SourceReference>? references,
    bool? isSaved,
    String? structuredContent,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      references: references ?? this.references,
      isSaved: isSaved ?? this.isSaved,
      structuredContent: structuredContent ?? this.structuredContent,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Create a user message
  factory MessageModel.user({
    required String id,
    required String conversationId,
    required String content,
  }) {
    return MessageModel(
      id: id,
      conversationId: conversationId,
      role: 'user',
      content: content,
      createdAt: DateTime.now(),
    );
  }

  /// Create a loading placeholder message
  factory MessageModel.loading({
    required String conversationId,
  }) {
    return MessageModel(
      id: 'loading_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      role: 'assistant',
      content: '',
      createdAt: DateTime.now(),
      isLoading: true,
    );
  }

  /// Create an error message
  factory MessageModel.error({
    required String conversationId,
    required String errorMessage,
  }) {
    return MessageModel(
      id: 'error_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: conversationId,
      role: 'assistant',
      content: 'An error occurred while processing your request.',
      createdAt: DateTime.now(),
      errorMessage: errorMessage,
    );
  }

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';
  bool get hasReferences => references.isNotEmpty;
  bool get hasQuranReference => references.any((r) => r.type == 'quran');
  bool get hasHadithReference => references.any((r) => r.type == 'hadith');
}
