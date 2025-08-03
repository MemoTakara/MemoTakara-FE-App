import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../components/stat_card_widget.dart';
import '../../models/analytics_data.dart';
import '../../models/dashboard_data.dart';
import '../../services/progress_service.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> {
  final ProgressService _progressService = ProgressService();

  DashboardData? dashboardData;
  AnalyticsData? analyticsData;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      // Simulate loading delay
      await Future.delayed(const Duration(seconds: 1));

      // Create fake dashboard data
      final fakeDashboard = DashboardData(
        todayStats: TodayStats(
          studyTimeMinutes: 45,
          sessionsCount: 3,
          goalProgress: GoalProgress(
            cardsStudied: 28,
            dailyGoal: 30,
            progressPercentage: 93.3,
            goalAchieved: false,
          ),
          cardsStudied: 58,
        ),
        overallStats: OverallStats(
          totalCards: 250,
          newCards: 50,
          learningCards: 75,
          reviewCards: 85,
          masteredCards: 35,
          dueCards: 15,
          studyStreak: 2,
        ),
      );

      // Create fake analytics data
      final fakeAnalytics = AnalyticsData(
        difficultyAnalysis: DifficultyAnalysis(
          averageQuality: 3.8,
          successRate: 85.5,
          hardCount: 20,
          goodCount: 150,
          easyCount: 80,
        ),
        // retentionRate:,
        collectionPerformance: [
          CollectionPerformance(
            collectionId: 'col1',
            collectionName: 'Từ vựng Minna no Nihongo Bài 42',
            totalCards: 45,
            accuracy: 92,
            totalTime: 120, sessionsCount: 6,
          ),
        ],
      );

      setState(() {
        dashboardData = fakeDashboard;
        analyticsData = fakeAnalytics;
        isLoading = false;
      });

    } catch (e) {
      setState(() {
        error = 'Lỗi khi tải dữ liệu: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Thống kê'),
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadData,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Thống kê'),
        automaticallyImplyLeading: false,
        // backgroundColor: Colors.white,
        // foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Today's Performance
              _buildSectionTitle('Hiệu suất hôm nay'),
              const SizedBox(height: 12),
              _buildTodayStats(),
              const SizedBox(height: 24),

              // Daily Goal Progress
              _buildSectionTitle('Tiến độ mục tiêu hàng ngày'),
              const SizedBox(height: 12),
              _buildDailyGoalProgress(),
              const SizedBox(height: 24),

              // Cards Overview
              _buildSectionTitle('Tổng quan thẻ học'),
              const SizedBox(height: 12),
              _buildCardsOverview(),
              const SizedBox(height: 24),

              // Performance Metrics
              _buildSectionTitle('Chỉ số hiệu suất'),
              const SizedBox(height: 12),
              _buildPerformanceMetrics(),
              const SizedBox(height: 24),

              // Study Heatmap
              // _buildSectionTitle('Lịch học tập'),
              // const SizedBox(height: 12),
              // _buildStudyHeatmap(),
              // const SizedBox(height: 24),

              // Collection Performance
              _buildSectionTitle('Hiệu suất bộ sưu tập'),
              const SizedBox(height: 12),
              _buildCollectionPerformance(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTodayStats() {
    final todayStats = dashboardData?.todayStats;
    final overallStats = dashboardData?.overallStats;

    return Row(
      children: [
        Expanded(
          child: StatCardWidget(
            title: 'Thời gian học',
            value: '${todayStats?.studyTimeMinutes ?? 0}',
            suffix: 'phút',
            icon: Icons.access_time,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCardWidget(
            title: 'Phiên học',
            value: '${todayStats?.sessionsCount ?? 0}',
            icon: Icons.book,
            color: Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyGoalProgress() {
    final goalProgress = dashboardData?.todayStats.goalProgress;
    final progressPercentage = goalProgress?.progressPercentage ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mục tiêu hàng ngày',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              if (goalProgress?.goalAchieved == true)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Hoàn thành',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progressPercentage / 100,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              goalProgress?.goalAchieved == true ? Colors.green : Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${goalProgress?.cardsStudied ?? 0} / ${goalProgress?.dailyGoal ?? 0} thẻ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardsOverview() {
    final stats = dashboardData?.overallStats;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Stats list
          Container(
            width: MediaQuery.of(context).size.width * 0.3, // Tăng chiều rộng
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Căn trái
              children: [
                _buildStatRow('Tổng cộng', stats?.totalCards ?? 0, Colors.black87),
                _buildStatRow('Mới', stats?.newCards ?? 0, Color(0xff1890ff)),
                _buildStatRow('Đang học', stats?.learningCards ?? 0, Color(0xfffa8c16)),
                _buildStatRow('Ôn tập', stats?.reviewCards ?? 0, Color(0xff722ed1)),
                _buildStatRow('Thành thạo', stats?.masteredCards ?? 0, Color(0xff52c41a)),
                _buildStatRow('Đến hạn', stats?.dueCards ?? 0, Color(0xfff5222d)),
              ],
            ),
          ),
          const SizedBox(width: 16), // Khoảng cách giữa danh sách và biểu đồ
          // Pie chart
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.5, // Chiều rộng biểu đồ
            height: 200,
            child: PieChart(
              PieChartData(
                sections: _buildPieChartSections(stats),
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String title, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 14)),
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections(OverallStats? stats) {
    if (stats == null || stats.totalCards == 0) return [];

    return [
      PieChartSectionData(
        color: Color(0xff1890ff),
        value: stats.newCards.toDouble(),
        title: '${((stats.newCards / stats.totalCards) * 100).toInt()}%',
        radius: 50,
      ),
      PieChartSectionData(
        color: Color(0xfffa8c16),
        value: stats.learningCards.toDouble(),
        title: '${((stats.learningCards / stats.totalCards) * 100).toInt()}%',
        radius: 50,
      ),
      PieChartSectionData(
        color: Color(0xff722ed1),
        value: stats.reviewCards.toDouble(),
        title: '${((stats.reviewCards / stats.totalCards) * 100).toInt()}%',
        radius: 50,
      ),
      PieChartSectionData(
        color: Color(0xff52c41a),
        value: stats.masteredCards.toDouble(),
        title: '${((stats.masteredCards / stats.totalCards) * 100).toInt()}%',
        radius: 50,
      ),
      PieChartSectionData(
        color: Color(0xfff5222d),
        value: stats.dueCards.toDouble(),
        title: '${((stats.dueCards / stats.totalCards) * 100).toInt()}%',
        radius: 50,
      ),
    ];
  }

  Widget _buildPerformanceMetrics() {
    final difficultyAnalysis = analyticsData?.difficultyAnalysis;
    // final retentionRate = analyticsData?.retentionRate;

    return Row(
      children: [
        Expanded(
          child: StatCardWidget(
            title: 'Chất lượng TB',
            value: '4.28',
            suffix: '/ 5',
            icon: Icons.star,
            color: Colors.amber,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StatCardWidget(
            title: 'Tỷ lệ thành công',
            value: '${difficultyAnalysis?.successRate?.toStringAsFixed(1) ?? '0.0'}',
            suffix: '%',
            icon: Icons.check_circle,
            color: Colors.green,
          ),
        ),
      ],
    );
  }


  Widget _buildCollectionPerformance() {
    final collections = analyticsData?.collectionPerformance ?? [];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Expanded(flex: 5, child: Text('Bộ sưu tập', style: TextStyle(fontWeight: FontWeight.w500))),
                const Expanded(flex: 2, child: Text('Độ chính xác', style: TextStyle(fontWeight: FontWeight.w500))),
                const Expanded(flex: 2, child: Text('Thời gian', style: TextStyle(fontWeight: FontWeight.w500))),
              ],
            ),
          ),
          // Data rows
          ...collections.take(1).map((collection) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.grey[200]!),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 5, // Tăng flex của cột này
                  child: Text(
                    collection.collectionName,
                    style: const TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  flex: 2, // Giữ nguyên flex cho cột độ chính xác
                  child: Text(
                    '85.5%',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                Expanded(
                  flex: 2, // Giữ nguyên flex cho cột thời gian
                  child: Text(
                    '67p',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}