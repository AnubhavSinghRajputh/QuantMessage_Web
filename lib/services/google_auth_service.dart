import 'package:supabase_flutter/supabase_flutter.dart';

/// GoogleAuthService for Web
/// Handles the OAuth2 redirect flow for Google Sign-In.
/// Since this is for WEB, we use signInWithOAuth instead of ID Tokens.
class GoogleAuthService {
  final SupabaseClient _client;

  /// Constructor follows the same pattern as AuthService
  GoogleAuthService(this._client);

  /// Returns the currently authenticated user from the Supabase session
  User? get currentUser => _client.auth.currentUser;

  /// Quick check to see if the user is authenticated
  bool get isLoggedIn => currentUser != null;

  /// This is the main engine method for Web.
  /// It is called by [GoogleLoginPage] when the user clicks 'Authorize Account'.
  /// Note: On the web, this method does not return a response immediately because
  /// the browser redirects the user away from the app to Google's servers.
  Future<void> signInWithGoogle() async {
    try {
      /// Trigger the OAuth redirect flow.
      /// This will send the user to the Google Login page.
      /// Once they authorize, Google redirects them back to your QuantNews site.
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        // Optional: You can specify a specific redirect URL if not using the one in the dashboard
        // redirectTo: 'http://localhost:XXXXX',
      );
    } on AuthException catch (e) {
      // Rethrow Supabase exceptions so the UI can display the error
      rethrow;
    } catch (e) {
      // Wrap generic errors into AuthException (Positional argument fix applied)
      throw AuthException('An unexpected error occurred during Web Google Auth: ${e.toString()}');
    }
  }

  /// Signs out the user from the Supabase session.
  /// On the web, the session is managed by the browser cookie/localStorage.
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw AuthException('Unable to sign out: ${e.toString()}');
    }
  }
}
