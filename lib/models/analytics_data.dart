class AnalyticsData {
  final List<CollectionPerformance> collectionPerformance;
  final DifficultyAnalysis difficultyAnalysis;
  // final RetentionRate retentionRate;

  AnalyticsData({
    required this.collectionPerformance,
    required this.difficultyAnalysis,
    // required this.retentionRate,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      collectionPerformance: (json['collection_performance'] as List?)
          ?.map((item) => CollectionPerformance.fromJson(item))
          .toList() ??
          [],
      difficultyAnalysis: DifficultyAnalysis.fromJson(json['difficulty_analysis'] ?? {}),
      // retentionRate: RetentionRate.fromJson(json['retention_rate'] ?? {}),
    );
  }
}

class CollectionPerformance {
  final String collectionName;
  final int totalCards;
  final double accuracy;
  final int totalTime;
  final int sessionsCount;

  CollectionPerformance({
    required this.collectionName,
    required this.totalCards,
    required this.accuracy,
    required this.totalTime,
    required this.sessionsCount, required String collectionId,
  });

  factory CollectionPerformance.fromJson(Map<String, dynamic> json) {
    return CollectionPerformance(
      collectionName: json['collection_name'] ?? '',
      totalCards: json['total_cards'] ?? 0,
      accuracy: (json['accuracy'] ?? 0.0).toDouble(),
      totalTime: json['total_time'] ?? 0,
      sessionsCount: json['sessions_count'] ?? 0, collectionId: json['collection_id'] ?? '',
    );
  }
}

class DifficultyAnalysis {
  final double averageQuality;
  final double successRate;

  DifficultyAnalysis({
    required this.averageQuality,
    required this.successRate, required int hardCount, required int goodCount, required int easyCount,
  });

  factory DifficultyAnalysis.fromJson(Map<String, dynamic> json) {
    return DifficultyAnalysis(
      averageQuality: (json['average_quality'] ?? 0.0).toDouble(),
      successRate: (json['success_rate'] ?? 0.0).toDouble(), hardCount: 20, goodCount: 2, easyCount: 12,
    );
  }
}

class RetentionRate {
  final double retentionRate;

  RetentionRate({
    required this.retentionRate,
  });

  factory RetentionRate.fromJson(Map<String, dynamic> json) {
    return RetentionRate(
      retentionRate: (json['retention_rate'] ?? 0.0).toDouble(),
    );
  }
}