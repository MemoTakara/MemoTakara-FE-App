import 'dart:convert';

import 'package:flutter/cupertino.dart';

import '../models/flashcard.dart';
import '../models/study_progress.dart';
import 'api_service.dart';

class StudyService {
  Future<Map<String, dynamic>> startSession(int collectionId, String studyType, String token) async {
    // debugPrint('StudyService: Starting session for collection $collectionId');

    final response = await ApiService.post(
      '/study/start',
      headers: ApiService.getAuthHeaders(token),
      data: {
        'collection_id': collectionId.toString(),
        'study_type': studyType,
        'limit': 5,
        'new_cards_limit': 2,
        'review_cards_limit': 3,
      },
    );

    // debugPrint('StudyService: Response status: ${response.statusCode}');
    // debugPrint('StudyService: Response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        // debugPrint('StudyService: Parsed JSON successfully');
        // debugPrint('StudyService: Data structure: ${data.keys}');

        if (data['data'] == null) {
          throw Exception('Missing data field in response');
        }

        final sessionData = data['data'];
        // debugPrint('StudyService: Session data keys: ${sessionData.keys}');

        // Parse session_id
        final sessionId = sessionData['session_id'];
        // debugPrint('StudyService: Raw session_id: $sessionId (${sessionId.runtimeType})');

        final parsedSessionId = sessionId is String
            ? int.tryParse(sessionId) ?? sessionId
            : sessionId;
        // debugPrint('StudyService: Parsed session_id: $parsedSessionId');

        // Parse cards
        final cardsData = sessionData['cards'];
        // debugPrint('StudyService: Cards data type: ${cardsData.runtimeType}');
        // debugPrint('StudyService: Cards count: ${cardsData is List ? cardsData.length : 'not a list'}');

        List<Flashcard> flashcards = [];
        if (cardsData is List) {
          for (int i = 0; i < cardsData.length; i++) {
            try {
              final card = Flashcard.fromJson(cardsData[i]);
              flashcards.add(card);
              // debugPrint('StudyService: Successfully parsed card $i: ${card.front}');
            } catch (e) {
              // debugPrint('StudyService: Error parsing card $i: $e');
              // debugPrint('StudyService: Card data: ${cardsData[i]}');
              throw Exception('Error parsing flashcard at index $i: $e');
            }
          }
        } else {
          throw Exception('Cards data is not a list: ${cardsData.runtimeType}');
        }

        // Parse card_counts
        final cardCountsData = sessionData['card_counts'];
        // debugPrint('StudyService: Card counts data: $cardCountsData');

        StudyProgress progress;
        try {
          progress = StudyProgress.fromJson(cardCountsData);
          // debugPrint('StudyService: Successfully parsed progress: ${progress.toJson()}');
        } catch (e) {
          // debugPrint('StudyService: Error parsing progress: $e');
          throw Exception('Error parsing study progress: $e');
        }

        return {
          'sessionId': parsedSessionId,
          'flashcards': flashcards,
          'progress': progress,
        };
      } catch (e) {
        // debugPrint('StudyService: JSON parsing error: $e');
        throw Exception('Error parsing start session response: $e');
      }
    } else {
      // debugPrint('StudyService: Start session error: ${response.statusCode} - ${response.body}');
      throw Exception('Không thể bắt đầu phiên học: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> submitFlashcard({
    required int sessionId,
    required int flashcardId,
    required int quality,
    required String token,
  }) async {
    // debugPrint('StudyService: Submitting flashcard - Session: $sessionId, Card: $flashcardId, Quality: $quality');

    final response = await ApiService.post(
      '/study/flashcard/submit',
      headers: ApiService.getAuthHeaders(token),
      data: {
        'session_id': sessionId.toString(),
        'flashcard_id': flashcardId.toString(),
        'quality': quality,
        'study_mode': 'front_to_back',
        // 'response_time_ms': 1000,
      },
    );

    // debugPrint('StudyService: Submit response status: ${response.statusCode}');
    // debugPrint('StudyService: Submit response body: ${response.body}');

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        // debugPrint('StudyService: Submit flashcard response parsed successfully');

        return {
          'progress': StudyProgress.fromJson(data['data']['card_counts']),
          'isCorrect': data['data']['is_correct'],
        };
      } catch (e) {
        // debugPrint('StudyService: Submit flashcard parsing error: $e');
        throw Exception('Error parsing submit response: $e');
      }
    } else {
      // debugPrint('StudyService: Submit flashcard error: ${response.statusCode} - ${response.body}');
      throw Exception('Lỗi khi gửi câu trả lời: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> submitTyping({
    required int sessionId,
    required int flashcardId,
    required int quality,
    required String userAnswer,
    int responseTimeMs = 1000,
    required String token,
  }) async {
    final response = await ApiService.post(
      '/study/typing/submit',
      headers: ApiService.getAuthHeaders(token),
      data: {
        'session_id': sessionId.toString(),
        'flashcard_id': flashcardId.toString(),
        'quality': quality,
        'study_mode': 'front_to_back',
        'answer': userAnswer,
        'response_time_ms': responseTimeMs,
      },
    );

    if (response.statusCode == 200) {
      try {
        final data = jsonDecode(response.body);
        return {
          'progress': StudyProgress.fromJson(data['data']['card_counts']),
          'isCorrect': data['data']['is_correct'],
          'correct_answer': data['data']['correct_answer'],
          'similarity': data['data']['similarity'], // nếu có
        };
      } catch (e) {
        throw Exception('Error parsing typing submit response: $e');
      }
    } else {
      throw Exception('Lỗi khi gửi câu trả lời typing: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> submitMatching({
    required int sessionId,
    required List<Map<String, dynamic>> matchedPairs,
    required int responseTimeMs,
    required String token,
  }) async {
    final response = await ApiService.post(
      '/study/matching/submit',
      headers: ApiService.getAuthHeaders(token),
      data: {
        'session_id': sessionId.toString(),
        'matches': matchedPairs,
        'study_mode': 'front_to_back',
        'response_time_ms': responseTimeMs,
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded == null || decoded['data'] == null) {
        throw Exception('Response không chứa data');
      }
      return decoded['data'] as Map<String, dynamic>;
    } else {
      throw Exception('Lỗi khi gửi câu trả lời matching: ${response.statusCode} - ${response.body}');
    }
  }

  Future<Map<String, dynamic>> submitQuiz({
    required int sessionId,
    required List<Map<String, dynamic>> answers,
    required String token,
  }) async {
    final response = await ApiService.post(
      '/study/submit-quiz-answer',
      headers: ApiService.getAuthHeaders(token),
      data: {
        'session_id': sessionId.toString(),
        'answers': answers,
        'study_mode': 'front_to_back',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      throw Exception('Gửi đáp án thất bại: ${response.body}');
    }
  }

  Future<void> endSession(int sessionId, String token) async {
    // debugPrint('StudyService: Ending session $sessionId');

    final response = await ApiService.post(
      '/study/end',
      headers: ApiService.getAuthHeaders(token),
      data: {'session_id': sessionId.toString()},
    );

    // debugPrint('StudyService: End session response status: ${response.statusCode}');
    // debugPrint('StudyService: End session response body: ${response.body}');

    if (response.statusCode != 200) {
      // debugPrint('StudyService: End session error: ${response.statusCode} - ${response.body}');
      throw Exception('Không thể kết thúc phiên học: ${response.statusCode}');
    }
  }
}