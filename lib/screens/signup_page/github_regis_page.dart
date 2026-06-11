import 'package:flutter/material.dart';
import '../premium_effects.dart'; // Path to your provided effects file
import '../../services/github_auth_services.dart'; // Path to your service file

class GitHubRegisPage extends StatefulWidget {
  const GitHubRegisPage({super.key});

  @override
  State<GitHubRegisPage> createState() => _GitHubRegisPageState();
}

class _GitHubRegisPageState extends State<GitHubRegisPage> with TickerProviderStateMixin {
  late AnimationController _bgController;
  late AnimationController _textController;

  @override
  void initState() {
    super.initState();

    // 1. Background Controller: Drives the Moving Dots and Fluid Mesh
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    // 2. Text Controller: Drives the Typing animation and Fade-ins
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // Start the text animations shortly after the page appears
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _textController.forward();
      }
    });
  }

  @override
  void dispose() {
    _bgController.dispose();
    _textController.dispose();
    super.dispose();
  }

  // Trigger the GitHub Auth Service
  Future<void> _handleGitHubAuth() async {
    try {
      await GitHubAuthService().signInWithGitHub();
      // Note: The user will be redirected to GitHub's site.
    } catch (e) {
      _showErrorSnackBar(e.toString());
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A1F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // The PremiumBackgroundStack provides the MovingDots and InteractiveFluidPainter
      body: PremiumBackgroundStack(
        bgController: _bgController,
        showMovingDots: true,
        showFluidMesh: true,
        baseColor: const Color(0xFF070709),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // --- STATUS TAG ---
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.04),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: const Text(
                      'SECURE ACCESS',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- PREMIUM TYPING HEADLINE ---
                  // This uses the AuraHeadline + TypingTextAnimation from your effects file
                  AuraHeadline(
                    controller: _textController,
                    fullText: 'Authorize QuantMessage via GitHub',
                    highlightPart: 'GitHub',
                    auraController: _bgController, // Synchronize glow with background
                  ),
                  const SizedBox(height: 16),

                  // --- FADE-IN DESCRIPTION ---
                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: Text(
                      'Connect your developer profile to access institutional grade financial data and QuantNews premium tools.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.35),
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),

                  // --- PREMIUM AUTHORIZATION BUTTON ---
                  // This uses the AuraButton with the CirculatingAura border
                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: AuraButton(
                      onPressed: _handleGitHubAuth,
                      auraController: _bgController,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.code, size: 20, color: Colors.white),
                          const SizedBox(width: 12),
                          const Text(
                            'Continue with GitHub',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- BACK BUTTON ---
                  FadeInOnTextAnimation(
                    controller: _textController,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Return to Registration',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.3),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
