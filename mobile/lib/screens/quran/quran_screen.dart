import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_decorations.dart';
import '../../providers/quran_provider.dart';
import '../../models/surah_model.dart';
import '../../widgets/loading_widget.dart';
import 'surah_reader_screen.dart';

/// Premium Quran Screen - Beautiful Surah list
/// 
/// World-class design with search and categorization
class QuranScreen extends ConsumerStatefulWidget {
  const QuranScreen({super.key});

  @override
  ConsumerState<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends ConsumerState<QuranScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surahsAsync = ref.watch(surahsProvider);
    final lastRead = ref.watch(lastReadProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          // Premium Header with Search
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.headerGradientDeep,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'القرآن الكريم',
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: 28,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'The Noble Quran',
                                    style: AppTypography.bodyLarge(
                                      color: Colors.white.withOpacity(0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Bookmark button
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: IconButton(
                                onPressed: () {},
                                icon: const Icon(
                                  Icons.bookmark_outline,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(72),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: _buildSearchBar(isDark),
                ),
              ),
            ),
          ),
        ],
        body: FadeTransition(
          opacity: _fadeIn,
          child: surahsAsync.when(
            data: (surahs) {
              final filteredSurahs = _filterSurahs(surahs);
              
              return CustomScrollView(
                slivers: [
                  // Last read card
                  if (lastRead != null && _searchQuery.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                        child: _LastReadCard(
                          surah: lastRead,
                          isDark: isDark,
                          onTap: () => _openSurah(context, lastRead),
                        ),
                      ),
                    ),
                  
                  // Surah list
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final surah = filteredSurahs[index];
                          return _SurahItem(
                            surah: surah,
                            isDark: isDark,
                            index: index,
                            onTap: () => _openSurah(context, surah),
                          );
                        },
                        childCount: filteredSurahs.length,
                      ),
                    ),
                  ),
                  
                  // Bottom padding
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 100),
                  ),
                ],
              );
            },
            loading: () => const Center(child: LoadingWidget()),
            error: (e, _) => Center(
              child: Text('Error loading surahs: $e'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search surah...',
          hintStyle: AppTypography.bodyMedium(
            color: isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
          ),
          border: InputBorder.none,
          icon: Icon(
            Icons.search,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                  icon: Icon(
                    Icons.close,
                    color: isDark 
                        ? AppColors.darkTextSecondary 
                        : AppColors.textSecondary,
                    size: 20,
                  ),
                )
              : null,
        ),
        style: AppTypography.bodyMedium(
          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
        ),
      ),
    );
  }

  List<SurahModel> _filterSurahs(List<SurahModel> surahs) {
    if (_searchQuery.isEmpty) return surahs;
    
    final query = _searchQuery.toLowerCase();
    return surahs.where((surah) {
      return surah.name.toLowerCase().contains(query) ||
          surah.englishName.toLowerCase().contains(query) ||
          surah.number.toString().contains(query);
    }).toList();
  }

  void _openSurah(BuildContext context, SurahModel surah) {
    ref.read(quranNotifierProvider.notifier).setLastRead(surah);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SurahReaderScreen(surah: surah),
      ),
    );
  }
}

class _LastReadCard extends StatelessWidget {
  final SurahModel surah;
  final bool isDark;
  final VoidCallback onTap;

  const _LastReadCard({
    required this.surah,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Surah number
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  surah.number.toString(),
                  style: AppTypography.titleLarge(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // Surah info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.bookmark_rounded,
                        color: AppColors.gold,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Continue Reading',
                        style: AppTypography.labelSmall(color: AppColors.gold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    surah.englishName,
                    style: AppTypography.titleMedium(color: Colors.white),
                  ),
                  Text(
                    '${surah.ayahCount} Ayahs • ${surah.revelationType}',
                    style: AppTypography.bodySmall(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            
            // Arabic name
            Text(
              surah.name,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 24,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SurahItem extends StatelessWidget {
  final SurahModel surah;
  final bool isDark;
  final int index;
  final VoidCallback onTap;

  const _SurahItem({
    required this.surah,
    required this.isDark,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 200 + (index * 30).clamp(0, 300)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.15 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Number badge
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        surah.number.toString(),
                        style: AppTypography.titleSmall(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Surah name
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
                        const SizedBox(height: 4),
                        Text(
                          '${surah.ayahCount} Ayahs • ${surah.revelationType}',
                          style: AppTypography.bodySmall(
                            color: isDark 
                                ? AppColors.darkTextSecondary 
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Arabic name
                  Text(
                    surah.name,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 22,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
