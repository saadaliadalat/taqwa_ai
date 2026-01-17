import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Taqwa AI Design System - Premium Decorations
/// 
/// Reusable decoration presets for consistent, premium visual styling.
/// Includes glassmorphism effects, gradients, and sophisticated shadows.
class AppDecorations {
  AppDecorations._();

  // ============================================
  // Card Decorations
  // ============================================
  
  /// Standard card decoration - light theme
  static BoxDecoration cardLight = BoxDecoration(
    color: AppColors.lightCard,
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.04),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.02),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );
  
  /// Standard card decoration - dark theme
  static BoxDecoration cardDark = BoxDecoration(
    color: AppColors.darkCard,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: AppColors.darkBorder.withOpacity(0.3),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.3),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
  
  /// Elevated card with stronger shadow
  static BoxDecoration cardElevated(bool isDark) => BoxDecoration(
    color: isDark ? AppColors.darkCardElevated : AppColors.lightCardElevated,
    borderRadius: BorderRadius.circular(24),
    border: isDark ? Border.all(
      color: AppColors.darkBorder.withOpacity(0.2),
      width: 1,
    ) : null,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.4 : 0.08),
        blurRadius: 30,
        offset: const Offset(0, 10),
      ),
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // ============================================
  // Gradient Header Decorations
  // ============================================
  
  /// Primary gradient header - signature look
  static BoxDecoration headerGradient = const BoxDecoration(
    gradient: AppColors.headerGradient,
  );
  
  /// Header with rounded bottom corners
  static BoxDecoration headerRounded = BoxDecoration(
    gradient: AppColors.headerGradientDeep,
    borderRadius: const BorderRadius.only(
      bottomLeft: Radius.circular(32),
      bottomRight: Radius.circular(32),
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.3),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
  
  /// Premium gradient card
  static BoxDecoration gradientCard = BoxDecoration(
    gradient: AppColors.cardGradient,
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.4),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: AppColors.primary.withOpacity(0.2),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  // ============================================
  // Glassmorphism Effects
  // ============================================
  
  /// Glass card overlay - use on top of gradients
  static BoxDecoration glassCard = BoxDecoration(
    gradient: AppColors.glassOverlay,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.white.withOpacity(0.1),
      width: 1,
    ),
  );
  
  /// Glass button style
  static BoxDecoration glassButton = BoxDecoration(
    color: Colors.white.withOpacity(0.15),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.white.withOpacity(0.2),
      width: 1,
    ),
  );
  
  /// Frosted glass for overlays
  static BoxDecoration frostedGlass(bool isDark) => BoxDecoration(
    color: (isDark ? Colors.black : Colors.white).withOpacity(0.7),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
      width: 1,
    ),
  );

  // ============================================
  // Input Decorations
  // ============================================
  
  /// Search bar decoration
  static BoxDecoration searchBar(bool isDark) => BoxDecoration(
    color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: isDark ? AppColors.darkBorder : AppColors.border,
      width: 1,
    ),
  );
  
  /// Chat input decoration
  static BoxDecoration chatInput(bool isDark) => BoxDecoration(
    color: isDark ? AppColors.darkCard : AppColors.lightCard,
    borderRadius: BorderRadius.circular(28),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
        blurRadius: 20,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // ============================================
  // Button Decorations
  // ============================================
  
  /// Primary button decoration
  static BoxDecoration primaryButton = BoxDecoration(
    gradient: AppColors.cardGradient,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.primary.withOpacity(0.4),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );
  
  /// Secondary button decoration
  static BoxDecoration secondaryButton(bool isDark) => BoxDecoration(
    color: isDark ? AppColors.darkCard : AppColors.lightCard,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppColors.primary,
      width: 1.5,
    ),
  );
  
  /// Gold premium button
  static BoxDecoration goldButton = BoxDecoration(
    gradient: AppColors.goldGradient,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: AppColors.gold.withOpacity(0.4),
        blurRadius: 16,
        offset: const Offset(0, 6),
      ),
    ],
  );
  
  /// Icon button circular
  static BoxDecoration iconButton(bool isDark) => BoxDecoration(
    color: isDark 
        ? Colors.white.withOpacity(0.1) 
        : Colors.black.withOpacity(0.05),
    shape: BoxShape.circle,
  );

  // ============================================
  // Navigation Decorations
  // ============================================
  
  /// Bottom navigation bar
  static BoxDecoration bottomNav(bool isDark) => BoxDecoration(
    color: isDark ? AppColors.darkCard : AppColors.lightCard,
    borderRadius: const BorderRadius.only(
      topLeft: Radius.circular(24),
      topRight: Radius.circular(24),
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
        blurRadius: 20,
        offset: const Offset(0, -4),
      ),
    ],
  );
  
  /// Tab indicator
  static BoxDecoration tabIndicator = BoxDecoration(
    color: AppColors.primary,
    borderRadius: BorderRadius.circular(3),
  );

  // ============================================
  // Special Elements
  // ============================================
  
  /// Prayer time card
  static BoxDecoration prayerCard(Color color, bool isDark) => BoxDecoration(
    color: isDark 
        ? color.withOpacity(0.15) 
        : color.withOpacity(0.1),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: color.withOpacity(0.3),
      width: 1,
    ),
  );
  
  /// Qibla compass ring
  static BoxDecoration compassRing = BoxDecoration(
    shape: BoxShape.circle,
    border: Border.all(
      color: AppColors.gold,
      width: 3,
    ),
    boxShadow: [
      BoxShadow(
        color: AppColors.gold.withOpacity(0.3),
        blurRadius: 20,
        spreadRadius: 2,
      ),
    ],
  );
  
  /// Avatar decoration
  static BoxDecoration avatar(bool isDark) => BoxDecoration(
    color: isDark ? AppColors.darkCardElevated : AppColors.lightSurface,
    shape: BoxShape.circle,
    border: Border.all(
      color: AppColors.primary.withOpacity(0.2),
      width: 2,
    ),
  );
  
  /// Badge decoration
  static BoxDecoration badge = BoxDecoration(
    gradient: AppColors.goldGradient,
    borderRadius: BorderRadius.circular(12),
  );
  
  /// Chip/tag decoration
  static BoxDecoration chip(bool isDark, {bool selected = false}) => BoxDecoration(
    color: selected 
        ? AppColors.primary.withOpacity(0.15)
        : (isDark ? AppColors.darkSurface : AppColors.lightSurface),
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: selected 
          ? AppColors.primary 
          : (isDark ? AppColors.darkBorder : AppColors.border),
      width: selected ? 1.5 : 1,
    ),
  );
  
  /// Divider with padding
  static Widget divider(bool isDark) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Divider(
      color: isDark ? AppColors.darkDivider : AppColors.divider,
      thickness: 1,
    ),
  );
}

/// Extension for easy access to decorations based on theme
extension ThemeDecorations on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  
  BoxDecoration get card => isDark ? AppDecorations.cardDark : AppDecorations.cardLight;
  BoxDecoration get cardElevated => AppDecorations.cardElevated(isDark);
  BoxDecoration get searchBar => AppDecorations.searchBar(isDark);
  BoxDecoration get chatInput => AppDecorations.chatInput(isDark);
  BoxDecoration get bottomNav => AppDecorations.bottomNav(isDark);
  BoxDecoration get iconButton => AppDecorations.iconButton(isDark);
  BoxDecoration get avatar => AppDecorations.avatar(isDark);
  BoxDecoration get frostedGlass => AppDecorations.frostedGlass(isDark);
  BoxDecoration get secondaryButton => AppDecorations.secondaryButton(isDark);
  BoxDecoration chip({bool selected = false}) => AppDecorations.chip(isDark, selected: selected);
  BoxDecoration prayerCard(Color color) => AppDecorations.prayerCard(color, isDark);
  Widget get divider => AppDecorations.divider(isDark);
}
