import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../models/hadith_model.dart';

/// Hadith Card Widget
/// Displays a hadith with Arabic text, translation, and metadata
class HadithCard extends StatelessWidget {
  final HadithModel hadith;
  final bool showArabic;
  final bool isFavorited;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;

  const HadithCard({
    super.key,
    required this.hadith,
    this.showArabic = true,
    this.isFavorited = false,
    this.onTap,
    this.onFavorite,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isDark ? AppColors.hadithHighlightDark : AppColors.hadithHighlight,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with collection and actions
              Row(
                children: [
                  // Collection Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      hadith.collectionDisplayName,
                      style: AppTypography.labelSmall(
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Grade Badge
                  if (hadith.grade != null)
                    _GradeBadge(grade: hadith.grade!),
                  const SizedBox(width: 8),
                  // Actions
                  if (onShare != null)
                    IconButton(
                      icon: const Icon(Icons.share_outlined, size: 20),
                      onPressed: onShare,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  if (onFavorite != null)
                    IconButton(
                      icon: Icon(
                        isFavorited ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                      ),
                      onPressed: onFavorite,
                      color: isFavorited 
                          ? AppColors.error 
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
              const SizedBox(height: 16),

              // Arabic Text
              if (showArabic && hadith.arabicText.isNotEmpty) ...[
                Text(
                  hadith.arabicText,
                  style: AppTypography.arabicHadith(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
              ],
              
              // Translation
              Text(
                hadith.translation,
                style: AppTypography.bodyMedium(
                  color: isDark 
                      ? AppColors.darkTextSecondary 
                      : AppColors.textSecondary,
                ),
              ),
              
              // Narrator
              if (hadith.narrator != null && hadith.narrator!.isNotEmpty) ...[
                const SizedBox(height: 16),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Narrated by ${hadith.narrator}',
                        style: AppTypography.reference(
                          color: isDark 
                              ? AppColors.darkTextSecondary 
                              : AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              
              // Reference
              const SizedBox(height: 8),
              Text(
                hadith.reference,
                style: AppTypography.reference(
                  color: isDark 
                      ? AppColors.darkTextSecondary 
                      : AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grade badge widget
class _GradeBadge extends StatelessWidget {
  final String grade;

  const _GradeBadge({required this.grade});

  Color get _color {
    switch (grade.toLowerCase()) {
      case 'sahih':
        return AppColors.success;
      case 'hasan':
        return AppColors.primary;
      case 'daif':
        return AppColors.warning;
      case 'maudu':
        return AppColors.error;
      default:
        return AppColors.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        grade,
        style: AppTypography.labelSmall(color: _color),
      ),
    );
  }
}

/// Compact Hadith Card for lists
class HadithCardCompact extends StatelessWidget {
  final HadithModel hadith;
  final VoidCallback? onTap;
  final bool isFavorited;

  const HadithCardCompact({
    super.key,
    required this.hadith,
    this.onTap,
    this.isFavorited = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                hadith.collectionDisplayName,
                style: AppTypography.labelSmall(color: AppColors.secondary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '#${hadith.hadithNumber}',
              style: AppTypography.labelSmall(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            hadith.translation,
            style: AppTypography.bodySmall(
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: isFavorited
            ? Icon(Icons.favorite, color: AppColors.error, size: 20)
            : null,
      ),
    );
  }
}
