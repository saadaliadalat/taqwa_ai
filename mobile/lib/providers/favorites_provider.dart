import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/favorite_model.dart';
import '../models/ayah_model.dart';
import '../models/hadith_model.dart';
import '../models/message_model.dart';
import '../services/api_service.dart';
import '../services/hive_service.dart';
import 'shared_providers.dart';
import 'conversation_provider.dart';

/// Favorites provider
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, FavoritesState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final hiveService = ref.watch(hiveServiceProvider);
  return FavoritesNotifier(apiService, hiveService);
});

/// Favorites state
class FavoritesState {
  final List<FavoriteModel> favorites;
  final bool isLoading;
  final String? error;
  final FavoriteFilter filter;

  const FavoritesState({
    this.favorites = const [],
    this.isLoading = false,
    this.error,
    this.filter = FavoriteFilter.all,
  });

  FavoritesState copyWith({
    List<FavoriteModel>? favorites,
    bool? isLoading,
    String? error,
    FavoriteFilter? filter,
  }) {
    return FavoritesState(
      favorites: favorites ?? this.favorites,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filter: filter ?? this.filter,
    );
  }

  /// Get filtered favorites
  List<FavoriteModel> get filteredFavorites {
    switch (filter) {
      case FavoriteFilter.all:
        return favorites;
      case FavoriteFilter.ayah:
        return favorites.where((f) => f.isAyah).toList();
      case FavoriteFilter.hadith:
        return favorites.where((f) => f.isHadith).toList();
      case FavoriteFilter.aiResponse:
        return favorites.where((f) => f.isAiResponse).toList();
    }
  }

  /// Get count by type
  int get ayahCount => favorites.where((f) => f.isAyah).length;
  int get hadithCount => favorites.where((f) => f.isHadith).length;
  int get aiResponseCount => favorites.where((f) => f.isAiResponse).length;

  /// Check if item is favorited
  bool isFavorited({
    String? ayahReference,
    String? hadithReference,
    String? messageId,
  }) {
    if (ayahReference != null) {
      return favorites.any((f) => f.isAyah && f.reference == ayahReference);
    }
    if (hadithReference != null) {
      return favorites.any((f) => f.isHadith && f.reference == hadithReference);
    }
    if (messageId != null) {
      return favorites.any((f) => f.isAiResponse && f.messageId == messageId);
    }
    return false;
  }
}

/// Favorite filter enum
enum FavoriteFilter {
  all,
  ayah,
  hadith,
  aiResponse,
}

/// Favorites notifier
class FavoritesNotifier extends StateNotifier<FavoritesState> {
  final ApiService _apiService;
  final HiveService _hiveService;
  final _uuid = const Uuid();

  FavoritesNotifier(this._apiService, this._hiveService) 
      : super(const FavoritesState());

  /// Load favorites from local storage
  Future<void> loadFavorites(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final localFavorites = _hiveService.getAllFavorites();
      final favorites = localFavorites
          .where((f) => f['userId'] == userId)
          .map((f) => FavoriteModel.fromFirestore(f, f['id'] as String))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      state = state.copyWith(favorites: favorites, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Set filter
  void setFilter(FavoriteFilter filter) {
    state = state.copyWith(filter: filter);
  }

  /// Save ayah to favorites
  Future<void> saveAyah({
    required String userId,
    required AyahModel ayah,
    required String surahName,
  }) async {
    final id = _uuid.v4();
    final favorite = FavoriteModel.fromAyah(
      id: id,
      userId: userId,
      surahNumber: ayah.surahNumber,
      ayahNumber: ayah.numberInSurah,
      surahName: surahName,
      arabicText: ayah.text,
      translation: ayah.translation ?? '',
    );
    
    // Save locally
    await _hiveService.saveFavorite(id, {
      ...favorite.toFirestore(),
      'id': id,
      'needsSync': true,
    });
    
    // Update state
    state = state.copyWith(
      favorites: [favorite, ...state.favorites],
    );
    
    // Sync to backend
    try {
      await _apiService.saveFavorite(
        type: 'ayah',
        content: ayah.translation ?? '',
        arabicText: ayah.text,
        reference: 'Quran ${ayah.surahNumber}:${ayah.numberInSurah}',
        metadata: {
          'surahNumber': ayah.surahNumber,
          'ayahNumber': ayah.numberInSurah,
          'surahName': surahName,
        },
      );
      await _hiveService.markFavoriteSynced(id);
    } catch (e) {
      // Will sync later when online
    }
  }

  /// Save hadith to favorites
  Future<void> saveHadith({
    required String userId,
    required HadithModel hadith,
  }) async {
    final id = _uuid.v4();
    final favorite = FavoriteModel.fromHadith(
      id: id,
      userId: userId,
      collection: hadith.collection,
      hadithNumber: hadith.hadithNumber,
      arabicText: hadith.arabicText,
      translation: hadith.translation,
      narrator: hadith.narrator,
    );
    
    // Save locally
    await _hiveService.saveFavorite(id, {
      ...favorite.toFirestore(),
      'id': id,
      'needsSync': true,
    });
    
    // Update state
    state = state.copyWith(
      favorites: [favorite, ...state.favorites],
    );
    
    // Sync to backend
    try {
      await _apiService.saveFavorite(
        type: 'hadith',
        content: hadith.translation,
        arabicText: hadith.arabicText,
        reference: '${hadith.collection} ${hadith.hadithNumber}',
        metadata: {
          'collection': hadith.collection,
          'hadithNumber': hadith.hadithNumber,
          'narrator': hadith.narrator,
        },
      );
      await _hiveService.markFavoriteSynced(id);
    } catch (e) {
      // Will sync later when online
    }
  }

  /// Save AI response to favorites
  Future<void> saveAiResponse({
    required String userId,
    required MessageModel message,
  }) async {
    final id = _uuid.v4();
    final favorite = FavoriteModel.fromAiResponse(
      id: id,
      userId: userId,
      content: message.content,
      conversationId: message.conversationId,
      messageId: message.id,
    );
    
    // Save locally
    await _hiveService.saveFavorite(id, {
      ...favorite.toFirestore(),
      'id': id,
      'needsSync': true,
    });
    
    // Update state
    state = state.copyWith(
      favorites: [favorite, ...state.favorites],
    );
    
    // Sync to backend
    try {
      await _apiService.saveFavorite(
        type: 'aiResponse',
        content: message.content,
        metadata: {
          'conversationId': message.conversationId,
          'messageId': message.id,
        },
      );
      await _hiveService.markFavoriteSynced(id);
    } catch (e) {
      // Will sync later when online
    }
  }

  /// Remove from favorites
  Future<void> removeFavorite(String favoriteId) async {
    // Remove from local storage
    await _hiveService.deleteFavorite(favoriteId);
    
    // Update state
    state = state.copyWith(
      favorites: state.favorites.where((f) => f.id != favoriteId).toList(),
    );
    
    // Sync delete to backend
    try {
      await _apiService.deleteFavorite(favoriteId);
    } catch (e) {
      // Ignore errors for now
    }
  }

  /// Check if item is favorited
  bool isFavorited({
    String? ayahReference,
    String? hadithReference,
    String? messageId,
  }) {
    if (ayahReference != null) {
      return state.favorites.any(
        (f) => f.isAyah && f.reference == ayahReference,
      );
    }
    if (hadithReference != null) {
      return state.favorites.any(
        (f) => f.isHadith && f.reference == hadithReference,
      );
    }
    if (messageId != null) {
      return state.favorites.any(
        (f) => f.isAiResponse && f.messageId == messageId,
      );
    }
    return false;
  }

  /// Sync unsynced favorites
  Future<void> syncFavorites() async {
    final unsynced = _hiveService.getUnsyncedFavorites();
    
    for (final favoriteData in unsynced) {
      try {
        await _apiService.saveFavorite(
          type: favoriteData['type'] as String,
          content: favoriteData['content'] as String,
          arabicText: favoriteData['arabicText'] as String?,
          reference: favoriteData['reference'] as String?,
        );
        await _hiveService.markFavoriteSynced(favoriteData['id'] as String);
      } catch (e) {
        // Continue with next
      }
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}
