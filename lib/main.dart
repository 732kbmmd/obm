// lib/main.dart (수정 후)

import 'package:flutter/material.dart';
import 'package:obm/viewmodels/app_viewmodel.dart'; // AppViewModel import
import 'package:obm/views/screens/selection_screen.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    // 앱의 최상위에서 AppViewModel을 제공합니다.
    ChangeNotifierProvider(
      create: (context) => AppViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '오뱅몇',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        brightness: Brightness.dark,
      ),
      home: const SelectionScreen(),
    );
  }
}
