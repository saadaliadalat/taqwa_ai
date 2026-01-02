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
        scrolledUnderElevation: 0,
        centerTitle: true,
        title: Text(
          'Ask Taqwa AI',
          style: AppTypography.titleLarge(
            color: theme.colorScheme.onBackground,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'New Conversation',
            onPressed: _startNewConversation,
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded),
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
class _EmptyConversation extends StatefulWidget {
  final void Function(String question)? onQuestionTap;
  
  const _EmptyConversation({this.onQuestionTap});

  @override
  State<_EmptyConversation> createState() => _EmptyConversationState();
}

class _EmptyConversationState extends State<_EmptyConversation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  final List<String> _suggestions = [
    'What does the Quran say about patience?',
    'How to perform Wudu correctly?',
    'What are the pillars of Islam?',
    'Virtues of Ramadan',
    'Supplication for knowledge',
    'Rights of parents in Islam',
  ];
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.2),
                        AppColors.primary.withOpacity(0.05),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Bismillah',
                  style: AppTypography.bismillah(color: AppColors.primary).copyWith(fontSize: 32),
                ),
                const SizedBox(height: 8),
                Text(
                  'How can I help you today?',
                  style: AppTypography.headlineSmall(
                    color: isDark 
                        ? AppColors.darkTextPrimary 
                        : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Ask about Quran, Hadith, or Fiqh',
                  style: AppTypography.bodyMedium(
                    color: isDark 
                        ? AppColors.darkTextSecondary 
                        : AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Suggestions Wrap
                Wrap(
                  spacing: 8,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: _suggestions.map((question) => _SuggestionChip(
                    label: question,
                    onTap: () => widget.onQuestionTap?.call(question),
                  )).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Suggestion chip
class _SuggestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
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
        bottom: MediaQuery.of(context).padding.bottom + 12, // Keep some spacing
      ),
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
             const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                style: AppTypography.bodyMedium(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Ask a question...',
                  hintStyle: AppTypography.bodyMedium(
                     color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 8,
                  ),
                ),
                onSubmitted: (_) => onSend(),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF285C4D) : AppColors.primary, // Darker Green for Dark Mode
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
                    : const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 24),
                onPressed: isSending ? null : onSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
