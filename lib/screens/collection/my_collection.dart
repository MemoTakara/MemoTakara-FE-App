import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/collection.dart';
import '../../services/collection_service.dart';
import '../../providers/auth_provider.dart';

class MyCollectionScreen extends StatefulWidget {
  const MyCollectionScreen({super.key});

  @override
  State<MyCollectionScreen> createState() => _MyCollectionScreenState();
}

class _MyCollectionScreenState extends State<MyCollectionScreen> {
  bool isLoading = true;
  String? error;
  List<Collection> collections = [];

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    setState(() => isLoading = true);
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      if (token == null) throw Exception('Token không tồn tại');
      final result = await CollectionService().fetchMyCollections(token);
      setState(() {
        collections = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('$e');
      setState(() {
        error = 'Lỗi khi tải danh sách bộ sưu tập: \$e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bộ sưu tập của tôi')),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : ListView.builder(
        itemCount: collections.length,
        itemBuilder: (context, index) {
          final item = collections[index];
          return Card(
            elevation: 3,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(item.name),
              subtitle: Text(item.description ?? 'Không có mô tả'),
              onTap: () {
                Navigator.pushNamed(context, '/collection-detail/\${item.id}');
              },
            ),
          );
        },
      ),
    );
  }
}
