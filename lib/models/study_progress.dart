class StudyProgress {
  final int newCards;
  final int learning;
  final int due;

  StudyProgress({
    required this.newCards,
    required this.learning,
    required this.due,
  });

  factory StudyProgress.fromJson(Map<String, dynamic> json) {
    return StudyProgress(
      newCards: json['new'] is String ? int.parse(json['new'] ?? '0') : (json['new'] ?? 0),
      learning: json['learning'] is String ? int.parse(json['learning'] ?? '0') : (json['learning'] ?? 0),
      due: json['due'] is String ? int.parse(json['due'] ?? '0') : (json['due'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'new': newCards,
      'learning': learning,
      'due': due,
    };
  }

  int get total => newCards + learning + due;
}