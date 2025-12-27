import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/conversation_model.dart';
import '../models/message_model.dart';
import '../services/api_service.dart';
import '../services/hive_service.dart';
import 'auth_provider.dart';

/// API service provider
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

/// Conversation list provider
final conversationsProvider = StateNotifierProvider<ConversationsNotifier, ConversationsState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final hiveService = ref.watch(hiveServiceProvider);
  return ConversationsNotifier(apiService, hiveService);
});

/// Current conversation provider
final currentConversationProvider = StateProvider<ConversationModel?>((ref) => null);

/// Conversations state
class ConversationsState {
  final List<ConversationModel> conversations;
  final bool isLoading;
  final String? error;

  const ConversationsState({
    this.conversations = const [],
    this.isLoading = false,
    this.error,
  });

  ConversationsState copyWith({
    List<ConversationModel>? conversations,
    bool? isLoading,
    String? error,
  }) {
    return ConversationsState(
      conversations: conversations ?? this.conversations,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Conversations notifier
class ConversationsNotifier extends StateNotifier<ConversationsState> {
  final ApiService _apiService;
  final HiveService _hiveService;
  final _uuid = const Uuid();

  ConversationsNotifier(this._apiService, this._hiveService) 
      : super(const ConversationsState());

  /// Load conversations from local storage
  Future<void> loadConversations(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final localConversations = _hiveService.getAllConversations();
      final conversations = localConversations
          .where((c) => c['userId'] == userId)
          .map((c) => ConversationModel.fromFirestore(c, c['id'] as String))
          .toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      
      state = state.copyWith(conversations: conversations, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Create a new conversation
  Future<ConversationModel> createConversation(String userId, {String? title}) async {
    final id = _uuid.v4();
    final conversation = ConversationModel.create(
      id: id,
      userId: userId,
      title: title,
    );
    
    // Save locally
    await _hiveService.saveConversation(id, {
      ...conversation.toFirestore(),
      'id': id,
      'needsSync': true,
    });
    
    // Update state
    state = state.copyWith(
      conversations: [conversation, ...state.conversations],
    );
    
    return conversation;
  }

  /// Update conversation
  Future<void> updateConversation(ConversationModel conversation) async {
    await _hiveService.saveConversation(conversation.id, {
      ...conversation.toFirestore(),
      'id': conversation.id,
      'needsSync': true,
    });
    
    final index = state.conversations.indexWhere((c) => c.id == conversation.id);
    if (index != -1) {
      final updatedList = [...state.conversations];
      updatedList[index] = conversation;
      state = state.copyWith(conversations: updatedList);
    }
  }

  /// Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    await _hiveService.deleteConversation(conversationId);
    
    state = state.copyWith(
      conversations: state.conversations.where((c) => c.id != conversationId).toList(),
    );
  }

  /// Get most recent conversation
  ConversationModel? get recentConversation {
    if (state.conversations.isEmpty) return null;
    return state.conversations.first;
  }
}

/// Chat state provider for a specific conversation
final chatProvider = StateNotifierProvider.family<ChatNotifier, ChatState, String>((ref, conversationId) {
  final apiService = ref.watch(apiServiceProvider);
  final hiveService = ref.watch(hiveServiceProvider);
  final conversationsNotifier = ref.watch(conversationsProvider.notifier);
  return ChatNotifier(apiService, hiveService, conversationsNotifier, conversationId);
});

/// Chat state
class ChatState {
  final List<MessageModel> messages;
  final bool isLoading;
  final bool isSending;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isSending = false,
    this.error,
  });

  ChatState copyWith({
    List<MessageModel>? messages,
    bool? isLoading,
    bool? isSending,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isSending: isSending ?? this.isSending,
      error: error,
    );
  }
}

/// Chat notifier
class ChatNotifier extends StateNotifier<ChatState> {
  final ApiService _apiService;
  final HiveService _hiveService;
  final ConversationsNotifier _conversationsNotifier;
  final String conversationId;
  final _uuid = const Uuid();

  ChatNotifier(
    this._apiService,
    this._hiveService,
    this._conversationsNotifier,
    this.conversationId,
  ) : super(const ChatState()) {
    _loadMessages();
  }

  /// Load messages from local storage
  Future<void> _loadMessages() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final localMessages = _hiveService.getMessages(conversationId);
      final messages = localMessages
          .map((m) => MessageModel.fromFirestore(m, m['id'] as String))
          .toList();
      
      state = state.copyWith(messages: messages, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Send a message
  Future<void> sendMessage(String content, {String? madhhab}) async {
    if (content.trim().isEmpty) return;
    
    // Create user message
    final userMessageId = _uuid.v4();
    final userMessage = MessageModel.user(
      id: userMessageId,
      conversationId: conversationId,
      content: content.trim(),
    );
    
    // Add user message to state
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isSending: true,
      error: null,
    );
    
    // Save user message locally
    await _hiveService.saveMessage(conversationId, userMessageId, {
      ...userMessage.toFirestore(),
      'id': userMessageId,
      'createdAt': userMessage.createdAt.toIso8601String(),
    });
    
    // Add loading placeholder
    final loadingMessage = MessageModel.loading(conversationId: conversationId);
    state = state.copyWith(
      messages: [...state.messages, loadingMessage],
    );
    
    try {
      // Send to API
      final response = await _apiService.askAi(
        question: content,
        conversationId: conversationId,
        madhhab: madhhab,
      );
      
      // Remove loading placeholder and add response
      final updatedMessages = state.messages
          .where((m) => !m.isLoading)
          .toList();
      
      state = state.copyWith(
        messages: [...updatedMessages, response],
        isSending: false,
      );
      
      // Save response locally
      await _hiveService.saveMessage(conversationId, response.id, {
        ...response.toFirestore(),
        'id': response.id,
        'createdAt': response.createdAt.toIso8601String(),
      });
      
      // Update conversation title if first message
      if (state.messages.length <= 2) {
        final title = content.length > 50 
            ? '${content.substring(0, 50)}...'
            : content;
        final conversation = _conversationsNotifier.state.conversations
            .firstWhere((c) => c.id == conversationId);
        await _conversationsNotifier.updateConversation(
          conversation.copyWith(
            title: title,
            lastMessagePreview: response.content.length > 100
                ? '${response.content.substring(0, 100)}...'
                : response.content,
            messageCount: state.messages.length,
          ),
        );
      }
    } catch (e) {
      // Remove loading placeholder and add error message
      final updatedMessages = state.messages
          .where((m) => !m.isLoading)
          .toList();
      
      final errorMessage = MessageModel.error(
        conversationId: conversationId,
        errorMessage: e.toString(),
      );
      
      state = state.copyWith(
        messages: [...updatedMessages, errorMessage],
        isSending: false,
        error: e.toString(),
      );
    }
  }

  /// Retry last failed message
  Future<void> retryLastMessage({String? madhhab}) async {
    if (state.messages.isEmpty) return;
    
    // Find last user message
    final lastUserMessage = state.messages.lastWhere(
      (m) => m.isUser,
      orElse: () => state.messages.last,
    );
    
    // Remove error message if present
    final updatedMessages = state.messages
        .where((m) => m.errorMessage == null)
        .toList();
    
    state = state.copyWith(messages: updatedMessages);
    
    // Resend the message
    await sendMessage(lastUserMessage.content, madhhab: madhhab);
  }

  /// Save a message to favorites
  Future<void> saveToFavorites(String messageId) async {
    final index = state.messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;
    
    final message = state.messages[index];
    final updatedMessage = message.copyWith(isSaved: true);
    
    final updatedMessages = [...state.messages];
    updatedMessages[index] = updatedMessage;
    
    state = state.copyWith(messages: updatedMessages);
    
    // Update in local storage
    await _hiveService.saveMessage(conversationId, messageId, {
      ...updatedMessage.toFirestore(),
      'id': messageId,
      'createdAt': updatedMessage.createdAt.toIso8601String(),
    });
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
