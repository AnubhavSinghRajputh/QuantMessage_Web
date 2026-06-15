// lib/animations/pendulum_animation.dart
//
// Draws the clock/pendulum icon seen in the screenshot:
// - Outer circle ring
// - Vertical stem (top to bottom through centre)
// - Horizontal crosshair tick at centre
// - Small filled dot at centre
// - A sweeping "pendulum arm" that oscillates left↔right

import 'dart:math' as math;
import 'package:flutter/material.dart';

class PendulumAnimation extends StatefulWidget {
  /// Size of the rendered widget (square).
  final double size;

  /// Stroke colour — defaults to dark for white backgrounds.
  final Color color;

  const PendulumAnimation({
    Key? key,
    this.size  = 80,
    this.color = const Color(0xFF1A1A1A),
  }) : super(key: key);

  @override
  State<PendulumAnimation> createState() => _PendulumAnimationState();
}

class _PendulumAnimationState extends State<PendulumAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  // Pendulum swings with an easeInOut feel — we use a sine curve
  // over a full 2-second period so it feels natural.
  late final Animation<double> _swing;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _swing = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _swing,
      builder: (_, __) => CustomPaint(
        size: Size(widget.size, widget.size),
        painter: _PendulumPainter(
          swingFraction: _swing.value,
          color:         widget.color,
        ),
      ),
    );
  }
}

// ─── Painter ──────────────────────────────────────────────────────────────────

class _PendulumPainter extends CustomPainter {
  /// 0.0 = full left, 1.0 = full right
  final double swingFraction;
  final Color  color;

  const _PendulumPainter({
    required this.swingFraction,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width  / 2;
    final cy = size.height / 2;
    final r  = size.width  / 2 - 2.5;

    final basePaint = Paint()
      ..color       = color
      ..style       = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap   = StrokeCap.round;

    // ── 1. Outer circle ───────────────────────────────────────────────────
    canvas.drawCircle(Offset(cx, cy), r, basePaint);

    // ── 2. Vertical stem (top → bottom, clipped to circle radius) ─────────
    canvas.drawLine(
      Offset(cx, cy - r * 0.88),
      Offset(cx, cy + r * 0.88),
      basePaint,
    );

    // ── 3. Horizontal crosshair tick at centre ────────────────────────────
    canvas.drawLine(
      Offset(cx - r * 0.30, cy),
      Offset(cx + r * 0.30, cy),
      basePaint,
    );

    // ── 4. Centre filled dot ──────────────────────────────────────────────
    canvas.drawCircle(
      Offset(cx, cy),
      r * 0.10,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );

    // ── 5. Pendulum arm ───────────────────────────────────────────────────
    // Max swing angle from vertical = 28°
    const maxAngle = 28.0 * math.pi / 180.0;
    // swingFraction 0→1 maps to -maxAngle → +maxAngle
    final angle = -maxAngle + swingFraction * 2 * maxAngle;

    // Arm length = inner radius (a bit shorter than r)
    final armLen = r * 0.72;
    final armEnd = Offset(
      cx + armLen * math.sin(angle),
      cy - armLen * math.cos(angle),   // subtract because y-axis is downward
    );

    // Glowing arm (thicker, semi-transparent)
    canvas.drawLine(
      Offset(cx, cy),
      armEnd,
      Paint()
        ..color       = color.withOpacity(0.18)
        ..strokeWidth = 5.0
        ..strokeCap   = StrokeCap.round
        ..maskFilter  = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Arm itself
    canvas.drawLine(
      Offset(cx, cy),
      armEnd,
      basePaint..strokeWidth = 1.8,
    );

    // Bob at the end of the arm
    canvas.drawCircle(
      armEnd,
      r * 0.09,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
    // Bob ring
    canvas.drawCircle(
      armEnd,
      r * 0.09,
      Paint()
        ..color       = color.withOpacity(0.30)
        ..style       = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..maskFilter  = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }

  @override
  bool shouldRepaint(covariant _PendulumPainter old) =>
      old.swingFraction != swingFraction || old.color != color;
}