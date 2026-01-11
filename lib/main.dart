import 'package:flutter/material.dart';
import 'package:mymovewiseapp/splashpage.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My MoveWise',
      theme: ThemeData(
        useMaterial3: true,
        // Keeping the PawPal brown styling as requested
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.brown,
          foregroundColor: Colors.white,
        ),
      ),
      home: const SplashPage(),
    );
  }
}

