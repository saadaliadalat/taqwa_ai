import 'package:flutter/material.dart';

/// Taqwa AI Design System - Colors
/// 
/// A calm, respectful color palette designed for Islamic aesthetics.
/// Supports both light and dark themes with RTL compatibility.
class AppColors {
  AppColors._();

  // ============================================
  // Light Theme Colors
  // ============================================
  
  /// Light theme background - warm off-white
  static const Color lightBackground = Color(0xFFFAFAF7);
  
  /// Light theme surface - slightly darker for cards
  static const Color lightSurface = Color(0xFFF5F5F2);
  
  /// Light theme card background
  static const Color lightCard = Color(0xFFFFFFFF);

  // ============================================
  // Dark Theme Colors
  // ============================================
  
  /// Dark theme background - deep forest green-black
  static const Color darkBackground = Color(0xFF0F1F1A);
  
  /// Dark theme surface - slightly lighter for cards
  static const Color darkSurface = Color(0xFF1A2F28);
  
  /// Dark theme card background
  static const Color darkCard = Color(0xFF243D34);

  // ============================================
  // Primary & Accent Colors
  // ============================================
  
  /// Primary accent - Islamic green
  static const Color primary = Color(0xFF1F7A5A);
  
  /// Primary light variant
  static const Color primaryLight = Color(0xFF2E9B75);
  
  /// Primary dark variant
  static const Color primaryDark = Color(0xFF165A42);
  
  /// Secondary accent - warm gold
  static const Color secondary = Color(0xFFC2A14D);
  
  /// Secondary light variant
  static const Color secondaryLight = Color(0xFFD4B76A);
  
  /// Secondary dark variant
  static const Color secondaryDark = Color(0xFFA88A3D);

  // ============================================
  // Text Colors
  // ============================================
  
  /// Primary text color - near black
  static const Color textPrimary = Color(0xFF1A1A1A);
  
  /// Secondary text color - muted gray
  static const Color textSecondary = Color(0xFF6B6B6B);
  
  /// Tertiary text color - light gray
  static const Color textTertiary = Color(0xFF9A9A9A);
  
  /// Text on primary color
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  /// Text on secondary color
  static const Color textOnSecondary = Color(0xFF1A1A1A);
  
  /// Light theme text colors
  static const Color lightTextPrimary = Color(0xFF1A1A1A);
  static const Color lightTextSecondary = Color(0xFF6B6B6B);
  
  /// Dark theme text colors
  static const Color darkTextPrimary = Color(0xFFF5F5F2);
  static const Color darkTextSecondary = Color(0xFFB0B0A8);

  // ============================================
  // Semantic Colors
  // ============================================
  
  /// Error color - muted red
  static const Color error = Color(0xFF8B2E2E);
  
  /// Error light variant
  static const Color errorLight = Color(0xFFB54545);
  
  /// Success color - muted green
  static const Color success = Color(0xFF2E6B4F);
  
  /// Warning color - muted amber
  static const Color warning = Color(0xFFB8860B);
  
  /// Info color - muted blue
  static const Color info = Color(0xFF4A6B8A);

  // ============================================
  // UI Element Colors
  // ============================================
  
  /// Divider color
  static const Color divider = Color(0xFFE5E5E0);
  
  /// Dark theme divider
  static const Color darkDivider = Color(0xFF3A4F47);
  
  /// Border color
  static const Color border = Color(0xFFD5D5D0);
  
  /// Dark theme border
  static const Color darkBorder = Color(0xFF4A5F57);
  
  /// Disabled state color
  static const Color disabled = Color(0xFFBDBDB8);
  
  /// Shimmer base color
  static const Color shimmerBase = Color(0xFFE8E8E4);
  
  /// Shimmer highlight color
  static const Color shimmerHighlight = Color(0xFFF5F5F2);

  // ============================================
  // Special Purpose Colors
  // ============================================
  
  /// Quran text background - slightly warm
  static const Color quranBackground = Color(0xFFFFFEFC);
  
  /// Quran text background dark
  static const Color quranBackgroundDark = Color(0xFF1A2A24);
  
  /// Hadith highlight color
  static const Color hadithHighlight = Color(0xFFFFF8E7);
  
  /// Hadith highlight dark
  static const Color hadithHighlightDark = Color(0xFF2A2A1F);
  
  /// AI response bubble
  static const Color aiBubble = Color(0xFFF0F4F2);
  
  /// AI response bubble dark
  static const Color aiBubbleDark = Color(0xFF243D34);
  
  /// User message bubble
  static const Color userBubble = Color(0xFF1F7A5A);

  // ============================================
  // Gradient Definitions
  // ============================================
  
  /// Primary gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );
  
  /// Gold gradient for special elements
  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryLight],
  );
  
  /// Subtle background gradient for light theme
  static const LinearGradient lightBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [lightBackground, lightSurface],
  );
  
  /// Subtle background gradient for dark theme
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [darkBackground, darkSurface],
  );
}
