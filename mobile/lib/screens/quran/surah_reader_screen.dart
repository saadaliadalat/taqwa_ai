import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../providers/quran_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/settings_provider.dart';
import '../../models/surah_model.dart';
import '../../models/ayah_model.dart';
import '../../widgets/ayah_card.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart' as custom_error;
import '../../utils/helpers.dart';

/// Surah reader screen
class SurahReaderScreen extends ConsumerStatefulWidget {
  final SurahModel surah;
  final int? initialAyah;

  const SurahReaderScreen({
    super.key,
    required this.surah,
    this.initialAyah,
  });

  @override
  ConsumerState<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends ConsumerState<SurahReaderScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSurah();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadSurah() {
    ref.read(quranProvider.notifier).loadSurah(widget.surah.number);
    
    // Scroll to initial ayah if provided
    if (widget.initialAyah != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Calculate scroll position based on ayah
        // This is a simplified version - in production you'd want precise positioning
        Future.delayed(const Duration(milliseconds: 500), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              (widget.initialAyah! - 1) * 200.0, // Approximate height
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final quranState = ref.watch(quranProvider);
    final settings = ref.watch(settingsProvider);
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: isDark 
          ? AppColors.quranBackgroundDark 
          : AppColors.quranBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Column(
          children: [
            Text(
              widget.surah.englishName,
              style: AppTypography.titleMedium(
                color: isDark 
                    ? AppColors.darkTextPrimary 
                    : AppColors.textPrimary,
              ),
            ),
            Text(
              widget.surah.name,
              style: AppTypography.arabicBody(color: AppColors.primary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              settings.showTranslation 
                  ? Icons.translate 
                  : Icons.translate_outlined,
            ),
            onPressed: () {
              ref.read(settingsProvider.notifier).toggleTranslation();
            },
            tooltip: 'Toggle Translation',
          ),
          IconButton(
            icon: const Icon(Icons.text_fields),
            onPressed: () => _showFontSizeDialog(context),
            tooltip: 'Font Size',
          ),
        ],
      ),
      body: quranState.isLoading
          ? const LoadingWidget(message: 'Loading Surah...')
          : quranState.error != null
              ? custom_error.ErrorWidget(
                  message: 'Failed to load Surah',
                  details: quranState.error,
                  onRetry: _loadSurah,
                )
              : _buildContent(context, quranState, settings, favorites),
    );
  }

  Widget _buildContent(
    BuildContext context,
    QuranState quranState,
    SettingsState settings,
    FavoritesState favorites,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        // Bismillah (except for Surah 9 At-Tawbah)
        if (widget.surah.number != 9)
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                style: AppTypography.bismillah(
                  color: isDark 
                      ? AppColors.darkTextPrimary 
                      : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

        // Surah info card
        SliverToBoxAdapter(
          child: _SurahInfoCard(surah: widget.surah),
        ),

        // Ayah list
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final ayah = quranState.currentAyahs[index];
              final isFavorited = favorites.isFavorited(
                ayahReference: 'Quran ${ayah.surahNumber}:${ayah.numberInSurah}',
              );

              return AyahCard(
                ayah: ayah,
                surahName: widget.surah.englishName,
                showTranslation: settings.showTranslation,
                fontSize: settings.quranFontSize,
                isFavorited: isFavorited,
                onFavorite: () => _toggleFavorite(ayah, isFavorited),
                onShare: () => _shareAyah(ayah),
              );
            },
            childCount: quranState.currentAyahs.length,
          ),
        ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
      ],
    );
  }

  void _toggleFavorite(AyahModel ayah, bool isFavorited) {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    if (isFavorited) {
      // Find and remove favorite
      final favorite = ref.read(favoritesProvider).favorites.firstWhere(
        (f) => f.reference == 'Quran ${ayah.surahNumber}:${ayah.numberInSurah}',
        orElse: () => throw Exception('Not found'),
      );
      ref.read(favoritesProvider.notifier).removeFavorite(favorite.id);
    } else {
      ref.read(favoritesProvider.notifier).saveAyah(
        userId: user.uid,
        ayah: ayah,
        surahName: widget.surah.englishName,
      );
    }
  }

  void _shareAyah(AyahModel ayah) {
    final text = '''
${ayah.text}

${ayah.translation ?? ''}

- ${widget.surah.englishName} (${widget.surah.name}) ${ayah.surahNumber}:${ayah.numberInSurah}

Shared via Taqwa AI
''';
    Share.share(text.trim());
  }

  void _showFontSizeDialog(BuildContext context) {
    final settings = ref.read(settingsProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quran Font Size'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: settings.quranFontSize.toDouble(),
                  min: 18,
                  max: 40,
                  divisions: 11,
                  label: settings.quranFontSize.toString(),
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier)
                        .setQuranFontSize(value.toInt());
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  'بِسْمِ اللَّهِ',
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: settings.quranFontSize.toDouble(),
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}

/// Surah info card
class _SurahInfoCard extends StatelessWidget {
  final SurahModel surah;

  const _SurahInfoCard({required this.surah});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  surah.englishName,
                  style: AppTypography.titleLarge(
                    color: isDark 
                        ? AppColors.darkTextPrimary 
                        : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  surah.englishNameTranslation,
                  style: AppTypography.bodyMedium(
                    color: isDark 
                        ? AppColors.darkTextSecondary 
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _InfoChip(
                      label: surah.isMakki ? 'Makki' : 'Madani',
                      color: surah.isMakki 
                          ? AppColors.primary 
                          : AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(
                      label: '${surah.numberOfAyahs} Ayahs',
                      color: AppColors.info,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            surah.name,
            style: AppTypography.surahName(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Info chip
class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall(color: color),
      ),
    );
  }
}
