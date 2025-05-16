import 'package:flutter/material.dart';

class CollectionDetailScreen extends StatelessWidget {
  final int id;

  const CollectionDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết Collection')),
      body: Center(child: Text('Đang tải flashcard cho collection $id')),
    );
  }
}
