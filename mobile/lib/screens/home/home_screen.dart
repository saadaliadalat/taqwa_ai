import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/quran_provider.dart';
import '../../models/ayah_model.dart';
import '../../utils/helpers.dart';
import '../main_layout.dart';
import '../prayer/prayer_times_screen.dart';
import '../prayer/qibla_screen.dart';
import '../favorites/favorites_screen.dart';

/// Premium Home Screen with prayer times and quick actions
/// 
/// Features gradient header, daily verse, and beautiful card layout
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  // Mock prayer times - will be replaced with real API
  final List<_PrayerTime> _prayerTimes = [
    _PrayerTime(name: 'Fajr', time: '05:12', isPassed: true),
    _PrayerTime(name: 'Sunrise', time: '06:42', isPassed: true),
    _PrayerTime(name: 'Dhuhr', time: '12:30', isPassed: true),
    _PrayerTime(name: 'Asr', time: '15:45', isPassed: false, isCurrent: true),
    _PrayerTime(name: 'Maghrib', time: '18:15', isPassed: false),
    _PrayerTime(name: 'Isha', time: '19:45', isPassed: false),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final userData = ref.watch(userDataStreamProvider);
    final dailyAyah = ref.watch(dailyAyahProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Premium Gradient Header
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.headerGradientDeep,
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // App bar row
                        Row(
                          children: [
                            // Logo
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: Center(
                                child: ShaderMask(
                                  shaderCallback: (bounds) => const LinearGradient(
                                    colors: [Colors.white, Color(0xFFE4C767)],
                                  ).createShader(bounds),
                                  child: const Text(
                                    'ت',
                                    style: TextStyle(
                                      fontFamily: 'Amiri',
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Taqwa AI',
                              style: AppTypography.titleLarge(color: Colors.white),
                            ),
                            const Spacer(),
                            // Notification bell
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white,
                                ),
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 28),
                        
                        // Greeting
                        Text(
                          'Assalamu Alaikum,',
                          style: AppTypography.bodyLarge(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userData.valueOrNull?.displayName ?? 'Guest',
                          style: AppTypography.headlineMedium(
                            color: Colors.white,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Daily verse preview
                        dailyAyah.when(
                          data: (ayah) => ayah != null
                              ? _DailyVerseCard(ayah: ayah)
                              : const SizedBox.shrink(),
                          loading: () => _DailyVerseCardShimmer(),
                          error: (_, __) => const SizedBox.shrink(),
                        ),
                        
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Curved transition
          SliverToBoxAdapter(
            child: Container(
              height: 24,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
            ),
          ),
          
          // Main content
          SliverToBoxAdapter(
            child: Container(
              color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
              child: FadeTransition(
                opacity: _fadeIn,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Quick Links section
                      Text(
                        'Quick Links',
                        style: AppTypography.titleMedium(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _QuickLinksRow(isDark: isDark),
                      
                      const SizedBox(height: 28),
                      
                      // Prayer Times section
                      _PrayerTimesCard(
                        prayerTimes: _prayerTimes,
                        isDark: isDark,
                      ),
                      
                      const SizedBox(height: 28),
                      
                      // Features section
                      Text(
                        'Explore',
                        style: AppTypography.titleMedium(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _FeatureCards(isDark: isDark),
                      
                      const SizedBox(height: 100), // Bottom padding for nav bar
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Daily verse card with premium styling
class _DailyVerseCard extends StatelessWidget {
  final AyahModel ayah;

  const _DailyVerseCard({required this.ayah});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: AppColors.gold,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Daily verse of the day',
                      style: AppTypography.labelSmall(color: AppColors.gold),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                Helpers.getSurahName(ayah.surahNumber),
                style: AppTypography.labelSmall(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            ayah.text,
            style: AppTypography.quranMedium(color: Colors.white).copyWith(fontSize: 20),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (ayah.hasTranslation) ...[
            const SizedBox(height: 12),
            Text(
              ayah.translation!,
              style: AppTypography.bodySmall(
                color: Colors.white.withOpacity(0.8),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

class _DailyVerseCardShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

/// Quick links row with Chat, Quran, Prayer, Qibla
class _QuickLinksRow extends ConsumerWidget {
  final bool isDark;

  const _QuickLinksRow({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quickLinks = [
      _QuickLink(
        icon: Icons.auto_awesome,
        label: 'Chat with AI',
        color: AppColors.primary,
        onTap: () => ref.read(tabIndexProvider.notifier).state = 1,
      ),
      _QuickLink(
        icon: Icons.menu_book_rounded,
        label: 'Read Quran',
        color: AppColors.gold,
        onTap: () => ref.read(tabIndexProvider.notifier).state = 2,
      ),
      _QuickLink(
        icon: Icons.access_time_rounded,
        label: 'Prayer Times',
        color: const Color(0xFF5C6BC0),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PrayerTimesScreen()),
          );
        },
      ),
      _QuickLink(
        icon: Icons.explore_rounded,
        label: 'Qibla',
        color: const Color(0xFFE57373),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const QiblaScreen()),
          );
        },
      ),
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: quickLinks.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final link = quickLinks[index];
          return _QuickLinkCard(
            link: link,
            isDark: isDark,
          );
        },
      ),
    );
  }
}

class _QuickLink {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _QuickLink({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

class _QuickLinkCard extends StatelessWidget {
  final _QuickLink link;
  final bool isDark;

  const _QuickLinkCard({required this.link, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: link.onTap,
      child: Container(
        width: 90,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: link.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                link.icon,
                color: link.color,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              link.label,
              style: AppTypography.labelSmall(
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

/// Prayer times card
class _PrayerTimesCard extends StatelessWidget {
  final List<_PrayerTime> prayerTimes;
  final bool isDark;

  const _PrayerTimesCard({
    required this.prayerTimes,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.cardGradient,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prayer Times',
                      style: AppTypography.labelMedium(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          "Today's Prayers in Islamabad",
                          style: AppTypography.titleSmall(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PrayerTimesScreen()),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'View All',
                      style: AppTypography.labelSmall(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Prayer times list
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: prayerTimes.map((prayer) {
                return _PrayerTimeItem(prayer: prayer, isDark: isDark);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrayerTime {
  final String name;
  final String time;
  final bool isPassed;
  final bool isCurrent;

  _PrayerTime({
    required this.name,
    required this.time,
    this.isPassed = false,
    this.isCurrent = false,
  });
}

class _PrayerTimeItem extends StatelessWidget {
  final _PrayerTime prayer;
  final bool isDark;

  const _PrayerTimeItem({required this.prayer, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isActive = prayer.isCurrent;
    
    return Column(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary
                : prayer.isPassed
                    ? AppColors.success
                    : (isDark ? AppColors.darkBorder : AppColors.border),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          prayer.name,
          style: AppTypography.labelSmall(
            color: isActive
                ? AppColors.primary
                : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
          ).copyWith(fontWeight: isActive ? FontWeight.w600 : FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Text(
          prayer.time,
          style: AppTypography.bodySmall(
            color: isActive
                ? AppColors.primary
                : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
          ).copyWith(fontWeight: isActive ? FontWeight.w600 : FontWeight.w400),
        ),
      ],
    );
  }
}

/// Feature cards section
class _FeatureCards extends ConsumerWidget {
  final bool isDark;

  const _FeatureCards({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _FeatureCard(
                icon: Icons.lightbulb_outline,
                title: 'Daily Wisdom',
                subtitle: 'Islamic insights',
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C4DFF), Color(0xFF536DFE)],
                ),
                isDark: isDark,
                onTap: () => ref.read(tabIndexProvider.notifier).state = 1,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FeatureCard(
                icon: Icons.favorite_outline,
                title: 'Duas',
                subtitle: 'Supplications',
                gradient: const LinearGradient(
                  colors: [Color(0xFFE57373), Color(0xFFEF5350)],
                ),
                isDark: isDark,
                onTap: () => ref.read(tabIndexProvider.notifier).state = 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _FeatureCard(
                icon: Icons.bookmark_outline,
                title: 'Saved',
                subtitle: 'Your favorites',
                gradient: const LinearGradient(
                  colors: [Color(0xFF4DB6AC), Color(0xFF26A69A)],
                ),
                isDark: isDark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FeatureCard(
                icon: Icons.access_time_rounded,
                title: 'Prayers',
                subtitle: 'Prayer times',
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB74D), Color(0xFFFFA726)],
                ),
                isDark: isDark,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PrayerTimesScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final bool isDark;
  final VoidCallback? onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Colors.white, size: 28),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.titleSmall(color: Colors.white),
                    ),
                    Text(
                      subtitle,
                      style: AppTypography.labelSmall(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
