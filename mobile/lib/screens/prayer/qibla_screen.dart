import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Qibla Compass Screen - Find direction to Kaaba
/// 
/// Premium full-screen compass with elegant design
class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<double> _compassRotate;
  
  // Mock qibla direction - will be calculated from location
  final double _qiblaDirection = 245.0; // degrees from north
  double _currentHeading = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    
    _compassRotate = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
      ),
    );
    
    _controller.forward();
    
    // Simulate compass movement for demo
    _simulateCompass();
  }

  void _simulateCompass() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          // Slowly rotate to demonstrate
          _currentHeading = (_currentHeading + 0.5) % 360;
        });
        _simulateCompass();
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;
    
    // Calculate if pointing to qibla (within 5 degrees)
    final diff = (_qiblaDirection - _currentHeading).abs();
    final isPointingQibla = diff < 5 || diff > 355;

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
                      icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCard
                              : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                          size: 18,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Qibla',
                      style: AppTypography.titleLarge(
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCard
                              : AppColors.lightCard,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.info_outline,
                          color: isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.textPrimary,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Location
              FadeTransition(
                opacity: _fadeIn,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Islamabad, Pakistan',
                          style: AppTypography.bodyMedium(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_qiblaDirection.toStringAsFixed(1)}° from North',
                      style: AppTypography.labelMedium(
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              
              const Spacer(),
              
              // Compass
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 0.5 + (_compassRotate.value * 0.5),
                    child: Opacity(
                      opacity: _fadeIn.value,
                      child: child,
                    ),
                  );
                },
                child: SizedBox(
                  width: size.width * 0.85,
                  height: size.width * 0.85,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer ring
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.gold.withOpacity(0.3),
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withOpacity(0.1),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      
                      // Compass background
                      Container(
                        width: size.width * 0.75,
                        height: size.width * 0.75,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              AppColors.primary.withOpacity(0.1),
                              AppColors.primary.withOpacity(0.05),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.2),
                            width: 2,
                          ),
                        ),
                      ),
                      
                      // Direction markers
                      Transform.rotate(
                        angle: -_currentHeading * (pi / 180),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // North marker
                            Positioned(
                              top: 20,
                              child: Column(
                                children: [
                                  Text(
                                    'N',
                                    style: AppTypography.titleLarge(
                                      color: AppColors.primary,
                                    ).copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                            // East marker
                            Positioned(
                              right: 20,
                              child: Text(
                                'E',
                                style: AppTypography.titleMedium(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            // South marker
                            Positioned(
                              bottom: 20,
                              child: Text(
                                'S',
                                style: AppTypography.titleMedium(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            // West marker
                            Positioned(
                              left: 20,
                              child: Text(
                                'W',
                                style: AppTypography.titleMedium(
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            
                            // Qibla direction indicator
                            Transform.rotate(
                              angle: _qiblaDirection * (pi / 180),
                              child: Column(
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) => LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        AppColors.gold,
                                        AppColors.goldDark,
                                      ],
                                    ).createShader(bounds),
                                    child: Icon(
                                      Icons.navigation_rounded,
                                      size: 48,
                                      color: Colors.white,
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.gold,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      'QIBLA',
                                      style: AppTypography.labelSmall(
                                        color: Colors.white,
                                      ).copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  SizedBox(height: size.width * 0.25),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Center Kaaba icon
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkCard : AppColors.lightCard,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '🕋',
                            style: const TextStyle(fontSize: 36),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Status message
              FadeTransition(
                opacity: _fadeIn,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isPointingQibla
                        ? AppColors.success.withOpacity(0.15)
                        : (isDark ? AppColors.darkCard : AppColors.lightCard),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isPointingQibla
                          ? AppColors.success
                          : (isDark ? AppColors.darkBorder : AppColors.border),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isPointingQibla
                            ? Icons.check_circle
                            : Icons.info_outline,
                        color: isPointingQibla
                            ? AppColors.success
                            : AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isPointingQibla
                            ? 'You are facing the Qibla!'
                            : 'Rotate to find the Qibla direction',
                        style: AppTypography.bodyMedium(
                          color: isPointingQibla
                              ? AppColors.success
                              : (isDark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Distance to Mecca
              FadeTransition(
                opacity: _fadeIn,
                child: Text(
                  '3,420 km to Mecca',
                  style: AppTypography.labelMedium(
                    color: isDark
                        ? AppColors.darkTextTertiary
                        : AppColors.textTertiary,
                  ),
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper widget for animated builders
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
