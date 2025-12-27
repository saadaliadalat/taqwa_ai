import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message_model.dart';
import '../models/hadith_model.dart';
import '../models/ayah_model.dart';
import '../models/surah_model.dart';

/// API Service for backend communication
class ApiService {
  // Base URL for the backend API
  static const String _baseUrl = 'https://your-firebase-functions-url.cloudfunctions.net';
  
  // Timeout duration
  static const Duration _timeout = Duration(seconds: 30);
  
  String? _authToken;

  /// Set auth token for authenticated requests
  void setAuthToken(String? token) {
    _authToken = token;
  }

  /// Get default headers
  Map<String, String> get _headers {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // ============================================
  // AI Chat Endpoints
  // ============================================

  /// Send a question to the AI
  Future<MessageModel> askAi({
    required String question,
    required String conversationId,
    String? context,
    String? madhhab,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/ask'),
            headers: _headers,
            body: jsonEncode({
              'question': question,
              'conversationId': conversationId,
              if (context != null) 'context': context,
              if (madhhab != null) 'madhhab': madhhab,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return MessageModel.fromApi(data, conversationId);
      } else {
        throw ApiException(
          'Failed to get AI response',
          statusCode: response.statusCode,
          body: response.body,
        );
      }
    } on TimeoutException {
      throw ApiException('Request timed out. Please try again.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  // ============================================
  // Quran Endpoints
  // ============================================

  /// Get all surahs
  Future<List<SurahModel>> getSurahs() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/quran/surahs'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final surahs = (data['surahs'] as List<dynamic>)
            .map((s) => SurahModel.fromApi(s as Map<String, dynamic>))
            .toList();
        return surahs;
      } else {
        // Return local list if API fails
        return SurahList.surahs;
      }
    } catch (e) {
      // Return local list as fallback
      return SurahList.surahs;
    }
  }

  /// Get ayahs for a surah
  Future<List<AyahModel>> getSurahAyahs({
    required int surahNumber,
    String translationEdition = 'en.sahih',
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/quran/surah/$surahNumber?translation=$translationEdition'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final ayahs = (data['ayahs'] as List<dynamic>)
            .map((a) => AyahModel.fromApi(a as Map<String, dynamic>))
            .toList();
        return ayahs;
      } else {
        throw ApiException(
          'Failed to fetch surah',
          statusCode: response.statusCode,
        );
      }
    } on TimeoutException {
      throw ApiException('Request timed out');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch surah: ${e.toString()}');
    }
  }

  /// Get a specific ayah
  Future<AyahModel> getAyah({
    required int surahNumber,
    required int ayahNumber,
    String translationEdition = 'en.sahih',
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/quran/ayah/$surahNumber:$ayahNumber?translation=$translationEdition'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AyahModel.fromApi(data);
      } else {
        throw ApiException(
          'Failed to fetch ayah',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch ayah: ${e.toString()}');
    }
  }

  /// Get random ayah (for daily ayah)
  Future<AyahModel> getRandomAyah({
    String translationEdition = 'en.sahih',
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/quran/random?translation=$translationEdition'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return AyahModel.fromApi(data);
      } else {
        throw ApiException(
          'Failed to fetch random ayah',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch random ayah: ${e.toString()}');
    }
  }

  /// Search Quran
  Future<List<AyahModel>> searchQuran({
    required String query,
    String translationEdition = 'en.sahih',
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/quran/search?q=${Uri.encodeComponent(query)}&translation=$translationEdition'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = (data['results'] as List<dynamic>)
            .map((a) => AyahModel.fromApi(a as Map<String, dynamic>))
            .toList();
        return results;
      } else {
        throw ApiException(
          'Search failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Search failed: ${e.toString()}');
    }
  }

  // ============================================
  // Hadith Endpoints
  // ============================================

  /// Get hadith by collection and number
  Future<HadithModel> getHadith({
    required String collection,
    required String hadithNumber,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl/hadith/$collection/$hadithNumber'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return HadithModel.fromApi(data);
      } else {
        throw ApiException(
          'Failed to fetch hadith',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch hadith: ${e.toString()}');
    }
  }

  /// Search hadith
  Future<List<HadithModel>> searchHadith({
    required String query,
    String? collection,
  }) async {
    try {
      var url = '$_baseUrl/hadith/search?q=${Uri.encodeComponent(query)}';
      if (collection != null) {
        url += '&collection=$collection';
      }

      final response = await http
          .get(
            Uri.parse(url),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = (data['results'] as List<dynamic>)
            .map((h) => HadithModel.fromApi(h as Map<String, dynamic>))
            .toList();
        return results;
      } else {
        throw ApiException(
          'Search failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Search failed: ${e.toString()}');
    }
  }

  /// Get random hadith
  Future<HadithModel> getRandomHadith({String? collection}) async {
    try {
      var url = '$_baseUrl/hadith/random';
      if (collection != null) {
        url += '?collection=$collection';
      }

      final response = await http
          .get(
            Uri.parse(url),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return HadithModel.fromApi(data);
      } else {
        throw ApiException(
          'Failed to fetch random hadith',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to fetch random hadith: ${e.toString()}');
    }
  }

  // ============================================
  // Favorites Endpoints
  // ============================================

  /// Save a favorite
  Future<void> saveFavorite({
    required String type,
    required String content,
    String? arabicText,
    String? reference,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_baseUrl/favorites'),
            headers: _headers,
            body: jsonEncode({
              'type': type,
              'content': content,
              if (arabicText != null) 'arabicText': arabicText,
              if (reference != null) 'reference': reference,
              if (metadata != null) ...metadata,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ApiException(
          'Failed to save favorite',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to save favorite: ${e.toString()}');
    }
  }

  /// Delete a favorite
  Future<void> deleteFavorite(String favoriteId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$_baseUrl/favorites/$favoriteId'),
            headers: _headers,
          )
          .timeout(_timeout);

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ApiException(
          'Failed to delete favorite',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed to delete favorite: ${e.toString()}');
    }
  }
}

/// API Exception class
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final String? body;

  ApiException(this.message, {this.statusCode, this.body});

  @override
  String toString() => message;
}
