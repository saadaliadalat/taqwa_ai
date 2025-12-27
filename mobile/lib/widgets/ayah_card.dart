import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../models/ayah_model.dart';

/// Quran Ayah Card Widget
/// Displays an ayah with Arabic text, translation, and actions
class AyahCard extends StatelessWidget {
  final AyahModel ayah;
  final String surahName;
  final bool showTranslation;
  final bool isFavorited;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onShare;
  final int? fontSize;

  const AyahCard({
    super.key,
    required this.ayah,
    required this.surahName,
    this.showTranslation = true,
    this.isFavorited = false,
    this.onTap,
    this.onFavorite,
    this.onShare,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isDark ? AppColors.quranBackgroundDark : AppColors.quranBackground,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Ayah Number Badge
              Row(
                children: [
                  _AyahNumberBadge(number: ayah.numberInSurah),
                  const Spacer(),
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
              Text(
                ayah.text,
                style: AppTypography.quranMedium(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ).copyWith(
                  fontSize: fontSize?.toDouble() ?? 26,
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
              
              // Translation
              if (showTranslation && ayah.hasTranslation) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  ayah.translation!,
                  style: AppTypography.bodyMedium(
                    color: isDark 
                        ? AppColors.darkTextSecondary 
                        : AppColors.textSecondary,
                  ),
                ),
              ],
              
              // Reference
              const SizedBox(height: 16),
              Text(
                'Surah $surahName ${ayah.surahNumber}:${ayah.numberInSurah}',
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

/// Ayah number badge widget
class _AyahNumberBadge extends StatelessWidget {
  final int number;

  const _AyahNumberBadge({required this.number});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          number.toString(),
          style: AppTypography.labelLarge(
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

/// Compact Ayah Card for lists
class AyahCardCompact extends StatelessWidget {
  final AyahModel ayah;
  final String surahName;
  final VoidCallback? onTap;
  final bool isFavorited;

  const AyahCardCompact({
    super.key,
    required this.ayah,
    required this.surahName,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: _AyahNumberBadge(number: ayah.numberInSurah),
        title: Text(
          ayah.text,
          style: AppTypography.arabicBody(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textDirection: TextDirection.rtl,
        ),
        subtitle: ayah.hasTranslation
            ? Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  ayah.translation!,
                  style: AppTypography.bodySmall(
                    color: isDark 
                        ? AppColors.darkTextSecondary 
                        : AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : null,
        trailing: isFavorited
            ? Icon(
                Icons.favorite,
                color: AppColors.error,
                size: 20,
              )
            : null,
      ),
    );
  }
}
