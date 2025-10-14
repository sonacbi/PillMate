// main.dart

import 'package:flutter/material.dart';
import 'pages/start_page.dart';
import 'pages/guide_page.dart';
import 'pages/manage_page.dart';

void main() {
  runApp(PillMateApp());
}

class PillMateApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PillMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => StartPage(),
        '/guide': (context) => GuidePage(),
        '/manage': (context) => ManagePage(
              onBack: () => Navigator.pop(context),
            ),
      },
    );
  }
}
