import 'package:flutter/material.dart';

/// Taqwa AI Design System - Premium Colors
/// 
/// A sophisticated, calm color palette designed for Islamic aesthetics.
/// Deep emerald greens with warm gold accents create a premium, trustworthy feel.
class AppColors {
  AppColors._();

  // ============================================
  // Primary Brand Colors - Deep Emerald
  // ============================================
  
  /// Primary brand color - Deep emerald green
  static const Color primary = Color(0xFF0D5A3C);
  
  /// Primary light - softer emerald for hover states
  static const Color primaryLight = Color(0xFF1A7A54);
  
  /// Primary dark - deeper for pressed states
  static const Color primaryDark = Color(0xFF084228);
  
  /// Primary surface - very subtle green tint
  static const Color primarySurface = Color(0xFFE8F5EE);

  // ============================================
  // Secondary - Premium Gold Accents
  // ============================================
  
  /// Gold accent - for premium elements and highlights
  static const Color gold = Color(0xFFD4AF37);
  
  /// Secondary color alias (same as gold for backwards compatibility)
  static const Color secondary = gold;
  
  /// Text on secondary/gold background
  static const Color textOnSecondary = Color(0xFF1A1A1A);
  
  /// Secondary light - softer gold variant (alias for goldLight)
  static const Color secondaryLight = Color(0xFFE4C767);
  
  /// Gold light - softer gold
  static const Color goldLight = Color(0xFFE4C767);
  
  /// Gold dark - deeper gold
  static const Color goldDark = Color(0xFFB8972E);
  
  /// Gold muted - for subtle accents
  static const Color goldMuted = Color(0xFFC9B896);

  // ============================================
  // Light Theme Colors
  // ============================================
  
  /// Light background - warm off-white
  static const Color lightBackground = Color(0xFFFAFAF8);
  
  /// Light surface - slightly warm
  static const Color lightSurface = Color(0xFFF5F5F2);
  
  /// Light card - pure white with softness
  static const Color lightCard = Color(0xFFFFFFFF);
  
  /// Light card elevated - subtle shadow
  static const Color lightCardElevated = Color(0xFFFDFDFD);

  // ============================================
  // Dark Theme Colors - Deep Islamic Greens
  // ============================================
  
  /// Dark background - deep forest
  static const Color darkBackground = Color(0xFF0A1F17);
  
  /// Dark surface - slightly lighter
  static const Color darkSurface = Color(0xFF122B21);
  
  /// Dark card - elevated surface
  static const Color darkCard = Color(0xFF1A3D2E);
  
  /// Dark card elevated - even lighter
  static const Color darkCardElevated = Color(0xFF234F3D);
  
  /// Dark header gradient start
  static const Color darkHeaderStart = Color(0xFF0D5A3C);
  
  /// Dark header gradient end
  static const Color darkHeaderEnd = Color(0xFF084228);

  // ============================================
  // Text Colors
  // ============================================
  
  /// Primary text - near black
  static const Color textPrimary = Color(0xFF1A1D1C);
  
  /// Secondary text - muted
  static const Color textSecondary = Color(0xFF5A6660);
  
  /// Tertiary text - subtle
  static const Color textTertiary = Color(0xFF8A9690);
  
  /// Text on primary surfaces
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  /// Text on gold surfaces
  static const Color textOnGold = Color(0xFF1A1D1C);
  
  /// Dark theme text
  static const Color darkTextPrimary = Color(0xFFF5F7F6);
  static const Color darkTextSecondary = Color(0xFFB0BAB5);
  static const Color darkTextTertiary = Color(0xFF7A8A84);

  // ============================================
  // Semantic Colors
  // ============================================
  
  /// Error - muted red
  static const Color error = Color(0xFFB34040);
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorSurface = Color(0xFFFDECEC);
  
  /// Success - natural green
  static const Color success = Color(0xFF2E7D52);
  static const Color successLight = Color(0xFF4CAF7A);
  static const Color successSurface = Color(0xFFE8F5EE);
  
  /// Warning - warm amber
  static const Color warning = Color(0xFFD4940C);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningSurface = Color(0xFFFFF8E6);
  
  /// Info - calm blue
  static const Color info = Color(0xFF3A7CA5);
  static const Color infoLight = Color(0xFF64B5F6);
  static const Color infoSurface = Color(0xFFE8F4FD);

  // ============================================
  // UI Element Colors
  // ============================================
  
  /// Divider - subtle separation
  static const Color divider = Color(0xFFE8EBE9);
  static const Color darkDivider = Color(0xFF2D4A3D);
  
  /// Border - component edges
  static const Color border = Color(0xFFD5DCD8);
  static const Color darkBorder = Color(0xFF3A5548);
  
  /// Disabled state
  static const Color disabled = Color(0xFFB5BDB9);
  
  /// Shimmer colors
  static const Color shimmerBase = Color(0xFFE8EBE9);
  static const Color shimmerHighlight = Color(0xFFF5F7F6);
  static const Color darkShimmerBase = Color(0xFF1A3D2E);
  static const Color darkShimmerHighlight = Color(0xFF234F3D);

  // ============================================
  // Special Purpose Colors
  // ============================================
  
  /// Quran text background
  static const Color quranBackground = Color(0xFFFFFEFC);
  static const Color quranBackgroundDark = Color(0xFF162E24);
  
  /// Hadith highlight
  static const Color hadithHighlight = Color(0xFFFFF9E8);
  static const Color hadithHighlightDark = Color(0xFF2A2A1F);
  
  /// AI bubble colors
  static const Color aiBubble = Color(0xFFF0F5F2);
  static const Color aiBubbleDark = Color(0xFF1A3D2E);
  
  /// User bubble
  static const Color userBubble = Color(0xFF0D5A3C);
  
  /// Prayer time colors
  static const Color prayerFajr = Color(0xFF5C6BC0);
  static const Color prayerSunrise = Color(0xFFFFB74D);
  static const Color prayerDhuhr = Color(0xFFFFD54F);
  static const Color prayerAsr = Color(0xFFFF8A65);
  static const Color prayerMaghrib = Color(0xFFE57373);
  static const Color prayerIsha = Color(0xFF7986CB);

  // ============================================
  // Premium Gradients
  // ============================================
  
  /// Primary header gradient - signature look
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0D5A3C),
      Color(0xFF084228),
    ],
  );
  
  /// Primary header gradient with more depth
  static const LinearGradient headerGradientDeep = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0D5A3C),
      Color(0xFF063321),
    ],
  );
  
  /// Card subtle gradient
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1A7A54),
      Color(0xFF0D5A3C),
    ],
  );
  
  /// Gold premium gradient
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE4C767),
      Color(0xFFD4AF37),
      Color(0xFFB8972E),
    ],
  );
  
  /// Subtle shimmer gradient for premium feel
  static const LinearGradient shimmerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x10FFFFFF),
      Color(0x20FFFFFF),
      Color(0x10FFFFFF),
    ],
  );
  
  /// Dark background gradient
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0A1F17),
      Color(0xFF0F2A20),
    ],
  );
  
  /// Light background gradient
  static const LinearGradient lightBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFAFAF8),
      Color(0xFFF5F5F2),
    ],
  );
  
  /// Glassmorphism overlay
  static const LinearGradient glassOverlay = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x15FFFFFF),
      Color(0x08FFFFFF),
    ],
  );
}
