import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/collection_model.dart';
import '../config/api_config.dart'; // Import config

class PublicCollectionService {

  static Future<List<Collection>> fetchPublicCollections() async {
    // Sử dụng ApiConfig.apiBaseUrl thay vì apiBaseUrl
    final response = await http.get(Uri.parse('${ApiConfig.apiBaseUrl}/public-collections'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body)['data'];
      return data.map((json) => Collection.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load public collections');
    }
  }

  // Thêm phương thức lấy chi tiết collection công khai (nếu cần)
  static Future<Collection> fetchPublicCollectionDetail(String id) async {
    final response = await http.get(Uri.parse('${ApiConfig.apiBaseUrl}/public-collections/$id'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'];
      return Collection.fromJson(data);
    } else {
      throw Exception('Failed to load collection details');
    }
  }
}