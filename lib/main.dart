import 'package:MemoTakara/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'router.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthProvider()..checkLoginStatus(),
      child: const MemoTakaraApp(),
    ),
  );
}

class MemoTakaraApp extends StatelessWidget {
  const MemoTakaraApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Memo Takara',
      theme: ThemeData(
        primaryColor: Color(0xff166dba),
        scaffoldBackgroundColor: const Color(0xfff1f2ff),
        textTheme: const TextTheme(
          labelMedium: TextStyle(color: Colors.black),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xff166dba),
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      routerConfig: appRouter,
    );
  }
}
