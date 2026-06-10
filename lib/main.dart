import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
void main() {
  runApp(const ComingSoonApp());
}
class ComingSoonApp extends StatelessWidget {
  const ComingSoonApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coming Soon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0C),
        primaryColor: Colors.white,
        fontFamily: 'Inter',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
          bodyLarge: TextStyle(
            color: Color(0xFF9E9E9E),
            fontSize: 16,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
