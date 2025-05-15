import 'package:flutter/material.dart';
import '../../services/collection_service.dart';
import '../../models/collection_model.dart';
import '../../components/collection_card.dart';
import '../../components/appbar_with_auth.dart';
import '../collection/collection_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isLoggedIn;

  const HomeScreen({super.key, required this.isLoggedIn});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Collection>> _collections;

  @override
  void initState() {
    super.initState();
    _collections = PublicCollectionService.fetchPublicCollections();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithAuth(
        isLoggedIn: widget.isLoggedIn,
        onLogin: () => Navigator.pushNamed(context, '/login'),
        onRegister: () => Navigator.pushNamed(context, '/register'),
      ),
      body: FutureBuilder<List<Collection>>(
        future: _collections,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final collections = snapshot.data!;
            return ListView.builder(
              itemCount: collections.length,
              itemBuilder: (context, index) {
                final collection = collections[index];
                return GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CollectionDetailScreen(id: collection.id),
                    ),
                  ),
                  child: CollectionCard(collection: collection),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
