// features_web_animations.dart

import 'dart:math' as math;

import 'package:flutter/material.dart';

class FeaturesWebAnimation extends StatefulWidget {
  final double size;
  final Duration duration;
  final bool useDarkTheme;

  const FeaturesWebAnimation({
    Key? key,
    this.size = 400,
    this.duration = const Duration(seconds: 10),
    this.useDarkTheme = false,
  }) : super(key: key);

  @override
  State<FeaturesWebAnimation> createState() => _FeaturesWebAnimationState();
}

class _FeaturesWebAnimationState extends State<FeaturesWebAnimation>
    with TickerProviderStateMixin {
  // Drives orbital rotation of categories/sub-nodes.
  late AnimationController _rotationController;
  // Drives the slow "breathing" camera zoom in/out, independent of rotation
  // so the two motions don't feel mechanically locked together.
  late AnimationController _zoomController;
  // Drives per-node twinkle/glow pulsing for a more alive, organic feel.
  late AnimationController _twinkleController;

  final List<String> categories = [
    'Design',
    'Content creation',
    'Business strategy',
    'Software development',
  ];

  final Map<String, List<String>> subCategories = {
    'Design': ['Responsive', 'Visuals', 'Components', 'Prototypes', 'Flows'],
    'Content creation': [
      'Translation',
      'Documentation',
      'Education',
      'Marketing',
      'Editing',
    ],
    'Business strategy': [
      'Modeling',
      'Growth',
      'Campaigns',
      'Competition',
      'Markets',
    ],
    'Software development': [
      'Debugging',
      'Reviews',
      'Testing',
      'Documentation',
      'Optimization',
    ],
  };

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();

    // Slower than the rotation, so the "camera" drifts in and out across
    // multiple rotation cycles rather than syncing up with them.
    _zoomController = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: (widget.duration.inMilliseconds * 1.8).round(),
      ),
    )..repeat(reverse: true);

    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _zoomController.dispose();
    _twinkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
        [_rotationController, _zoomController, _twinkleController],
      ),
      builder: (_, __) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: _FeaturesPainter(
            progress: _rotationController.value,
            zoom: _zoomController.value,
            twinkle: _twinkleController.value,
            categories: categories,
            subCategories: subCategories,
            useDarkTheme: widget.useDarkTheme,
          ),
        );
      },
    );
  }
}

class _FeaturesPainter extends CustomPainter {
  final double progress;
  final double zoom;
  final double twinkle;
  final List<String> categories;
  final Map<String, List<String>> subCategories;
  final bool useDarkTheme;

  _FeaturesPainter({
    required this.progress,
    required this.zoom,
    required this.twinkle,
    required this.categories,
    required this.subCategories,
    this.useDarkTheme = false,
  });

  /// Maps a raw value in [0,1] through an ease-in-out curve, used to make
  /// the breathing zoom feel smooth rather than linear back-and-forth.
  double _easeInOut(double t) => 0.5 - 0.5 * math.cos(t * math.pi);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final center = Offset(cx, cy);

    if (useDarkTheme) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = Colors.black,
      );
    }

    // Overall "camera" zoom: breathes between ~0.92x and ~1.08x scale,
    // eased so it accelerates/decelerates smoothly like a real camera
    // drifting rather than linearly oscillating.
    final double zoomScale = 0.92 + _easeInOut(zoom) * 0.16;

    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(zoomScale);
    canvas.translate(-cx, -cy);

    final TextPainter textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // ---- Soft ambient background glow behind the whole web, to add depth ----
    final Paint ambientGlow = Paint()
      ..shader = RadialGradient(
        colors: [
          (useDarkTheme ? Colors.greenAccent : Colors.green)
              .withOpacity(0.10 + 0.05 * _easeInOut(zoom)),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width * 0.55))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);
    canvas.drawCircle(center, size.width * 0.55, ambientGlow);

    // ---- Center node glow + label ----
    final double centerPulse = 0.85 + 0.15 * math.sin(twinkle * 2 * math.pi);
    final Paint centerGlowPaint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.35 * centerPulse)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);
    canvas.drawCircle(center, 26 * centerPulse, centerGlowPaint);

    final Paint centerDotPaint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.9);
    canvas.drawCircle(center, 4.5, centerDotPaint);

    textPainter.text = TextSpan(
      text: 'QuantMessage',
      style: TextStyle(
        color: Colors.greenAccent.withOpacity(0.95),
        fontSize: 20,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(
            color: Colors.greenAccent.withOpacity(0.6 * centerPulse),
            blurRadius: 12,
          ),
        ],
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(cx - textPainter.width / 2, cy - textPainter.height / 2 - 22),
    );

    final double radius = size.width * 0.3;

    // Collect category nodes first so we can sort by simulated depth and
    // paint back-to-front, like a real 3D scene (far things behind near ones).
    final List<_NodeRenderData> categoryNodes = [];

    for (int i = 0; i < categories.length; i++) {
      final double angle =
          (i / categories.length) * 2 * math.pi + progress * 2 * math.pi;

      // Simulated depth: cos(angle) maps to roughly [-1, 1]. We treat +1 as
      // "closest to camera" (bigger, brighter) and -1 as "furthest" (smaller,
      // dimmer) — this is what actually sells a 3D/zoom illusion on a 2D canvas.
      final double depth = math.cos(angle);
      final double depthScale = 0.78 + ((depth + 1) / 2) * 0.5; // 0.78–1.28
      final double depthOpacity = 0.55 + ((depth + 1) / 2) * 0.45; // 0.55–1.0

      // Vertical offset shrinks slightly with depth too, like an ellipse
      // orbit viewed at a slight tilt rather than a flat circle.
      final Offset catPos = Offset(
        cx + radius * math.cos(angle),
        cy + radius * math.sin(angle) * 0.92,
      );

      categoryNodes.add(_NodeRenderData(
        label: categories[i],
        position: catPos,
        depthScale: depthScale,
        depthOpacity: depthOpacity,
        phase: i.toDouble(),
      ));
    }

    categoryNodes.sort((a, b) => a.depthScale.compareTo(b.depthScale));

    for (final node in categoryNodes) {
      _drawCurvedConnection(
        canvas: canvas,
        from: center,
        to: node.position,
        opacity: node.depthOpacity,
        strokeWidth: 1.2 * node.depthScale,
        curveBend: 18,
      );
    }

    for (final node in categoryNodes) {
      _paintCategoryNode(canvas, textPainter, node);

      final subs = subCategories[node.label]!;
      final double subRadius = 68 * node.depthScale;

      final List<_NodeRenderData> subNodes = [];
      for (int j = 0; j < subs.length; j++) {
        final double subAngle =
            (j / subs.length) * 2 * math.pi - progress * 2 * math.pi;

        final double subDepth = math.cos(subAngle + node.phase);
        final double subDepthScale =
            node.depthScale * (0.82 + ((subDepth + 1) / 2) * 0.32);
        final double subDepthOpacity =
            node.depthOpacity * (0.5 + ((subDepth + 1) / 2) * 0.5);

        final Offset subPos = Offset(
          node.position.dx + subRadius * math.cos(subAngle),
          node.position.dy + subRadius * math.sin(subAngle) * 0.9,
        );

        subNodes.add(_NodeRenderData(
          label: subs[j],
          position: subPos,
          depthScale: subDepthScale,
          depthOpacity: subDepthOpacity,
          phase: j.toDouble() + node.phase,
        ));
      }

      subNodes.sort((a, b) => a.depthScale.compareTo(b.depthScale));

      for (final sub in subNodes) {
        _drawCurvedConnection(
          canvas: canvas,
          from: node.position,
          to: sub.position,
          opacity: sub.depthOpacity * 0.85,
          strokeWidth: 0.9 * sub.depthScale,
          curveBend: 9,
        );
      }

      for (final sub in subNodes) {
        _paintSubNode(canvas, textPainter, sub);
      }
    }

    canvas.restore();
  }

  /// Draws a gently curved (quadratic bezier) connection rather than a
  /// straight line, plus a soft glow stroke beneath it, so the web reads
  /// as organic strands rather than a rigid wireframe.
  void _drawCurvedConnection({
    required Canvas canvas,
    required Offset from,
    required Offset to,
    required double opacity,
    required double strokeWidth,
    required double curveBend,
  }) {
    final Offset mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
    final Offset dir = (to - from);
    final double len = dir.distance;
    if (len == 0) return;
    final Offset normal = Offset(-dir.dy, dir.dx) / len;
    final Offset control = mid + normal * curveBend;

    final Path path = Path()
      ..moveTo(from.dx, from.dy)
      ..quadraticBezierTo(control.dx, control.dy, to.dx, to.dy);

    final Color lineColor = useDarkTheme
        ? Colors.white.withOpacity(0.30 * opacity)
        : Colors.white.withOpacity(0.85 * opacity);

    // Faint glow pass beneath the crisp line for a soft, lit-strand look.
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor.withOpacity(lineColor.opacity * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth * 2.4
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth,
    );
  }

  void _paintCategoryNode(
      Canvas canvas,
      TextPainter textPainter,
      _NodeRenderData node,
      ) {
    final double pulse =
        0.8 + 0.2 * math.sin(twinkle * 2 * math.pi + node.phase * 1.7);

    // Glow halo behind the node dot, scaled/faded by simulated depth.
    final Paint glowPaint = Paint()
      ..color = Colors.greenAccent.withOpacity(0.30 * node.depthOpacity * pulse)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 9 * node.depthScale);
    canvas.drawCircle(node.position, 16 * node.depthScale * pulse, glowPaint);

    final Paint dotPaint = Paint()
      ..color = (useDarkTheme ? Colors.greenAccent : Colors.green)
          .withOpacity(0.85 * node.depthOpacity);
    canvas.drawCircle(node.position, 4.0 * node.depthScale, dotPaint);

    textPainter.text = TextSpan(
      text: node.label,
      style: TextStyle(
        color: (useDarkTheme ? Colors.white : Colors.greenAccent)
            .withOpacity(node.depthOpacity),
        fontSize: 16 * node.depthScale,
        fontWeight: FontWeight.w600,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.35 * node.depthOpacity),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      node.position -
          Offset(textPainter.width / 2, textPainter.height / 2 + 14 * node.depthScale),
    );
  }

  void _paintSubNode(
      Canvas canvas,
      TextPainter textPainter,
      _NodeRenderData node,
      ) {
    final double pulse =
        0.75 + 0.25 * math.sin(twinkle * 2 * math.pi + node.phase * 2.3);

    final Paint glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.18 * node.depthOpacity * pulse)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 5 * node.depthScale);
    canvas.drawCircle(node.position, 8 * node.depthScale * pulse, glowPaint);

    final Paint dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.7 * node.depthOpacity);
    canvas.drawCircle(node.position, 2.2 * node.depthScale, dotPaint);

    textPainter.text = TextSpan(
      text: node.label,
      style: TextStyle(
        color: Colors.white.withOpacity(0.85 * node.depthOpacity),
        fontSize: 12 * node.depthScale,
        shadows: [
          Shadow(
            color: Colors.black.withOpacity(0.3 * node.depthOpacity),
            blurRadius: 3,
          ),
        ],
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      node.position -
          Offset(textPainter.width / 2, textPainter.height / 2 + 9 * node.depthScale),
    );
  }

  @override
  bool shouldRepaint(covariant _FeaturesPainter oldDelegate) =>
      oldDelegate.progress != progress ||
          oldDelegate.zoom != zoom ||
          oldDelegate.twinkle != twinkle;
}


class _NodeRenderData {
  final String label;
  final Offset position;
  final double depthScale;
  final double depthOpacity;
  final double phase;

  _NodeRenderData({
    required this.label,
    required this.position,
    required this.depthScale,
    required this.depthOpacity,
    required this.phase,
  });
}