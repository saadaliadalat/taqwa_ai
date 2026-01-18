import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/conversation_provider.dart';
import '../../models/message_model.dart';

/// Premium Ask AI Chat Screen
/// 
/// World-class chat interface with beautiful animations
class AskAiScreen extends ConsumerStatefulWidget {
  const AskAiScreen({super.key});

  @override
  ConsumerState<AskAiScreen> createState() => _AskAiScreenState();
}

class _AskAiScreenState extends ConsumerState<AskAiScreen>
    with SingleTickerProviderStateMixin {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  String? _currentConversationId;
  late AnimationController _pulseController;
  late Animation<double> _pulse;

  final List<_SuggestionChip> _suggestions = [
    _SuggestionChip(
      icon: Icons.menu_book,
      label: 'Explain a Quran verse',
    ),
    _SuggestionChip(
      icon: Icons.history_edu,
      label: 'Islamic history',
    ),
    _SuggestionChip(
      icon: Icons.mosque,
      label: 'Prayer guidance',
    ),
    _SuggestionChip(
      icon: Icons.favorite,
      label: 'Daily dua',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initConversation();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulse = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _initConversation() async {
    // Use Firebase user ID if available, otherwise use local guest ID
    final user = ref.read(authStateProvider).valueOrNull;
    final userId = user?.uid ?? 'local_guest_user';
    
    final conversations = ref.read(conversationsProvider);
    if (conversations.conversations.isEmpty) {
      final conversation = await ref
          .read(conversationsProvider.notifier)
          .createConversation(userId);
      setState(() {
        _currentConversationId = conversation.id;
      });
    } else {
      setState(() {
        _currentConversationId = conversations.conversations.first.id;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final chatState = _currentConversationId != null
        ? ref.watch(chatProvider(_currentConversationId!))
        : null;

    final hasMessages = chatState?.messages.isNotEmpty ?? false;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            _buildAppBar(isDark),
            
            // Chat content
            Expanded(
              child: hasMessages
                  ? _buildChatMessages(chatState!, isDark)
                  : _buildEmptyState(isDark),
            ),
            
            // Input area
            _buildInputArea(isDark, chatState?.isLoading ?? false),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // AI Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: AppColors.cardGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Taqwa AI',
                  style: AppTypography.titleMedium(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Online • Ready to help',
                      style: AppTypography.labelSmall(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Actions
          IconButton(
            onPressed: _startNewConversation,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark 
                    ? AppColors.darkCard 
                    : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.add,
                color: AppColors.primary,
                size: 20,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark 
                    ? AppColors.darkCard 
                    : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.history,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          // Animated AI icon
          ScaleTransition(
            scale: _pulse,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 56,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          Text(
            'Assalamu Alaikum',
            style: AppTypography.headlineSmall(
              color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How can I help you today?',
            style: AppTypography.bodyLarge(
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Suggestion chips
          Text(
            'Try asking about',
            style: AppTypography.labelMedium(
              color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 16),
          
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: _suggestions.map((suggestion) {
              return GestureDetector(
                onTap: () => _handleSuggestionTap(suggestion.label),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark 
                          ? AppColors.darkBorder.withOpacity(0.3)
                          : AppColors.border.withOpacity(0.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        suggestion.icon,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        suggestion.label,
                        style: AppTypography.labelMedium(
                          color: isDark 
                              ? AppColors.darkTextPrimary 
                              : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildChatMessages(ChatState chatState, bool isDark) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: chatState.messages.length + (chatState.isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= chatState.messages.length) {
          // Loading indicator
          return _buildTypingIndicator(isDark);
        }
        
        final message = chatState.messages[index];
        return _ChatMessage(
          message: message,
          isDark: isDark,
          onCopy: () => _copyMessage(message.content),
          onFavorite: () => _toggleFavorite(message),
        );
      },
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.aiBubble,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 600 + (index * 200)),
                  builder: (context, value, child) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.3 + (value * 0.5)),
                        shape: BoxShape.circle,
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isDark, bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Attachment button
          Container(
            decoration: BoxDecoration(
              color: isDark 
                  ? AppColors.darkSurface 
                  : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.add_rounded,
                color: isDark 
                    ? AppColors.darkTextSecondary 
                    : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Text field
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark 
                    ? AppColors.darkSurface 
                    : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _messageController,
                focusNode: _focusNode,
                enabled: !isLoading,
                maxLines: 4,
                minLines: 1,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Ask anything about Islam...',
                  hintStyle: AppTypography.bodyMedium(
                    color: isDark 
                        ? AppColors.darkTextTertiary 
                        : AppColors.textTertiary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: AppTypography.bodyMedium(
                  color: isDark 
                      ? AppColors.darkTextPrimary 
                      : AppColors.textPrimary,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Send button
          GestureDetector(
            onTap: isLoading ? null : _sendMessage,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: isLoading ? null : AppColors.cardGradient,
                color: isLoading 
                    ? (isDark ? AppColors.darkSurface : AppColors.lightSurface)
                    : null,
                borderRadius: BorderRadius.circular(14),
                boxShadow: isLoading ? null : [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
                          ),
                        ),
                      )
                    : const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty || _currentConversationId == null) return;

    _messageController.clear();
    _focusNode.unfocus();

    try {
      await ref
          .read(chatProvider(_currentConversationId!).notifier)
          .sendMessage(message);

      // Scroll to bottom
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _startNewConversation() async {
    // Use Firebase user ID if available, otherwise use local guest ID
    final user = ref.read(authStateProvider).valueOrNull;
    final userId = user?.uid ?? 'local_guest_user';

    final conversation = await ref
        .read(conversationsProvider.notifier)
        .createConversation(userId);

    setState(() {
      _currentConversationId = conversation.id;
    });
  }

  void _handleSuggestionTap(String suggestion) {
    _messageController.text = suggestion;
    _focusNode.requestFocus();
  }

  void _copyMessage(String content) {
    Clipboard.setData(ClipboardData(text: content));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _toggleFavorite(MessageModel message) {
    // TODO: Implement favorite toggle
  }
}

class _SuggestionChip {
  final IconData icon;
  final String label;

  _SuggestionChip({required this.icon, required this.label});
}

class _ChatMessage extends StatelessWidget {
  final MessageModel message;
  final bool isDark;
  final VoidCallback onCopy;
  final VoidCallback onFavorite;

  const _ChatMessage({
    required this.message,
    required this.isDark,
    required this.onCopy,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            // AI Avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.cardGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser 
                    ? AppColors.primary 
                    : (isDark ? AppColors.darkCard : AppColors.aiBubble),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.2 : 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: AppTypography.bodyMedium(
                      color: isUser 
                          ? Colors.white 
                          : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                    ),
                  ),
                  if (!isUser) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ActionButton(
                          icon: Icons.copy_rounded,
                          onTap: onCopy,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _ActionButton(
                          icon: Icons.favorite_outline,
                          onTap: onFavorite,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _ActionButton(
                          icon: Icons.share_outlined,
                          onTap: () {},
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          
          if (isUser) const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isDark 
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isDark 
              ? AppColors.darkTextSecondary 
              : AppColors.textSecondary,
        ),
      ),
    );
  }
}
