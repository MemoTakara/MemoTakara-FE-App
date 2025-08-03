import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/collection.dart';
import '../../services/collection_service.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class CollectionListScreen extends StatefulWidget {
  final String type;

  const CollectionListScreen({super.key, required this.type});

  @override
  State<CollectionListScreen> createState() => _CollectionListScreenState();
}

class _CollectionListScreenState extends State<CollectionListScreen> {
  List<Collection> collections = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    setState(() => isLoading = true);
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token == null) throw Exception('Không tìm thấy token xác thực');

      final service = CollectionService();
      if (widget.type == 'recent') {
        collections = await service.fetchRecentCollections(token);
      } else {
        final result = await service.fetchCollections(
          token: token,
          privacy: 'public',
          perPage: 50,
        );

        if (result['collections'] is List<Collection>) {
          collections = result['collections'];
        } else {
          throw Exception('Kết quả không chứa danh sách bộ sưu tập');
        }

        collections = result['collections'];
      }
    } catch (e) {
      setState(() => error = 'Lỗi khi tải danh sách: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == 'recent' ? 'Bộ thẻ gần đây' : 'Bộ thẻ công khai';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : collections.isEmpty
          ? const Center(child: Text('Không có dữ liệu'))
          : ListView.separated(
        itemCount: collections.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = collections[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            leading: const Icon(Icons.book_outlined),
            title: Text(
              item.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              item.description ?? 'Không có mô tả',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => context.push('/collection-detail/${item.id}'),
          );
        },
      ),
    );
  }
}
