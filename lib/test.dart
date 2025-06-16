import 'package:MemoTakara/providers/auth_provider.dart';
import 'package:MemoTakara/screens/home_screen.dart';
import 'package:MemoTakara/screens/search_screen.dart';
import 'package:MemoTakara/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authProvider = AuthProvider();
  await authProvider.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        // Các provider khác
      ],
      child: const MemoTakaraApp(),
    ),
  );
}

class MemoTakaraApp extends StatefulWidget {
  const MemoTakaraApp({super.key});

  @override
  _MemoTakaraAppState createState() => _MemoTakaraAppState();
}

class _MemoTakaraAppState extends State<MemoTakaraApp> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    HomeScreen(),
    SearchScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.initialized) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xff166dba)),
        scaffoldBackgroundColor: const Color(0xfff1f2ff),
        // Các cấu hình khác...
      ),
      home: Scaffold(
        body: _pages[_selectedIndex], // Hiển thị trang dựa trên chỉ số
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blue,
          onTap: _onItemTapped, // Xử lý sự kiện khi nhấn vào item
        ),
      ),
    );
  }
}