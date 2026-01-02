import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../models/message_model.dart';
import 'source_reference.dart';

/// Chat bubble widget for messages
class ChatBubble extends StatelessWidget {
  final MessageModel message;
  final VoidCallback? onSave;
  final VoidCallback? onCopy;
  final bool showActions;

  const ChatBubble({
    super.key,
    required this.message,
    this.onSave,
    this.onCopy,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isLoading) {
      return _LoadingBubble();
    }

    if (message.errorMessage != null) {
      return _ErrorBubble(
        errorMessage: message.errorMessage!,
        onRetry: onCopy, // Reusing onCopy callback for retry
      );
    }

    if (message.isUser) {
      return _UserBubble(content: message.content);
    }

    return _AssistantBubble(
      message: message,
      onSave: onSave,
      onCopy: onCopy,
      showActions: showActions,
    );
  }
}

/// User message bubble
class _UserBubble extends StatelessWidget {
  final String content;

  const _UserBubble({required this.content});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.only(
          left: 48,
          right: 16,
          top: 4,
          bottom: 4,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.userBubble,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Text(
          content,
          style: AppTypography.bodyMedium(color: Colors.white),
        ),
      ),
    );
  }
}

/// Assistant message bubble
class _AssistantBubble extends StatelessWidget {
  final MessageModel message;
  final VoidCallback? onSave;
  final VoidCallback? onCopy;
  final bool showActions;

  const _AssistantBubble({
    required this.message,
    this.onSave,
    this.onCopy,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        margin: const EdgeInsets.only(
          left: 16,
          right: 48,
          top: 4,
          bottom: 4,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main message bubble
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark 
                      ? [AppColors.aiBubbleDark, const Color(0xFF2C4A40)] 
                      : [AppColors.aiBubble, const Color(0xFFF7F9F8)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(24),
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
                boxShadow: [
                   if (!isDark)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message content
                  Text(
                    message.content,
                    style: AppTypography.bodyMedium(
                      color: isDark 
                          ? AppColors.darkTextPrimary 
                          : AppColors.textPrimary,
                    ),
                  ),

                  // Source references
                  if (message.hasReferences) ...[
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Text(
                      'Sources',
                      style: AppTypography.labelMedium(
                        color: isDark 
                            ? AppColors.darkTextSecondary 
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...message.references.map(
                      (ref) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SourceReferenceWidget(reference: ref),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Actions row
            if (showActions)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onCopy != null)
                      _ActionButton(
                        icon: Icons.copy_rounded,
                        label: 'Copy',
                        onTap: onCopy!,
                      ),
                    if (onSave != null) ...[
                      const SizedBox(width: 12),
                      _ActionButton(
                        icon: message.isSaved 
                            ? Icons.bookmark_rounded
                            : Icons.bookmark_outline_rounded,
                        label: message.isSaved ? 'Saved' : 'Save',
                        onTap: onSave!,
                        isActive: message.isSaved,
                      ),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Loading bubble
class _LoadingBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(
          left: 16,
          right: 48,
          top: 4,
          bottom: 4,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.aiBubbleDark : AppColors.aiBubble,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TypingDot(delay: 0),
            const SizedBox(width: 4),
            _TypingDot(delay: 150),
            const SizedBox(width: 4),
            _TypingDot(delay: 300),
          ],
        ),
      ),
    );
  }
}

/// Typing animation dot
class _TypingDot extends StatefulWidget {
  final int delay;

  const _TypingDot({required this.delay});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.3 + (_animation.value * 0.7)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }
}

/// Error bubble
class _ErrorBubble extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const _ErrorBubble({
    required this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(
          left: 16,
          right: 48,
          top: 4,
          bottom: 4,
        ),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.error.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 20,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                'Something went wrong. Please try again.',
                style: AppTypography.bodySmall(color: AppColors.error),
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: 12),
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
                child: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Action button for message actions
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isActive 
        ? theme.colorScheme.primary 
        : theme.colorScheme.onSurfaceVariant;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTypography.labelSmall(color: color),
            ),
          ],
        ),
      ),
    );
  }
}
