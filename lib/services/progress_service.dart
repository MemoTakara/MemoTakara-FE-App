import 'dart:convert';
import '../models/dashboard_data.dart';
import '../models/analytics_data.dart';
import 'api_service.dart';

class ProgressService {
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String>? get _authHeaders =>
      _token != null ? ApiService.getAuthHeaders(_token!) : null;

  Future<DashboardData> getDashboard() async {
    final response = await ApiService.get(
      '/progress/dashboard',
      headers: _authHeaders,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return DashboardData.fromJson(data['data']);
    } else {
      throw Exception('Failed to get dashboard: ${response.statusCode}');
    }
  }

  Future<AnalyticsData> getAnalytics(int days) async {
    final response = await ApiService.get(
      '/progress/analytics?days=$days',
      headers: _authHeaders,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return AnalyticsData.fromJson(data['data']);
    } else {
      throw Exception('Failed to get analytics: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> getLeaderboard({int limit = 10}) async {
    final response = await ApiService.get(
      '/progress/leaderboard?limit=$limit',
      headers: _authHeaders,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Failed to get leaderboard: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> getStudyHeatmapData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await ApiService.get(
      '/progress/heatmap?start_date=${startDate.toIso8601String()}&end_date=${endDate.toIso8601String()}',
      headers: _authHeaders,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      throw Exception('Failed to get heatmap data: ${response.statusCode}');
    }
  }
}