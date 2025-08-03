class DashboardData {
  final TodayStats todayStats;
  final OverallStats overallStats;

  DashboardData({
    required this.todayStats,
    required this.overallStats,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      todayStats: TodayStats.fromJson(json['today_stats']),
      overallStats: OverallStats.fromJson(json['overall_stats']),
    );
  }
}

class TodayStats {
  final int studyTimeMinutes;
  final int sessionsCount;
  final int cardsStudied;
  final GoalProgress goalProgress;

  TodayStats({
    required this.studyTimeMinutes,
    required this.sessionsCount,
    required this.cardsStudied,
    required this.goalProgress,
  });

  factory TodayStats.fromJson(Map<String, dynamic> json) {
    return TodayStats(
      studyTimeMinutes: json['study_time_minutes'] ?? 0,
      sessionsCount: json['sessions_count'] ?? 0,
      cardsStudied: json['cards_studied'] ?? 0,
      goalProgress: GoalProgress.fromJson(json['goal_progress'] ?? {}),
    );
  }
}

class OverallStats {
  final int totalCards;
  final int newCards;
  final int learningCards;
  final int reviewCards;
  final int masteredCards;
  final int dueCards;
  final int studyStreak;

  OverallStats({
    required this.totalCards,
    required this.newCards,
    required this.learningCards,
    required this.reviewCards,
    required this.masteredCards,
    required this.dueCards,
    required this.studyStreak,
  });

  factory OverallStats.fromJson(Map<String, dynamic> json) {
    return OverallStats(
      totalCards: json['total_cards'] ?? 0,
      newCards: json['new_cards'] ?? 0,
      learningCards: json['learning_cards'] ?? 0,
      reviewCards: json['review_cards'] ?? 0,
      masteredCards: json['mastered_cards'] ?? 0,
      dueCards: json['due_cards'] ?? 0,
      studyStreak: json['study_streak'] ?? 0,
    );
  }
}

class GoalProgress {
  final int cardsStudied;
  final int dailyGoal;
  final double progressPercentage;
  final bool goalAchieved;

  GoalProgress({
    required this.cardsStudied,
    required this.dailyGoal,
    required this.progressPercentage,
    required this.goalAchieved,
  });

  factory GoalProgress.fromJson(Map<String, dynamic> json) {
    return GoalProgress(
      cardsStudied: json['cards_studied'] ?? 0,
      dailyGoal: json['daily_goal'] ?? 0,
      progressPercentage: (json['progress_percentage'] ?? 0.0).toDouble(),
      goalAchieved: json['goal_achieved'] ?? false,
    );
  }
}

class WeeklyComparison {
  final int thisWeek;
  final double changePercentage;

  WeeklyComparison({
    required this.thisWeek,
    required this.changePercentage,
  });

  factory WeeklyComparison.fromJson(Map<String, dynamic> json) {
    return WeeklyComparison(
      thisWeek: json['this_week'] ?? 0,
      changePercentage: (json['change_percentage'] ?? 0.0).toDouble(),
    );
  }
}