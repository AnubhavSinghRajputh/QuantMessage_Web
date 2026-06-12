import 'package:flutter/material.dart';
import 'dart:math' as math;

class HomeAnimation extends StatefulWidget {
  const HomeAnimation({super.key});

  @override
  State<HomeAnimation> createState() => _HomeAnimationState();
}

class _HomeAnimationState extends State<HomeAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Star> _stars;
  late List<Planet> _planets;

  @override
  void initState() {
    super.initState();

    // Animation controller to drive the space motion
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Initialize stars and planets
    _initSpaceObjects();
  }

  void _initSpaceObjects() {
    final random = math.Random();

    // Create 150 stars with different sizes and twinkle phases
    _stars = List.generate(150, (index) {
      return Star(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: random.nextDouble() * 2.0 + 0.5,
        phase: random.nextDouble() * math.pi * 2,
        speed: random.nextDouble() * 0.05 + 0.02,
      );
    });

    // Create 3 distinct planets with different orbits and colors
    _planets = [
      Planet(
        radius: 25,
        orbitRadius: 120,
        speed: 0.2,
        color: Colors.blueGrey,
        glowColor: Colors.blue.withOpacity(0.3),
        phase: 0.0,
      ),
      Planet(
        radius: 15,
        orbitRadius: 200,
        speed: -0.15,
        color: Colors.orangeAccent,
        glowColor: Colors.orange.withOpacity(0.3),
        phase: math.pi,
      ),
      Planet(
        radius: 10,
        orbitRadius: 280,
        speed: 0.1,
        color: Colors.purpleAccent,
        glowColor: Colors.purple.withOpacity(0.3),
        phase: math.pi / 2,
      ),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(color: Color(0xFF020205)),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                painter: SpacePainter(
                  animationValue: _controller.value,
                  stars: _stars,
                  planets: _planets,
                ),
                child: Container(),
              );
            },
          ),
        );
      },
    );
  }
}

/// Data model for stars
class Star {
  final double x;
  final double y;
  final double size;
  final double phase;
  final double speed;
  Star({required this.x, required this.y, required this.size, required this.phase, required this.speed});
}

/// Data model for planets
class Planet {
  final double radius;
  final double orbitRadius;
  final double speed;
  final Color color;
  final Color glowColor;
  final double phase;
  Planet({required this.radius, required this.orbitRadius, required this.speed, required this.color, required this.glowColor, required this.phase});
}

class SpacePainter extends CustomPainter {
  final double animationValue;
  final List<Star> stars;
  final List<Planet> planets;

  SpacePainter({required this.animationValue, required this.stars, required this.planets});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 1. DYNAMIC LIGHTING: Deep space radial gradient (The "Nebula" effect)
    final paintBg = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF1A1A2E), // Center deep blue
          const Color(0xFF0A0A15), // Mid dark
          const Color(0xFF020205), // Edge black
        ],
        center: Alignment.center,
        radius: 1.5,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paintBg);

    // 2. DRAW THE MOON (Central focal point)
    final moonPaint = Paint()
      ..color = Colors.white
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    // Moon glow
    canvas.drawCircle(center, 40, moonPaint);

    // Moon core
    final moonCorePaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, 30, moonCorePaint);

    // 3. DRAW STARS (Twinkling effect)
    for (final star in stars) {
      // Twinkle logic: modulate opacity using sine wave
      final opacity = (0.3 + 0.7 * math.sin(animationValue * 2 * math.pi * star.speed + star.phase)).clamp(0.1, 1.0);

      final starPaint = Paint()
        ..color = Colors.white.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(star.x * size.width, star.y * size.height), star.size, starPaint);
    }

    // 4. DRAW PLANETS (Orbiting effect)
    for (final planet in planets) {
      final angle = (animationValue * 2 * math.pi * planet.speed) + planet.phase;
      final px = center.dx + math.cos(angle) * planet.orbitRadius;
      final py = center.dy + math.sin(angle) * planet.orbitRadius;

      // Planet Glow (Atmosphere)
      final glowPaint = Paint()
        ..color = planet.glowColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(Offset(px, py), planet.radius * 2, glowPaint);

      // Planet Core
      final planetPaint = Paint()
        ..shader = RadialGradient(
          colors: [planet.color, Colors.black],
          stops: const [0.3, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(px, py), radius: planet.radius));

      canvas.drawCircle(Offset(px, py), planet.radius, planetPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SpacePainter oldDelegate) => true;
}
