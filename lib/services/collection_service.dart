import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api_config.dart';
import '../models/collection.dart';
import 'api_service.dart';

class CollectionService {
  Future<Map<String, dynamic>> fetchCollections({
    required String token,
    int page = 1,
    int perPage = 10,
    String? search,
    String? userId,
    String? difficulty,
    String? languageFront,
    String? languageBack,
    String? tags,
    String? privacy,
    String? sortBy,
    String? sortOrder,
    bool? featured,
  }) async {
    final queryParams = {
      'page': '$page',
      'per_page': '$perPage',
      if (search != null) 'search': search,
      if (userId != null) 'user_id': userId,
      if (difficulty != null) 'difficulty': difficulty,
      if (languageFront != null) 'language_front': languageFront,
      if (languageBack != null) 'language_back': languageBack,
      if (tags != null) 'tags': tags,
      if (privacy != null) 'privacy': privacy,
      if (sortBy != null) 'sort_by': sortBy,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (featured != null) 'featured': featured.toString(),
    };

    final uri = Uri.parse('${ApiConfig.apiBaseUrl}/collections').replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: ApiService.getAuthHeaders(token));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Kiểm tra an toàn
      final collectionsData = data['data']?['data'];
      if (collectionsData is! List) {
        throw Exception('Dữ liệu bộ sưu tập không hợp lệ');
      }

      return {
        // 'collections': (data['data']['data'] as List)
        //     .map((json) => Collection.fromJson(json))
        //     .toList(),
        'collections': collectionsData.map((json) => Collection.fromJson(json)).toList(),
        'meta': data['data'],
        'filters': data['filters'],
      };
    } else {
      debugPrint('Fetch collections error: ${response.statusCode} - ${response.body}');
      throw Exception('Không thể tải danh sách bộ sưu tập: ${response.statusCode}');
    }
  }

  Future<List<Collection>> fetchMyCollections(String token, {int page = 1, String? search}) async {
    final queryParams = {
      'page': page.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
    };

    final uri = Uri.parse('${ApiConfig.apiBaseUrl}/collections/my-collections').replace(queryParameters: queryParams);

    final response = await ApiService.get(
      uri.toString(),
      headers: ApiService.getAuthHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint('MyCollections API response: ${response.body}');

      final List<dynamic> collectionList = data['data']['data']; // danh sách collections trong paginated data
      return collectionList.map((json) => Collection.fromJson(json)).toList();
    } else {
      debugPrint('Fetch my collections error: ${response.statusCode} - ${response.body}');
      throw Exception('Không thể tải bộ sưu tập cá nhân: ${response.statusCode}');
    }
  }

  Future<List<Collection>> fetchRecentCollections(String token) async {
    final response = await ApiService.get(
      '/collections/recent',
      headers: ApiService.getAuthHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<dynamic> collections = data['data'];
      return collections.map((item) => Collection.fromJson(item)).toList();
    } else {
      debugPrint('Fetch recent collections error: ${response.statusCode} - ${response.body}');
      throw Exception('Không thể tải danh sách gần đây: ${response.statusCode}');
    }
  }

  Future<Collection> fetchCollectionById(int collectionId, String token) async {
    final response = await ApiService.get(
      '/collections/$collectionId',
      headers: ApiService.getAuthHeaders(token),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      debugPrint('Collection API response: ${response.body}');

      // Tạo collection với can_edit từ response root level
      final collectionData = data['data']['collection'];
      collectionData['can_edit'] = data['data']['can_edit'];

      return Collection.fromJson(collectionData);
    } else {
      debugPrint('Fetch collection error: ${response.statusCode} - ${response.body}');
      throw Exception('Không thể tải bộ sưu tập: ${response.statusCode}');
    }
  }
}