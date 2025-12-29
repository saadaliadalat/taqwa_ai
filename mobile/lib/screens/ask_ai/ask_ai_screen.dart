import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/conversation_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../widgets/chat_bubble.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart' as custom_error;
import '../../utils/helpers.dart';

/// Ask AI screen - Chat interface
class AskAiScreen extends ConsumerStatefulWidget {
  const AskAiScreen({super.key});

  @override
  ConsumerState<AskAiScreen> createState() => _AskAiScreenState();
}

class _AskAiScreenState extends ConsumerState<AskAiScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  String? _currentConversationId;

  @override
  void initState() {
    super.initState();
    _initConversation();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initConversation() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user != null) {
      // Check for existing conversations
      final conversations = ref.read(conversationsProvider);
      if (conversations.conversations.isEmpty) {
        // Create new conversation
        final conversation = await ref
            .read(conversationsProvider.notifier)
            .createConversation(user.uid);
        setState(() {
          _currentConversationId = conversation.id;
        });
      } else {
        setState(() {
          _currentConversationId = conversations.conversations.first.id;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = ref.watch(settingsProvider);

    // Watch chat state if we have a conversation
    final chatState = _currentConversationId != null
        ? ref.watch(chatProvider(_currentConversationId!))
        : null;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Ask Taqwa AI',
          style: AppTypography.titleLarge(
            color: theme.colorScheme.onBackground,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Conversation',
            onPressed: _startNewConversation,
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Conversation history coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Chat messages
          Expanded(
            child: chatState == null
                ? const LoadingWidget(message: 'Preparing...')
                : chatState.messages.isEmpty
                    ? _EmptyConversation(
                        onQuestionTap: (question) {
                          _messageController.text = question;
                          _sendMessage();
                        },
                      )
                    : _MessagesList(
                        messages: chatState.messages,
                        scrollController: _scrollController,
                        conversationId: _currentConversationId!,
                      ),
          ),

          // Input area
          _MessageInput(
            controller: _messageController,
            isSending: chatState?.isSending ?? false,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }

  void _startNewConversation() async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user != null) {
      final conversation = await ref
          .read(conversationsProvider.notifier)
          .createConversation(user.uid);
      setState(() {
        _currentConversationId = conversation.id;
      });
      _messageController.clear();
    }
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty || _currentConversationId == null) return;

    final settings = ref.read(settingsProvider);
    final madhhab = settings.madhhab != 'none' ? settings.madhhab : null;

    ref
        .read(chatProvider(_currentConversationId!).notifier)
        .sendMessage(message, madhhab: madhhab);

    _messageController.clear();

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

/// Empty conversation placeholder
class _EmptyConversation extends StatelessWidget {
  final void Function(String question)? onQuestionTap;
  
  const _EmptyConversation({this.onQuestionTap});
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 48,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Bismillah',
              style: AppTypography.arabicTitle(color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Ask me anything about Islam',
              style: AppTypography.titleMedium(
                color: isDark 
                    ? AppColors.darkTextPrimary 
                    : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'I can help with Quran, Hadith, fiqh, and spiritual guidance',
              style: AppTypography.bodyMedium(
                color: isDark 
                    ? AppColors.darkTextSecondary 
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Example questions
            _ExampleQuestion(
              text: 'What does the Quran say about patience?',
              onTap: () => onQuestionTap?.call('What does the Quran say about patience?'),
            ),
            const SizedBox(height: 12),
            _ExampleQuestion(
              text: 'How to perform Wudu correctly?',
              onTap: () => onQuestionTap?.call('How to perform Wudu correctly?'),
            ),
            const SizedBox(height: 12),
            _ExampleQuestion(
              text: 'What are the pillars of Islam?',
              onTap: () => onQuestionTap?.call('What are the pillars of Islam?'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Example question chip
class _ExampleQuestion extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _ExampleQuestion({required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 18,
              color: AppColors.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: AppTypography.bodyMedium(
                  color: isDark 
                      ? AppColors.darkTextPrimary 
                      : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Messages list
class _MessagesList extends ConsumerWidget {
  final List<dynamic> messages;
  final ScrollController scrollController;
  final String conversationId;

  const _MessagesList({
    required this.messages,
    required this.scrollController,
    required this.conversationId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(top: 16, bottom: 16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return ChatBubble(
          message: message,
          onSave: message.isAssistant && !message.isLoading
              ? () => _saveToFavorites(ref, message)
              : null,
          onCopy: message.isAssistant && !message.isLoading
              ? () => _copyMessage(context, message.content)
              : null,
        );
      },
    );
  }

  void _saveToFavorites(WidgetRef ref, dynamic message) {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user != null) {
      ref.read(favoritesProvider.notifier).saveAiResponse(
        userId: user.uid,
        message: message,
      );
      ref.read(chatProvider(conversationId).notifier).saveToFavorites(message.id);
    }
  }

  void _copyMessage(BuildContext context, String content) {
    Clipboard.setData(ClipboardData(text: content));
    Helpers.showSnackBar(context, 'Copied to clipboard');
  }
}

/// Message input field
class _MessageInput extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSend;

  const _MessageInput({
    required this.controller,
    required this.isSending,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              maxLines: 4,
              minLines: 1,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Ask a question...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: isDark 
                    ? AppColors.darkSurface 
                    : AppColors.lightSurface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              onSubmitted: (_) => onSend(),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: isSending
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
              onPressed: isSending ? null : onSend,
            ),
          ),
        ],
      ),
    );
  }
}
