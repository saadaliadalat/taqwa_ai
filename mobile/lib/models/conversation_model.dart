import 'package:hive/hive.dart';
import 'message_model.dart';

part 'conversation_model.g.dart';

/// Conversation model representing a chat session with the AI
@HiveType(typeId: 1)
class ConversationModel {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String userId;
  
  @HiveField(3)
  final DateTime createdAt;
  
  @HiveField(4)
  final DateTime updatedAt;
  
  @HiveField(5)
  final List<MessageModel> messages;
  
  @HiveField(6)
  final bool isArchived;
  
  @HiveField(7)
  final String? lastMessagePreview;
  
  @HiveField(8)
  final int messageCount;
  
  @HiveField(9)
  final bool needsSync;

  const ConversationModel({
    required this.id,
    required this.title,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.messages = const [],
    this.isArchived = false,
    this.lastMessagePreview,
    this.messageCount = 0,
    this.needsSync = false,
  });

  /// Create from Firestore document
  factory ConversationModel.fromFirestore(Map<String, dynamic> data, String docId) {
    return ConversationModel(
      id: docId,
      title: data['title'] as String? ?? 'New Conversation',
      userId: data['userId'] as String,
      createdAt: (data['createdAt'] as dynamic)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as dynamic)?.toDate() ?? DateTime.now(),
      messages: [], // Messages loaded separately
      isArchived: data['isArchived'] as bool? ?? false,
      lastMessagePreview: data['lastMessagePreview'] as String?,
      messageCount: data['messageCount'] as int? ?? 0,
      needsSync: false,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'userId': userId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isArchived': isArchived,
      'lastMessagePreview': lastMessagePreview,
      'messageCount': messageCount,
    };
  }

  /// Create a copy with updated fields
  ConversationModel copyWith({
    String? id,
    String? title,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<MessageModel>? messages,
    bool? isArchived,
    String? lastMessagePreview,
    int? messageCount,
    bool? needsSync,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      isArchived: isArchived ?? this.isArchived,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      messageCount: messageCount ?? this.messageCount,
      needsSync: needsSync ?? this.needsSync,
    );
  }

  /// Create a new conversation
  factory ConversationModel.create({
    required String id,
    required String userId,
    String? title,
  }) {
    final now = DateTime.now();
    return ConversationModel(
      id: id,
      title: title ?? 'New Conversation',
      userId: userId,
      createdAt: now,
      updatedAt: now,
      messages: [],
      needsSync: true,
    );
  }

  /// Add a message to the conversation
  ConversationModel addMessage(MessageModel message) {
    final updatedMessages = [...messages, message];
    return copyWith(
      messages: updatedMessages,
      updatedAt: DateTime.now(),
      lastMessagePreview: message.content.length > 100 
          ? '${message.content.substring(0, 100)}...'
          : message.content,
      messageCount: updatedMessages.length,
      needsSync: true,
    );
  }
}
