import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../providers/quran_provider.dart';
import '../../models/surah_model.dart';
import '../../widgets/loading_widget.dart';
import 'surah_reader_screen.dart';

/// Quran screen - Surah list
class QuranScreen extends ConsumerWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final quranState = ref.watch(quranProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 120,
            backgroundColor: theme.colorScheme.background,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'القرآن الكريم',
                style: AppTypography.arabicTitle(
                  color: isDark 
                      ? AppColors.darkTextPrimary 
                      : AppColors.textPrimary,
                ),
              ),
              centerTitle: true,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // TODO: Show search
                },
              ),
              IconButton(
                icon: const Icon(Icons.bookmark_outline),
                onPressed: () {
                  _continueReading(context, ref);
                },
                tooltip: 'Continue Reading',
              ),
            ],
          ),

          // Last read position
          SliverToBoxAdapter(
            child: _LastReadCard(quranState: quranState),
          ),

          // Surah list header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  Text(
                    'Surahs',
                    style: AppTypography.titleMedium(
                      color: isDark 
                          ? AppColors.darkTextPrimary 
                          : AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${quranState.surahs.length} Surahs',
                    style: AppTypography.labelSmall(
                      color: isDark 
                          ? AppColors.darkTextSecondary 
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Surah list
          quranState.isLoading
              ? SliverFillRemaining(
                  child: LoadingWidget(message: 'Loading Quran...'),
                )
              : SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final surah = quranState.surahs[index];
                      return _SurahListItem(
                        surah: surah,
                        onTap: () => _openSurah(context, ref, surah),
                      );
                    },
                    childCount: quranState.surahs.length,
                  ),
                ),
        ],
      ),
    );
  }

  void _openSurah(BuildContext context, WidgetRef ref, SurahModel surah) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SurahReaderScreen(surah: surah),
      ),
    );
  }

  void _continueReading(BuildContext context, WidgetRef ref) {
    final lastPosition = ref.read(quranProvider.notifier).getLastReadPosition();
    if (lastPosition != null) {
      final surahNumber = lastPosition['surahNumber'] as int;
      final surah = ref.read(quranProvider).surahs.firstWhere(
        (s) => s.number == surahNumber,
        orElse: () => SurahList.surahs[surahNumber - 1],
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SurahReaderScreen(
            surah: surah,
            initialAyah: lastPosition['ayahNumber'] as int,
          ),
        ),
      );
    }
  }
}

/// Last read card
class _LastReadCard extends StatelessWidget {
  final QuranState quranState;

  const _LastReadCard({required this.quranState});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // In a real app, this would come from the provider
    // For now, showing a static card
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.goldGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Continue Reading',
                  style: AppTypography.labelMedium(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Al-Fatihah',
                  style: AppTypography.titleLarge(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ayah 1 of 7',
                  style: AppTypography.bodySmall(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }
}

/// Surah list item
class _SurahListItem extends StatelessWidget {
  final SurahModel surah;
  final VoidCallback onTap;

  const _SurahListItem({
    required this.surah,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? AppColors.darkDivider : AppColors.divider,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          children: [
            // Surah number
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  surah.number.toString(),
                  style: AppTypography.labelLarge(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Surah info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.englishName,
                    style: AppTypography.titleSmall(
                      color: isDark 
                          ? AppColors.darkTextPrimary 
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: surah.isMakki
                              ? AppColors.primary.withOpacity(0.1)
                              : AppColors.secondary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          surah.isMakki ? 'Makki' : 'Madani',
                          style: AppTypography.labelSmall(
                            color: surah.isMakki 
                                ? AppColors.primary 
                                : AppColors.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${surah.numberOfAyahs} Ayahs',
                        style: AppTypography.bodySmall(
                          color: isDark 
                              ? AppColors.darkTextSecondary 
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Arabic name
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  surah.name,
                  style: AppTypography.arabicBody(
                    color: isDark 
                        ? AppColors.darkTextPrimary 
                        : AppColors.textPrimary,
                  ),
                ),
                Text(
                  surah.englishNameTranslation,
                  style: AppTypography.labelSmall(
                    color: isDark 
                        ? AppColors.darkTextSecondary 
                        : AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
