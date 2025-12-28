import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/surah_model.dart';
import '../models/ayah_model.dart';
import '../services/api_service.dart';
import '../services/hive_service.dart';
import 'shared_providers.dart';
import 'conversation_provider.dart';

/// Quran provider
final quranProvider = StateNotifierProvider<QuranNotifier, QuranState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final hiveService = ref.watch(hiveServiceProvider);
  return QuranNotifier(apiService, hiveService);
});

/// Daily ayah provider
final dailyAyahProvider = FutureProvider<AyahModel?>((ref) async {
  final quranNotifier = ref.watch(quranProvider.notifier);
  return await quranNotifier.getDailyAyah();
});

/// Quran state
class QuranState {
  final List<SurahModel> surahs;
  final SurahModel? currentSurah;
  final List<AyahModel> currentAyahs;
  final int? currentAyahIndex;
  final bool isLoading;
  final String? error;
  final bool showTranslation;
  final bool showTafsir;
  final String translationEdition;

  const QuranState({
    this.surahs = SurahList.surahs,
    this.currentSurah,
    this.currentAyahs = const [],
    this.currentAyahIndex,
    this.isLoading = false,
    this.error,
    this.showTranslation = true,
    this.showTafsir = false,
    this.translationEdition = 'en.sahih',
  });

  QuranState copyWith({
    List<SurahModel>? surahs,
    SurahModel? currentSurah,
    List<AyahModel>? currentAyahs,
    int? currentAyahIndex,
    bool? isLoading,
    String? error,
    bool? showTranslation,
    bool? showTafsir,
    String? translationEdition,
  }) {
    return QuranState(
      surahs: surahs ?? this.surahs,
      currentSurah: currentSurah ?? this.currentSurah,
      currentAyahs: currentAyahs ?? this.currentAyahs,
      currentAyahIndex: currentAyahIndex ?? this.currentAyahIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      showTranslation: showTranslation ?? this.showTranslation,
      showTafsir: showTafsir ?? this.showTafsir,
      translationEdition: translationEdition ?? this.translationEdition,
    );
  }
}

/// Quran notifier
class QuranNotifier extends StateNotifier<QuranState> {
  final ApiService _apiService;
  final HiveService _hiveService;

  QuranNotifier(this._apiService, this._hiveService) : super(const QuranState()) {
    _loadSurahs();
  }

  /// Load surahs list
  Future<void> _loadSurahs() async {
    state = state.copyWith(isLoading: true);
    
    try {
      // Try to load from cache first
      final cachedSurahs = _hiveService.getSurahsList();
      if (cachedSurahs != null && cachedSurahs.isNotEmpty) {
        final surahs = cachedSurahs
            .map((s) => SurahModel.fromApi(s))
            .toList();
        state = state.copyWith(surahs: surahs, isLoading: false);
      } else {
        // Use static list
        state = state.copyWith(surahs: SurahList.surahs, isLoading: false);
      }
      
      // Fetch from API in background
      _fetchSurahsFromApi();
    } catch (e) {
      // Fallback to static list
      state = state.copyWith(
        surahs: SurahList.surahs,
        isLoading: false,
      );
    }
  }

  /// Fetch surahs from API
  Future<void> _fetchSurahsFromApi() async {
    try {
      final surahs = await _apiService.getSurahs();
      state = state.copyWith(surahs: surahs);
      
      // Cache the surahs
      await _hiveService.saveSurahsList(
        surahs.map((s) => s.toJson()).toList(),
      );
    } catch (e) {
      // Ignore - we have the static list
    }
  }

  /// Load a surah
  Future<void> loadSurah(int surahNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Get surah metadata
      final surah = state.surahs.firstWhere(
        (s) => s.number == surahNumber,
        orElse: () => SurahList.surahs[surahNumber - 1],
      );
      
      // Try to load ayahs from cache
      final cachedAyahs = _hiveService.getSurahAyahs(surahNumber);
      if (cachedAyahs != null && cachedAyahs.isNotEmpty) {
        final ayahs = cachedAyahs
            .map((a) => AyahModel.fromApi(a))
            .toList();
        state = state.copyWith(
          currentSurah: surah,
          currentAyahs: ayahs,
          currentAyahIndex: 0,
          isLoading: false,
        );
      }
      
      // Fetch from API
      final ayahs = await _apiService.getSurahAyahs(
        surahNumber: surahNumber,
        translationEdition: state.translationEdition,
      );
      
      state = state.copyWith(
        currentSurah: surah,
        currentAyahs: ayahs,
        currentAyahIndex: 0,
        isLoading: false,
      );
      
      // Cache the ayahs
      await _hiveService.saveSurahAyahs(
        surahNumber,
        ayahs.map((a) => a.toJson()).toList(),
      );
      
      // Save last read position
      await _hiveService.saveLastReadPosition(surahNumber, 1);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Go to specific ayah
  void goToAyah(int ayahNumber) {
    final index = state.currentAyahs.indexWhere(
      (a) => a.numberInSurah == ayahNumber,
    );
    if (index != -1) {
      state = state.copyWith(currentAyahIndex: index);
      
      // Update last read position
      if (state.currentSurah != null) {
        _hiveService.saveLastReadPosition(
          state.currentSurah!.number,
          ayahNumber,
        );
      }
    }
  }

  /// Next ayah
  void nextAyah() {
    if (state.currentAyahIndex != null && 
        state.currentAyahIndex! < state.currentAyahs.length - 1) {
      goToAyah(state.currentAyahs[state.currentAyahIndex! + 1].numberInSurah);
    }
  }

  /// Previous ayah
  void previousAyah() {
    if (state.currentAyahIndex != null && state.currentAyahIndex! > 0) {
      goToAyah(state.currentAyahs[state.currentAyahIndex! - 1].numberInSurah);
    }
  }

  /// Toggle translation visibility
  void toggleTranslation() {
    state = state.copyWith(showTranslation: !state.showTranslation);
  }

  /// Toggle tafsir visibility
  void toggleTafsir() {
    state = state.copyWith(showTafsir: !state.showTafsir);
  }

  /// Set translation edition
  void setTranslationEdition(String edition) {
    state = state.copyWith(translationEdition: edition);
    
    // Reload current surah with new translation
    if (state.currentSurah != null) {
      loadSurah(state.currentSurah!.number);
    }
  }

  /// Get daily ayah
  Future<AyahModel?> getDailyAyah() async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    // Check cache first
    final cached = _hiveService.getDailyAyah(today);
    if (cached != null) {
      return AyahModel.fromApi(cached);
    }
    
    try {
      final ayah = await _apiService.getRandomAyah(
        translationEdition: state.translationEdition,
      );
      
      // Cache the daily ayah
      await _hiveService.saveDailyAyah(ayah.toJson(), today);
      
      return ayah;
    } catch (e) {
      return null;
    }
  }

  /// Search Quran
  Future<List<AyahModel>> searchQuran(String query) async {
    if (query.trim().isEmpty) return [];
    
    try {
      return await _apiService.searchQuran(
        query: query,
        translationEdition: state.translationEdition,
      );
    } catch (e) {
      return [];
    }
  }

  /// Get last read position
  Map<String, dynamic>? getLastReadPosition() {
    return _hiveService.getLastReadPosition();
  }

  /// Continue reading from last position
  Future<void> continueReading() async {
    final position = _hiveService.getLastReadPosition();
    if (position != null) {
      await loadSurah(position['surahNumber'] as int);
      goToAyah(position['ayahNumber'] as int);
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
