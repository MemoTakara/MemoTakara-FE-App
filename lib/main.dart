import 'package:flutter/material.dart';
import 'router.dart';

void main() {
  runApp(const MemoTakaraApp());
}

class MemoTakaraApp extends StatelessWidget {
  const MemoTakaraApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Memo Takara',
      routerConfig: appRouter,
    );
  }
}
