import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'premium_effects.dart'; // Path to your effects file
import 'home_screen.dart';
// import 'dashboard_screen.dart'; // Import this once you create it

class AuthGuard extends StatelessWidget {
  const AuthGuard({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder listens to Supabase Auth changes in real-time
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // 1. While the app is communicating with Supabase to check the session
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const PremiumLoadingScreen();
        }

        final session = snapshot.data?.session;

        // 2. If session exists, the user is logged in -> Go to Dashboard
        if (session != null) {
          // REPLACE 'HomeScreen()' with 'DashboardScreen()' once created
          return const HomeScreen();
        }

        // 3. If no session exists, user is not logged in -> Go to Landing Page
        return const HomeScreen();
      },
    );
  }
}

/// A high-end loading screen that uses the MovingDots and FluidMesh
/// to ensure the transition feels premium.
class PremiumLoadingScreen extends StatefulWidget {
  const PremiumLoadingScreen({super.key});

  @override
  State<PremiumLoadingScreen> createState() => _PremiumLoadingScreenState();
}

class _PremiumLoadingScreenState extends State<PremiumLoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    // Initialize the controller to drive the PremiumBackgroundStack animations
    _bgController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 15)
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PremiumBackgroundStack(
      bgController: _bgController,
      showMovingDots: true,
      showFluidMesh: true,
      baseColor: const Color(0xFF070709),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Premium Loader: A sleek, thin circular indicator
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withOpacity(0.8),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Branded Text with high letter spacing for a "Quant" feel
            Text(
              'QUANTMESSAGE',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 6.0,
              ),
            ),
            const SizedBox(height: 8),
            // Subtle status text
            Text(
              'VERIFYING SESSION',
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 8,
                fontWeight: FontWeight.w500,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
