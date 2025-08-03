import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;
  final String location;

  const MainScaffold({
    super.key,
    required this.child,
    required this.location,
  });

  int _calculateSelectedIndex(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/study')) return 1;
    if (location.startsWith('/statistics')) return 2;
    if (location.startsWith('/notifications')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  Color _getBackgroundColor(String location) {
    // Các trang có background #f1f2ff
    if (location.startsWith('/home') ||
        location.startsWith('/study') ||
        location.startsWith('/statistics')) {
      return const Color(0xfff1f2ff);
    }
    // Các trang khác có background trắng
    return Colors.white;
  }

  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/my-collection');
        break;
      case 2:
        context.go('/statistics');
        break;
      case 3:
        context.go('/notifications');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _getBackgroundColor(location),
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _calculateSelectedIndex(location),
        onTap: (index) => _onItemTapped(context, index),
        selectedItemColor: const Color(0xff166dba),
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Học',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Thống kê',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Thông báo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
      ),
    );
  }
}