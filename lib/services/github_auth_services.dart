import 'package:supabase_flutter/supabase_flutter.dart';

class GitHubAuthService {
  // Singleton pattern to avoid creating multiple instances of the service
  static final GitHubAuthService _instance = GitHubAuthService._internal();
  factory GitHubAuthService() => _instance;
  GitHubAuthService._internal();

  final SupabaseClient _supabase = Supabase.instance.client;

  /// Triggers the GitHub OAuth flow
  Future<void> signInWithGitHub() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.github,
        // Change this to your actual deployed domain (e.g., https://quantnews.vercel.app)
        redirectTo: 'http://localhost:3000',
      );
    } on AuthException catch (e) {
      throw Exception('Supabase Auth Error: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  /// Check if the user is currently logged in
  bool get isSignedIn => _supabase.auth.currentSession != null;

  /// Logout function
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}
