import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_decorations.dart';

/// Prayer Times Screen - Full prayer schedule
/// 
/// Premium design with location-based times and countdown
class PrayerTimesScreen extends ConsumerStatefulWidget {
  const PrayerTimesScreen({super.key});

  @override
  ConsumerState<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends ConsumerState<PrayerTimesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;

  // Mock data - will be replaced with real API
  final List<_PrayerTimeData> _prayers = [
    _PrayerTimeData(
      name: 'Fajr',
      arabicName: 'الفجر',
      time: '05:12 AM',
      icon: Icons.wb_twilight,
      color: const Color(0xFF5C6BC0),
      isPassed: true,
    ),
    _PrayerTimeData(
      name: 'Sunrise',
      arabicName: 'الشروق',
      time: '06:42 AM',
      icon: Icons.wb_sunny_outlined,
      color: const Color(0xFFFFB74D),
      isPassed: true,
    ),
    _PrayerTimeData(
      name: 'Dhuhr',
      arabicName: 'الظهر',
      time: '12:30 PM',
      icon: Icons.wb_sunny,
      color: const Color(0xFFFFD54F),
      isPassed: true,
    ),
    _PrayerTimeData(
      name: 'Asr',
      arabicName: 'العصر',
      time: '03:45 PM',
      icon: Icons.wb_cloudy,
      color: const Color(0xFFFF8A65),
      isPassed: false,
      isCurrent: true,
      countdown: '2h 30m',
    ),
    _PrayerTimeData(
      name: 'Maghrib',
      arabicName: 'المغرب',
      time: '06:15 PM',
      icon: Icons.wb_twilight,
      color: const Color(0xFFE57373),
      isPassed: false,
    ),
    _PrayerTimeData(
      name: 'Isha',
      arabicName: 'العشاء',
      time: '07:45 PM',
      icon: Icons.nightlight_round,
      color: const Color(0xFF7986CB),
      isPassed: false,
    ),
  ];

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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final currentPrayer = _prayers.firstWhere((p) => p.isCurrent, orElse: () => _prayers.first);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Premium Header
          SliverAppBar(
            expandedHeight: 260,
            floating: false,
            pinned: true,
            backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
                ),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.headerGradientDeep,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Location
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.location_on, color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Islamabad, Pakistan',
                              style: AppTypography.labelMedium(
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down, color: Colors.white70, size: 18),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Current prayer highlight
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.15),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                currentPrayer.icon,
                                color: currentPrayer.color,
                                size: 40,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                currentPrayer.name,
                                style: AppTypography.headlineSmall(color: Colors.white),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currentPrayer.time,
                                style: AppTypography.titleLarge(
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),
                              if (currentPrayer.countdown != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.gold.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    'Time remaining: ${currentPrayer.countdown}',
                                    style: AppTypography.labelSmall(color: AppColors.gold),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Prayer times list
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: FadeTransition(
                opacity: _fadeIn,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Today's Prayers",
                        style: AppTypography.titleMedium(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Prayer time cards
                      ...List.generate(_prayers.length, (index) {
                        final prayer = _prayers[index];
                        return _PrayerTimeCard(
                          prayer: prayer,
                          isDark: isDark,
                          index: index,
                        );
                      }),
                      
                      const SizedBox(height: 24),
                      
                      // Qibla direction quick access
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: AppColors.cardGradient,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.explore_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Qibla Direction',
                                    style: AppTypography.titleMedium(color: Colors.white),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Find the direction to pray',
                                    style: AppTypography.bodySmall(
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 100),
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

class _PrayerTimeData {
  final String name;
  final String arabicName;
  final String time;
  final IconData icon;
  final Color color;
  final bool isPassed;
  final bool isCurrent;
  final String? countdown;

  _PrayerTimeData({
    required this.name,
    required this.arabicName,
    required this.time,
    required this.icon,
    required this.color,
    this.isPassed = false,
    this.isCurrent = false,
    this.countdown,
  });
}

class _PrayerTimeCard extends StatelessWidget {
  final _PrayerTimeData prayer;
  final bool isDark;
  final int index;

  const _PrayerTimeCard({
    required this.prayer,
    required this.isDark,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: prayer.isCurrent
              ? AppColors.primary.withOpacity(0.1)
              : (isDark ? AppColors.darkCard : AppColors.lightCard),
          borderRadius: BorderRadius.circular(20),
          border: prayer.isCurrent
              ? Border.all(color: AppColors.primary, width: 1.5)
              : Border.all(
                  color: isDark
                      ? AppColors.darkBorder.withOpacity(0.3)
                      : AppColors.border.withOpacity(0.5),
                ),
          boxShadow: prayer.isCurrent
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: prayer.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                prayer.icon,
                color: prayer.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Name and Arabic
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    prayer.name,
                    style: AppTypography.titleSmall(
                      color: prayer.isCurrent
                          ? AppColors.primary
                          : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                    ),
                  ),
                  Text(
                    prayer.arabicName,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Time
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  prayer.time,
                  style: AppTypography.titleSmall(
                    color: prayer.isCurrent
                        ? AppColors.primary
                        : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                  ),
                ),
                if (prayer.isPassed)
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Passed',
                        style: AppTypography.labelSmall(color: AppColors.success),
                      ),
                    ],
                  ),
                if (prayer.isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Current',
                      style: AppTypography.labelSmall(color: Colors.white),
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
