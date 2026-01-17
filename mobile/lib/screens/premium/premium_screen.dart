import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_decorations.dart';

/// Premium Screen - Subscription upgrade
/// 
/// Premium design with feature comparison and pricing options
class PremiumScreen extends ConsumerStatefulWidget {
  const PremiumScreen({super.key});

  @override
  ConsumerState<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends ConsumerState<PremiumScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  bool _isYearly = true;

  final List<_PremiumFeature> _features = [
    _PremiumFeature(
      icon: Icons.auto_awesome,
      title: 'Unlimited AI Chats',
      description: 'Ask unlimited questions',
      isFree: false,
    ),
    _PremiumFeature(
      icon: Icons.cloud_download_outlined,
      title: 'Offline Quran Audio',
      description: 'Download for offline',
      isFree: false,
    ),
    _PremiumFeature(
      icon: Icons.wallpaper,
      title: 'Exclusive Wallpapers',
      description: 'Beautiful Islamic art',
      isFree: false,
    ),
    _PremiumFeature(
      icon: Icons.block,
      title: 'Ad-Free Experience',
      description: 'No interruptions',
      isFree: false,
    ),
    _PremiumFeature(
      icon: Icons.school,
      title: 'Advanced Learning',
      description: 'In-depth courses',
      isFree: false,
    ),
    _PremiumFeature(
      icon: Icons.support_agent,
      title: 'Priority Support',
      description: '24/7 assistance',
      isFree: false,
    ),
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

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.darkBackground, AppColors.darkSurface]
                : [AppColors.lightBackground, AppColors.lightSurface],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Restore Purchases',
                        style: AppTypography.labelMedium(color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: FadeTransition(
                    opacity: _fadeIn,
                    child: Column(
                      children: [
                        // Premium badge
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: AppColors.goldGradient,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withOpacity(0.4),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.workspace_premium,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Text(
                          'Unlock Full Potential',
                          style: AppTypography.headlineMedium(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'with Taqwa Premium',
                          style: AppTypography.titleLarge(
                            color: AppColors.gold,
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Features grid
                        Text(
                          'Benefits',
                          style: AppTypography.titleMedium(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.4,
                          ),
                          itemCount: _features.length,
                          itemBuilder: (context, index) {
                            return _FeatureCard(
                              feature: _features[index],
                              isDark: isDark,
                              index: index,
                            );
                          },
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Pricing section
                        Text(
                          'Pricing',
                          style: AppTypography.titleMedium(
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Toggle
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkCard
                                : AppColors.lightSurface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _PricingToggle(
                                  label: 'Monthly',
                                  isSelected: !_isYearly,
                                  onTap: () => setState(() => _isYearly = false),
                                  isDark: isDark,
                                ),
                              ),
                              Expanded(
                                child: Stack(
                                  children: [
                                    _PricingToggle(
                                      label: 'Yearly',
                                      isSelected: _isYearly,
                                      onTap: () => setState(() => _isYearly = true),
                                      isDark: isDark,
                                    ),
                                    Positioned(
                                      right: 8,
                                      top: 4,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.success,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '-40%',
                                          style: AppTypography.labelSmall(
                                            color: Colors.white,
                                          ).copyWith(fontSize: 9),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Price display
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _PriceCard(
                            key: ValueKey(_isYearly),
                            price: _isYearly ? '\$49.99' : '\$6.99',
                            period: _isYearly ? '/year' : '/month',
                            subtitle: _isYearly
                                ? 'That\'s only \$4.17/month'
                                : 'Cancel anytime',
                            isDark: isDark,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Upgrade button
                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: AppColors.goldGradient,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.gold.withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  // TODO: Implement purchase
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.workspace_premium,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Upgrade Now',
                                        style: AppTypography.titleMedium(
                                          color: Colors.white,
                                        ).copyWith(fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Terms
                        Text(
                          'Auto-renewable. Cancel anytime.',
                          style: AppTypography.bodySmall(
                            color: isDark
                                ? AppColors.darkTextTertiary
                                : AppColors.textTertiary,
                          ),
                        ),
                        
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PremiumFeature {
  final IconData icon;
  final String title;
  final String description;
  final bool isFree;

  _PremiumFeature({
    required this.icon,
    required this.title,
    required this.description,
    required this.isFree,
  });
}

class _FeatureCard extends StatelessWidget {
  final _PremiumFeature feature;
  final bool isDark;
  final int index;

  const _FeatureCard({
    required this.feature,
    required this.isDark,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + (index * 100)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(
            scale: 0.8 + (value * 0.2),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? AppColors.darkBorder.withOpacity(0.3)
                : AppColors.border.withOpacity(0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    feature.icon,
                    color: AppColors.gold,
                    size: 20,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.check_circle,
                  color: AppColors.gold,
                  size: 20,
                ),
              ],
            ),
            const Spacer(),
            Text(
              feature.title,
              style: AppTypography.labelMedium(
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              feature.description,
              style: AppTypography.labelSmall(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _PricingToggle extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;

  const _PricingToggle({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.labelLarge(
              color: isSelected
                  ? Colors.white
                  : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final String price;
  final String period;
  final String subtitle;
  final bool isDark;

  const _PriceCard({
    super.key,
    required this.price,
    required this.period,
    required this.subtitle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                price,
                style: AppTypography.displaySmall(color: Colors.white),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  period,
                  style: AppTypography.bodyLarge(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTypography.bodyMedium(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}
