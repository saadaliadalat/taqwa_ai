import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Taqwa AI Design System - Typography
/// 
/// Uses Inter for English/Latin text and Amiri/Scheherazade for Arabic.
/// Large, readable Quran text with generous line spacing.
class AppTypography {
  AppTypography._();

  // ============================================
  // Font Families
  // ============================================
  
  /// Primary font for English/Latin text
  static String get primaryFontFamily => 'Inter';
  
  /// Arabic font for Quranic text
  static String get arabicFontFamily => 'Amiri';
  
  /// Alternative Arabic font
  static String get arabicAltFontFamily => 'Scheherazade';

  // ============================================
  // Text Styles - Headings
  // ============================================
  
  /// Display Large - 57sp
  static TextStyle displayLarge({Color? color}) => GoogleFonts.inter(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
    color: color,
  );
  
  /// Display Medium - 45sp
  static TextStyle displayMedium({Color? color}) => GoogleFonts.inter(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
    color: color,
  );
  
  /// Display Small - 36sp
  static TextStyle displaySmall({Color? color}) => GoogleFonts.inter(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
    color: color,
  );
  
  /// Headline Large - 32sp
  static TextStyle headlineLarge({Color? color}) => GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.25,
    color: color,
  );
  
  /// Headline Medium - 28sp
  static TextStyle headlineMedium({Color? color}) => GoogleFonts.inter(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
    color: color,
  );
  
  /// Headline Small - 24sp
  static TextStyle headlineSmall({Color? color}) => GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
    color: color,
  );
  
  /// Title Large - 22sp
  static TextStyle titleLarge({Color? color}) => GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.27,
    color: color,
  );
  
  /// Title Medium - 16sp
  static TextStyle titleMedium({Color? color}) => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.5,
    color: color,
  );
  
  /// Title Small - 14sp
  static TextStyle titleSmall({Color? color}) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
    color: color,
  );

  // ============================================
  // Text Styles - Body
  // ============================================
  
  /// Body Large - 16sp
  static TextStyle bodyLarge({Color? color}) => GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
    color: color,
  );
  
  /// Body Medium - 14sp
  static TextStyle bodyMedium({Color? color}) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
    color: color,
  );
  
  /// Body Small - 12sp
  static TextStyle bodySmall({Color? color}) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
    color: color,
  );

  // ============================================
  // Text Styles - Labels
  // ============================================
  
  /// Label Large - 14sp
  static TextStyle labelLarge({Color? color}) => GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
    color: color,
  );
  
  /// Label Medium - 12sp
  static TextStyle labelMedium({Color? color}) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
    color: color,
  );
  
  /// Label Small - 11sp
  static TextStyle labelSmall({Color? color}) => GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
    color: color,
  );

  // ============================================
  // Arabic Text Styles - Quran
  // ============================================
  
  /// Quran Large - 32sp with generous line height
  static TextStyle quranLarge({Color? color}) => TextStyle(
    fontFamily: 'Amiri',
    fontSize: 32,
    fontWeight: FontWeight.w400,
    height: 2.0,
    color: color,
  );
  
  /// Quran Medium - 26sp
  static TextStyle quranMedium({Color? color}) => TextStyle(
    fontFamily: 'Amiri',
    fontSize: 26,
    fontWeight: FontWeight.w400,
    height: 1.9,
    color: color,
  );
  
  /// Quran Small - 22sp
  static TextStyle quranSmall({Color? color}) => TextStyle(
    fontFamily: 'Amiri',
    fontSize: 22,
    fontWeight: FontWeight.w400,
    height: 1.8,
    color: color,
  );
  
  /// Quran Ayah Number
  static TextStyle quranAyahNumber({Color? color}) => TextStyle(
    fontFamily: 'Amiri',
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: color,
  );

  // ============================================
  // Arabic Text Styles - General
  // ============================================
  
  /// Arabic Body - 18sp
  static TextStyle arabicBody({Color? color}) => TextStyle(
    fontFamily: 'Scheherazade',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    height: 1.7,
    color: color,
  );
  
  /// Arabic Hadith - 20sp
  static TextStyle arabicHadith({Color? color}) => TextStyle(
    fontFamily: 'Scheherazade',
    fontSize: 20,
    fontWeight: FontWeight.w400,
    height: 1.8,
    color: color,
  );
  
  /// Arabic Title - 24sp
  static TextStyle arabicTitle({Color? color}) => TextStyle(
    fontFamily: 'Amiri',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.5,
    color: color,
  );

  // ============================================
  // Special Styles
  // ============================================
  
  /// Surah Name Style
  static TextStyle surahName({Color? color}) => TextStyle(
    fontFamily: 'Amiri',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.4,
    color: color,
  );
  
  /// Bismillah Style
  static TextStyle bismillah({Color? color}) => TextStyle(
    fontFamily: 'Amiri',
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 1.8,
    color: color,
  );
  
  /// Reference Style (for citations)
  static TextStyle reference({Color? color}) => GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic,
    letterSpacing: 0.4,
    height: 1.4,
    color: color,
  );
}
