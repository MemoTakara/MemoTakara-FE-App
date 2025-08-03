import 'package:flutter/material.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Thông báo'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Text(
          'Thông báo',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}