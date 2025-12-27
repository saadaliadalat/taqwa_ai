import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../models/message_model.dart';

/// Source reference widget
class SourceReferenceWidget extends StatelessWidget {
  final SourceReference reference;
  final VoidCallback? onTap;

  const SourceReferenceWidget({
    super.key,
    required this.reference,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _getBackgroundColor(isDark),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _getBorderColor(isDark),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reference header
            Row(
              children: [
                _TypeIcon(type: reference.type),
                const SizedBox(width: 8),
                Text(
                  reference.formattedReference,
                  style: AppTypography.labelMedium(
                    color: _getPrimaryColor(),
                  ),
                ),
                if (onTap != null) ...[
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ],
            ),

            // Arabic text
            if (reference.arabicText != null && reference.arabicText!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                reference.arabicText!,
                style: AppTypography.arabicBody(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
                textDirection: TextDirection.rtl,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Translation
            if (reference.translation != null && reference.translation!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                reference.translation!,
                style: AppTypography.bodySmall(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor(bool isDark) {
    switch (reference.type) {
      case 'quran':
        return isDark 
            ? AppColors.quranBackgroundDark.withOpacity(0.5)
            : AppColors.quranBackground;
      case 'hadith':
        return isDark 
            ? AppColors.hadithHighlightDark.withOpacity(0.5)
            : AppColors.hadithHighlight;
      default:
        return isDark 
            ? AppColors.darkSurface 
            : AppColors.lightSurface;
    }
  }

  Color _getBorderColor(bool isDark) {
    switch (reference.type) {
      case 'quran':
        return AppColors.primary.withOpacity(isDark ? 0.3 : 0.2);
      case 'hadith':
        return AppColors.secondary.withOpacity(isDark ? 0.3 : 0.2);
      default:
        return isDark ? AppColors.darkBorder : AppColors.border;
    }
  }

  Color _getPrimaryColor() {
    switch (reference.type) {
      case 'quran':
        return AppColors.primary;
      case 'hadith':
        return AppColors.secondary;
      default:
        return AppColors.info;
    }
  }
}

/// Type icon for reference
class _TypeIcon extends StatelessWidget {
  final String type;

  const _TypeIcon({required this.type});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color color;

    switch (type) {
      case 'quran':
        icon = Icons.menu_book;
        color = AppColors.primary;
        break;
      case 'hadith':
        icon = Icons.format_quote;
        color = AppColors.secondary;
        break;
      case 'scholar':
        icon = Icons.school;
        color = AppColors.info;
        break;
      case 'book':
        icon = Icons.auto_stories;
        color = AppColors.info;
        break;
      default:
        icon = Icons.source;
        color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 14, color: color),
    );
  }
}

/// Inline reference chip for text
class SourceReferenceChip extends StatelessWidget {
  final String reference;
  final String type;
  final VoidCallback? onTap;

  const SourceReferenceChip({
    super.key,
    required this.reference,
    required this.type,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (type) {
      case 'quran':
        color = AppColors.primary;
        break;
      case 'hadith':
        color = AppColors.secondary;
        break;
      default:
        color = AppColors.info;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          reference,
          style: AppTypography.labelSmall(color: color),
        ),
      ),
    );
  }
}
