import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/collection.dart';
import '../../services/collection_service.dart';
import '../../providers/auth_provider.dart';

class CollectionDetailScreen extends StatefulWidget {
  final int id;

  const CollectionDetailScreen({super.key, required this.id});

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  bool isLoading = true;
  String? error;
  Collection? collection;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token;
      final data = await CollectionService().fetchCollectionById(widget.id, token!);
      setState(() {
        collection = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Lỗi khi tải dữ liệu: $e';
        isLoading = false;
      });
    }
  }

  void _navigateToStudy(String method) {
    context.push('/study/$method/${widget.id}');
  }

  Widget _buildStudyButton(String label, IconData icon, String method) {
    return OutlinedButton.icon(
      onPressed: () => _navigateToStudy(method),
      icon: Icon(icon, color: Color(0xff166dba), size: 18),
      label: Text(label, style: const TextStyle(color: Colors.black, fontSize: 14)),
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: Color(0xff166dba)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết Collection'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Thông tin collection
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    collection!.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Text(
                  //   'Người tạo: ${collection!.user?.name ?? 'Không rõ'}',
                  //   style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  // ),
                  const SizedBox(height: 8),
                  Text(
                    collection!.description ?? 'Không có mô tả',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Số lượng flashcard: ${collection!.flashcards.length}',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.8,
            children: [
              _buildStudyButton('Flashcard', Icons.view_agenda, 'fc'),
              _buildStudyButton('Typing', Icons.keyboard, 'typing'),
              _buildStudyButton('Matching', Icons.grid_view, 'matching'),
              _buildStudyButton('Quiz', Icons.quiz, 'quiz'),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Danh sách Flashcard',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: collection!.flashcards.length,
            itemBuilder: (context, index) {
              final flashcard = collection!.flashcards[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  // leading: const Icon(Icons.card_giftcard),
                  title: Text(flashcard.front),
                  subtitle: Text(flashcard.back),
                  // trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {},
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          if (collection!.canEdit ?? false)
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Chỉnh sửa collection
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Chỉnh sửa'),
              ),
            ),
        ],
      ),
    );
  }
}
