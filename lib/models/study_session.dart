import 'flashcard.dart';
import 'study_progress.dart';

class StudySession {
  final String sessionId;
  final List<Flashcard> cards;
  final StudyProgress progress;

  StudySession({
    required this.sessionId,
    required this.cards,
    required this.progress,
  });

  factory StudySession.fromJson(Map<String, dynamic> json) {
    return StudySession(
      sessionId: json['session_id'],
      cards: (json['cards'] as List)
          .map((card) => Flashcard.fromJson(card))
          .toList(),
      progress: StudyProgress.fromJson(json['card_counts'] ?? {}),
    );
  }
}