import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/collection.dart';
import '../../services/collection_service.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Collection> recentCollections = [];
  List<Collection> publicCollections = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    if (token == null) return;

    try {
      final collectionService = CollectionService();
      final recent = await collectionService.fetchRecentCollections(token);
      final publicData = await collectionService.fetchCollections(
        token: token,
        privacy: 'public',
        perPage: 10,
      );

      setState(() {
        recentCollections = recent;
        publicCollections = publicData['collections'];
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Lỗi tải collections: $e');
      setState(() => isLoading = false);
    }
  }

  Widget _buildCollectionCard(Collection item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: GestureDetector(
        onTap: () => context.push('/collection-detail/${item.id}'),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.book_outlined, size: 36),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Text(
                      //   'Người tạo: ${item.user?.username ?? 'Không rõ'}',
                      //   style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                      // ),
                      const SizedBox(height: 4),
                      Text(
                        item.description ?? 'Không có mô tả',
                        style: const TextStyle(fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Trang chủ'),
        automaticallyImplyLeading: false,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Chào mừng bạn!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),
                const Text(
                  'Bộ thẻ gần đây',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 150,
                  child: PageView.builder(
                    itemCount: recentCollections.length,
                    controller: PageController(viewportFraction: 0.85),
                    itemBuilder: (context, index) {
                      return _buildCollectionCard(recentCollections[index]);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        context.go('/collection-list?type=recent');

                      },
                      child: const Text('Xem tất cả'),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),
                const Text(
                  'Bộ thẻ công khai',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 150,
                  child: PageView.builder(
                    itemCount: publicCollections.length,
                    controller: PageController(viewportFraction: 0.85),
                    itemBuilder: (context, index) {
                      return _buildCollectionCard(publicCollections[index]);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        context.go('/collection-list?type=public');
                      },
                      child: const Text('Xem tất cả'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
