import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/message_model.dart';
import '../models/hadith_model.dart';
import '../models/ayah_model.dart';
import '../models/surah_model.dart';

/// API Service - Works with free external APIs
class ApiService {
  // Gemini API
  static const String _geminiApiKey = 'AIzaSyDWw2Dy14i9vPiTt10RQjsWmgIMSfzTKeQ';
  static const String _geminiApiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  
  // Free Quran API
  static const String _quranApiUrl = 'https://api.alquran.cloud/v1';
  
  // Timeout duration
  static const Duration _timeout = Duration(seconds: 60);
  
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
  // AI Chat - REAL Gemini API
  // ============================================

  /// System prompt for Islamic AI assistant
  static const String _systemPrompt = '''You are Taqwa AI, an Islamic knowledge assistant. Your role is to:

1. Answer questions about Islam based on Quran and authentic Hadith
2. Provide references when possible (Surah:Ayah or Hadith collection)
3. Be respectful and follow Islamic ethics
4. Clarify when there are different scholarly opinions
5. Encourage seeking knowledge from qualified scholars for complex fiqh matters
6. Use Arabic terms with transliterations when appropriate
7. Be concise but comprehensive

Remember: You are a helpful assistant, not a mufti. Always recommend consulting local scholars for fatwa-level questions.''';

  /// Ask a question to Gemini AI
  Future<MessageModel> askAi({
    required String question,
    required String conversationId,
    String? context,
    String? madhhab,
  }) async {
    try {
      final prompt = _buildPrompt(question, context, madhhab);
      
      final response = await http.post(
        Uri.parse('$_geminiApiUrl?key=$_geminiApiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
          'safetySettings': [
            {
              'category': 'HARM_CATEGORY_HARASSMENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_HATE_SPEECH',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
            {
              'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
              'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
            },
          ],
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List<dynamic>?;
        
        if (candidates != null && candidates.isNotEmpty) {
          final candidate = candidates[0] as Map<String, dynamic>;
          final content = candidate['content'] as Map<String, dynamic>?;
          final parts = content?['parts'] as List<dynamic>?;
          
          if (parts != null && parts.isNotEmpty) {
            final text = parts[0]['text'] as String? ?? 'No response generated.';
            
            return MessageModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              conversationId: conversationId,
              role: 'assistant',
              content: text,
              createdAt: DateTime.now(),
            );
          }
        }
        
        // Fallback if parsing fails
        return MessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          conversationId: conversationId,
          role: 'assistant',
          content: 'I apologize, but I could not generate a response. Please try again.',
          createdAt: DateTime.now(),
        );
      } else {
        // API error - return error message
        return MessageModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          conversationId: conversationId,
          role: 'assistant',
          content: 'I apologize, there was an error connecting to the AI service. Please try again later.\n\n_Error: ${response.statusCode}_',
          createdAt: DateTime.now(),
        );
      }
    } on TimeoutException {
      return MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: conversationId,
        role: 'assistant',
        content: 'The request timed out. Please check your internet connection and try again.',
        createdAt: DateTime.now(),
      );
    } catch (e) {
      return MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: conversationId,
        role: 'assistant',
        content: 'An error occurred: ${e.toString()}. Please try again.',
        createdAt: DateTime.now(),
      );
    }
  }

  String _buildPrompt(String question, String? context, String? madhhab) {
    final buffer = StringBuffer();
    buffer.writeln(_systemPrompt);
    buffer.writeln();
    
    if (madhhab != null && madhhab.isNotEmpty) {
      buffer.writeln('The user follows the $madhhab school of thought (madhab). Consider this when applicable.');
    }
    
    if (context != null && context.isNotEmpty) {
      buffer.writeln('Context from previous conversation:');
      buffer.writeln(context);
      buffer.writeln();
    }
    
    buffer.writeln('User Question: $question');
    buffer.writeln();
    buffer.writeln('Please provide a helpful, accurate response based on authentic Islamic sources.');
    
    return buffer.toString();
  }

  // ============================================
  // Quran Endpoints (Using alquran.cloud API)
  // ============================================

  /// Get all surahs
  Future<List<SurahModel>> getSurahs() async {
    try {
      final response = await http
          .get(Uri.parse('$_quranApiUrl/surah'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK') {
          final surahs = (data['data'] as List<dynamic>)
              .map((s) => SurahModel.fromAlQuranCloud(s as Map<String, dynamic>))
              .toList();
          return surahs;
        }
      }
      return SurahList.surahs;
    } catch (e) {
      return SurahList.surahs;
    }
  }

  /// Get ayahs for a surah
  Future<List<AyahModel>> getSurahAyahs({
    required int surahNumber,
    String translationEdition = 'en.sahih',
  }) async {
    try {
      // Get Arabic and translation together
      final response = await http
          .get(Uri.parse('$_quranApiUrl/surah/$surahNumber/editions/quran-uthmani,$translationEdition'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK') {
          final editions = data['data'] as List<dynamic>;
          final arabicEdition = editions[0] as Map<String, dynamic>;
          final transEdition = editions.length > 1 
              ? editions[1] as Map<String, dynamic> 
              : arabicEdition;
          
          final arabicAyahs = arabicEdition['ayahs'] as List<dynamic>;
          final translationAyahs = transEdition['ayahs'] as List<dynamic>;
          
          final List<AyahModel> ayahs = [];
          for (int i = 0; i < arabicAyahs.length; i++) {
            final arabic = arabicAyahs[i] as Map<String, dynamic>;
            final translation = i < translationAyahs.length 
                ? translationAyahs[i] as Map<String, dynamic>
                : arabic;
            
            ayahs.add(AyahModel(
              number: arabic['number'] as int? ?? i + 1,
              numberInSurah: arabic['numberInSurah'] as int? ?? i + 1,
              surahNumber: surahNumber,
              text: arabic['text'] as String? ?? '',
              translation: translation['text'] as String?,
              juz: arabic['juz'] as int? ?? 1,
              page: arabic['page'] as int? ?? 1,
              hizbQuarter: arabic['hizbQuarter'] as int? ?? 1,
              sajda: arabic['sajda'] != null && arabic['sajda'] != false,
            ));
          }
          return ayahs;
        }
      }
      throw ApiException('Failed to fetch surah');
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
          .get(Uri.parse('$_quranApiUrl/ayah/$surahNumber:$ayahNumber/editions/quran-uthmani,$translationEdition'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK') {
          final editions = data['data'] as List<dynamic>;
          final arabic = editions[0] as Map<String, dynamic>;
          final translation = editions.length > 1 ? editions[1] as Map<String, dynamic> : arabic;
          
          return AyahModel(
            number: arabic['number'] as int? ?? 1,
            numberInSurah: arabic['numberInSurah'] as int? ?? ayahNumber,
            surahNumber: surahNumber,
            text: arabic['text'] as String? ?? '',
            translation: translation['text'] as String?,
            juz: arabic['juz'] as int? ?? 1,
            page: arabic['page'] as int? ?? 1,
            hizbQuarter: arabic['hizbQuarter'] as int? ?? 1,
            sajda: arabic['sajda'] != null && arabic['sajda'] != false,
          );
        }
      }
      throw ApiException('Failed to fetch ayah');
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
      // Generate random surah and ayah
      final random = Random();
      final surahNumber = random.nextInt(114) + 1;
      
      // Get surah info first to know ayah count
      final surahResponse = await http
          .get(Uri.parse('$_quranApiUrl/surah/$surahNumber'))
          .timeout(_timeout);
      
      int maxAyahs = 7; // Default to Al-Fatiha length
      if (surahResponse.statusCode == 200) {
        final surahData = jsonDecode(surahResponse.body) as Map<String, dynamic>;
        if (surahData['status'] == 'OK') {
          maxAyahs = surahData['data']['numberOfAyahs'] as int;
        }
      }
      
      final ayahNumber = random.nextInt(maxAyahs) + 1;
      return getAyah(
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        translationEdition: translationEdition,
      );
    } catch (e) {
      // Fallback to Al-Fatiha verse 5
      return AyahModel(
        number: 5,
        numberInSurah: 5,
        surahNumber: 1,
        text: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
        translation: 'It is You we worship and You we ask for help.',
        juz: 1,
        page: 1,
      );
    }
  }

  /// Search Quran
  Future<List<AyahModel>> searchQuran({
    required String query,
    String translationEdition = 'en.sahih',
  }) async {
    try {
      final response = await http
          .get(Uri.parse('$_quranApiUrl/search/$query/$translationEdition'))
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['status'] == 'OK' && data['data'] != null) {
          final searchData = data['data'] as Map<String, dynamic>;
          final matches = searchData['matches'] as List<dynamic>? ?? [];
          
          return matches.take(20).map((m) {
            final match = m as Map<String, dynamic>;
            final surah = match['surah'] as Map<String, dynamic>;
            return AyahModel(
              number: match['number'] as int? ?? 0,
              numberInSurah: match['numberInSurah'] as int? ?? 0,
              surahNumber: surah['number'] as int? ?? 0,
              text: '', // Arabic not returned in search
              translation: match['text'] as String?,
              juz: match['juz'] as int? ?? 1,
              page: match['page'] as int? ?? 1,
            );
          }).toList();
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // ============================================
  // Hadith Endpoints (Placeholder)
  // ============================================

  /// Get hadith by collection and number
  Future<HadithModel> getHadith({
    required String collection,
    required String hadithNumber,
  }) async {
    // Return placeholder hadith
    return HadithModel(
      id: '${collection}_$hadithNumber',
      collection: collection,
      hadithNumber: hadithNumber,
      arabicText: '',
      translation: 'Hadith API is being configured. Please check back later or consult hadith collections directly.',
      narrator: 'System Message',
    );
  }

  /// Search hadith
  Future<List<HadithModel>> searchHadith({
    required String query,
    String? collection,
  }) async {
    // Return empty for now
    return [];
  }

  /// Get random hadith
  Future<HadithModel> getRandomHadith({String? collection}) async {
    // Return a well-known hadith
    return HadithModel(
      id: 'bukhari_1',
      collection: 'Sahih al-Bukhari',
      hadithNumber: '1',
      arabicText: 'إِنَّمَا الأَعْمَالُ بِالنِّيَّاتِ',
      translation: 'The reward of deeds depends upon the intentions and every person will get the reward according to what he has intended.',
      narrator: 'Umar ibn al-Khattab (رضي الله عنه)',
      grade: 'Sahih',
    );
  }

  // ============================================
  // Favorites (Local only - no API needed)
  // ============================================

  Future<void> saveFavorite({
    required String type,
    required String content,
    String? arabicText,
    String? reference,
    Map<String, dynamic>? metadata,
  }) async {
    // Favorites are handled locally by HiveService
  }

  Future<void> deleteFavorite(String favoriteId) async {
    // Favorites are handled locally by HiveService
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
