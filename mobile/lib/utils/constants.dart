/// App constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Taqwa AI';
  static const String appTagline = 'Your Islamic AI Assistant';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String apiBaseUrl = 'https://your-firebase-functions-url.cloudfunctions.net';
  static const Duration apiTimeout = Duration(seconds: 30);

  // Hive Box Names
  static const String userBox = 'user_box';
  static const String conversationsBox = 'conversations_box';
  static const String messagesBox = 'messages_box';
  static const String favoritesBox = 'favorites_box';
  static const String quranCacheBox = 'quran_cache_box';
  static const String settingsBox = 'settings_box';
  static const String dailyAyahBox = 'daily_ayah_box';

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Spacing
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // Border Radius
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;

  // Chat
  static const int maxMessageLength = 2000;
  static const int maxConversationTitleLength = 100;

  // Quran
  static const int totalSurahs = 114;
  static const int totalAyahs = 6236;
  static const int totalJuz = 30;

  // Madhhab Options
  static const List<MadhhabOption> madhhabOptions = [
    MadhhabOption(id: 'hanafi', name: 'Hanafi', arabicName: 'حنفي'),
    MadhhabOption(id: 'maliki', name: 'Maliki', arabicName: 'مالكي'),
    MadhhabOption(id: 'shafii', name: 'Shafi\'i', arabicName: 'شافعي'),
    MadhhabOption(id: 'hanbali', name: 'Hanbali', arabicName: 'حنبلي'),
    MadhhabOption(id: 'none', name: 'No Preference', arabicName: 'بدون تفضيل'),
  ];

  // Language Options
  static const List<LanguageOption> languageOptions = [
    LanguageOption(code: 'en', name: 'English', nativeName: 'English'),
    LanguageOption(code: 'ar', name: 'Arabic', nativeName: 'العربية'),
    LanguageOption(code: 'ur', name: 'Urdu', nativeName: 'اردو'),
    LanguageOption(code: 'tr', name: 'Turkish', nativeName: 'Türkçe'),
    LanguageOption(code: 'id', name: 'Indonesian', nativeName: 'Bahasa Indonesia'),
    LanguageOption(code: 'ms', name: 'Malay', nativeName: 'Bahasa Melayu'),
  ];

  // Purpose Options
  static const List<PurposeOption> purposeOptions = [
    PurposeOption(id: 'learning', title: 'Learning Islam', icon: '📚'),
    PurposeOption(id: 'quran', title: 'Reading Quran', icon: '📖'),
    PurposeOption(id: 'questions', title: 'Islamic Questions', icon: '❓'),
    PurposeOption(id: 'hadith', title: 'Studying Hadith', icon: '📜'),
    PurposeOption(id: 'spirituality', title: 'Spiritual Growth', icon: '🤲'),
    PurposeOption(id: 'daily', title: 'Daily Reminders', icon: '🌙'),
  ];

  // Hadith Collections
  static const List<HadithCollectionOption> hadithCollections = [
    HadithCollectionOption(id: 'bukhari', name: 'Sahih Bukhari', arabicName: 'صحيح البخاري'),
    HadithCollectionOption(id: 'muslim', name: 'Sahih Muslim', arabicName: 'صحيح مسلم'),
    HadithCollectionOption(id: 'tirmidhi', name: 'Jami\' at-Tirmidhi', arabicName: 'جامع الترمذي'),
    HadithCollectionOption(id: 'abuDawud', name: 'Sunan Abu Dawud', arabicName: 'سنن أبي داود'),
    HadithCollectionOption(id: 'nasai', name: 'Sunan an-Nasa\'i', arabicName: 'سنن النسائي'),
    HadithCollectionOption(id: 'ibnMajah', name: 'Sunan Ibn Majah', arabicName: 'سنن ابن ماجه'),
  ];
}

/// Madhhab option model
class MadhhabOption {
  final String id;
  final String name;
  final String arabicName;

  const MadhhabOption({
    required this.id,
    required this.name,
    required this.arabicName,
  });
}

/// Language option model
class LanguageOption {
  final String code;
  final String name;
  final String nativeName;

  const LanguageOption({
    required this.code,
    required this.name,
    required this.nativeName,
  });
}

/// Purpose option model
class PurposeOption {
  final String id;
  final String title;
  final String icon;

  const PurposeOption({
    required this.id,
    required this.title,
    required this.icon,
  });
}

/// Hadith collection option model
class HadithCollectionOption {
  final String id;
  final String name;
  final String arabicName;

  const HadithCollectionOption({
    required this.id,
    required this.name,
    required this.arabicName,
  });
}
