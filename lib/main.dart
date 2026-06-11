import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Import your screens
import 'screens/splash_screen.dart';

Future<void> main() async {
  // 1. Ensure Flutter bindings are initialized for async setup
  // This is critical when using Supabase.initialize()
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. Initialize Supabase
    // This connects your Flutter app to your specific Supabase project backend
    await Supabase.initialize(
      url: 'https://dmgwkgadhnpjnnjklnqh.supabase.co',
      publishableKey: 'sb_publishable_Lspy0F1ek5gInIYOkY087A_IGPG3Xkg',
    );
    debugPrint("Supabase initialized successfully.");
  } catch (e) {
    debugPrint("Error initializing Supabase: $e");
  }

  runApp(const QuantNewsApp());
}

class QuantNewsApp extends StatelessWidget {
  const QuantNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuantNews',
      debugShowCheckedModeBanner: false,

      // --- PREMIUM THEME CONFIGURATION ---
      theme: ThemeData(
        brightness: Brightness.dark,
        // Your signature deep black background
        scaffoldBackgroundColor: const Color(0xFF070709),
        // Material 3 enables the modern button and input styles
        useMaterial3: true,
        // Primary color used for highlights and accents
        primaryColor: Colors.white,
        // Defining a global text theme to ensure consistency
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white, fontFamily: 'Inter'),
        ),
      ),

      // The SplashScreen is the brain of the app.
      // It should check if a Supabase session exists:
      // If session != null -> Go to Dashboard
      // If session == null -> Go to Home/Login
      home: const SplashScreen(),
    );
  }
}

/// Global Supabase client shortcut.
/// This allows you to call [supabase.auth.signInWithOAuth(...)]
/// in your Google and GitHub service files without re-initializing.
SupabaseClient get supabase => Supabase.instance.client;
