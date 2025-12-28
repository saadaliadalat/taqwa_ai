import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/hive_service.dart';
import '../services/connectivity_service.dart';
import 'shared_providers.dart';

/// Settings provider
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return SettingsNotifier(hiveService);
});

/// Theme mode provider
final themeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(settingsProvider);
  return settings.darkModeEnabled ? ThemeMode.dark : ThemeMode.light;
});

/// Settings state
class SettingsState {
  final bool darkModeEnabled;
  final bool notificationsEnabled;
  final bool dailyAyahEnabled;
  final String dailyAyahTime;
  final String language;
  final String madhhab;
  final int quranFontSize;
  final bool showTranslation;
  final String translationLanguage;
  final bool onboardingComplete;

  const SettingsState({
    this.darkModeEnabled = false,
    this.notificationsEnabled = true,
    this.dailyAyahEnabled = true,
    this.dailyAyahTime = '08:00',
    this.language = 'english',
    this.madhhab = 'none',
    this.quranFontSize = 26,
    this.showTranslation = true,
    this.translationLanguage = 'en',
    this.onboardingComplete = false,
  });

  SettingsState copyWith({
    bool? darkModeEnabled,
    bool? notificationsEnabled,
    bool? dailyAyahEnabled,
    String? dailyAyahTime,
    String? language,
    String? madhhab,
    int? quranFontSize,
    bool? showTranslation,
    String? translationLanguage,
    bool? onboardingComplete,
  }) {
    return SettingsState(
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyAyahEnabled: dailyAyahEnabled ?? this.dailyAyahEnabled,
      dailyAyahTime: dailyAyahTime ?? this.dailyAyahTime,
      language: language ?? this.language,
      madhhab: madhhab ?? this.madhhab,
      quranFontSize: quranFontSize ?? this.quranFontSize,
      showTranslation: showTranslation ?? this.showTranslation,
      translationLanguage: translationLanguage ?? this.translationLanguage,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }

  /// Get translation edition code
  String get translationEditionCode {
    switch (translationLanguage) {
      case 'en':
        return 'en.sahih';
      case 'ar':
        return 'ar.muyassar';
      case 'ur':
        return 'ur.jalandhry';
      case 'tr':
        return 'tr.diyanet';
      case 'id':
        return 'id.indonesian';
      case 'ms':
        return 'ms.basmeih';
      default:
        return 'en.sahih';
    }
  }
}

/// Settings notifier
class SettingsNotifier extends StateNotifier<SettingsState> {
  final HiveService _hiveService;

  SettingsNotifier(this._hiveService) : super(const SettingsState()) {
    _loadSettings();
  }

  /// Load settings from local storage
  void _loadSettings() {
    state = SettingsState(
      darkModeEnabled: _hiveService.isDarkMode,
      notificationsEnabled: _hiveService.notificationsEnabled,
      dailyAyahEnabled: _hiveService.getSetting<bool>('daily_ayah_enabled') ?? true,
      dailyAyahTime: _hiveService.getSetting<String>('daily_ayah_time') ?? '08:00',
      language: _hiveService.getSetting<String>('language') ?? 'english',
      madhhab: _hiveService.getSetting<String>('madhhab') ?? 'none',
      quranFontSize: _hiveService.getSetting<int>('quran_font_size') ?? 26,
      showTranslation: _hiveService.getSetting<bool>('show_translation') ?? true,
      translationLanguage: _hiveService.getSetting<String>('translation_language') ?? 'en',
      onboardingComplete: _hiveService.isOnboardingComplete,
    );
  }

  /// Toggle dark mode
  Future<void> toggleDarkMode() async {
    final newValue = !state.darkModeEnabled;
    await _hiveService.setDarkMode(newValue);
    state = state.copyWith(darkModeEnabled: newValue);
  }

  /// Set dark mode
  Future<void> setDarkMode(bool enabled) async {
    await _hiveService.setDarkMode(enabled);
    state = state.copyWith(darkModeEnabled: enabled);
  }

  /// Toggle notifications
  Future<void> toggleNotifications() async {
    final newValue = !state.notificationsEnabled;
    await _hiveService.setNotificationsEnabled(newValue);
    state = state.copyWith(notificationsEnabled: newValue);
  }

  /// Set notifications enabled
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _hiveService.setNotificationsEnabled(enabled);
    state = state.copyWith(notificationsEnabled: enabled);
  }

  /// Toggle daily ayah
  Future<void> toggleDailyAyah() async {
    final newValue = !state.dailyAyahEnabled;
    await _hiveService.saveSetting('daily_ayah_enabled', newValue);
    state = state.copyWith(dailyAyahEnabled: newValue);
  }

  /// Set daily ayah time
  Future<void> setDailyAyahTime(String time) async {
    await _hiveService.saveSetting('daily_ayah_time', time);
    state = state.copyWith(dailyAyahTime: time);
  }

  /// Set language
  Future<void> setLanguage(String language) async {
    await _hiveService.saveSetting('language', language);
    state = state.copyWith(language: language);
  }

  /// Set madhhab
  Future<void> setMadhhab(String madhhab) async {
    await _hiveService.saveSetting('madhhab', madhhab);
    state = state.copyWith(madhhab: madhhab);
  }

  /// Set Quran font size
  Future<void> setQuranFontSize(int size) async {
    await _hiveService.saveSetting('quran_font_size', size);
    state = state.copyWith(quranFontSize: size);
  }

  /// Toggle translation visibility
  Future<void> toggleTranslation() async {
    final newValue = !state.showTranslation;
    await _hiveService.saveSetting('show_translation', newValue);
    state = state.copyWith(showTranslation: newValue);
  }

  /// Set translation language
  Future<void> setTranslationLanguage(String language) async {
    await _hiveService.saveSetting('translation_language', language);
    state = state.copyWith(translationLanguage: language);
  }

  /// Complete onboarding
  Future<void> completeOnboarding() async {
    await _hiveService.completeOnboarding();
    state = state.copyWith(onboardingComplete: true);
  }

  /// Save onboarding preferences
  Future<void> saveOnboardingPreferences({
    required String language,
    required String madhhab,
    required List<String> purposes,
    required bool notificationsEnabled,
  }) async {
    await setLanguage(language);
    await setMadhhab(madhhab);
    await setNotificationsEnabled(notificationsEnabled);
    await _hiveService.saveSetting('purposes', purposes);
  }
}

/// Connectivity provider
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

/// Connectivity state provider
final connectivityProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectivityStream;
});

/// Is online provider
final isOnlineProvider = Provider<bool>((ref) {
  final connectivity = ref.watch(connectivityProvider);
  return connectivity.when(
    data: (isConnected) => isConnected,
    loading: () => true, // Assume online while loading
    error: (_, __) => false,
  );
});
