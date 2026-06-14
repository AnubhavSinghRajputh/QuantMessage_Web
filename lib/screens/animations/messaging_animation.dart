import 'dart:math' as math;
import 'package:flutter/material.dart';


// Location: lib/animations/messaging_animation.dart
//
// Usage in home_screen.dart (beside Early Access section):
//
//   Row(
//     crossAxisAlignment: CrossAxisAlignment.center,
//     children: [
//       Expanded(child: /* your Early Access column */),
//       SizedBox(width: 48),
//       SizedBox(
//         width: 340,
//         height: 480,
//         child: MessagingAnimation(),
//       ),
//     ],
//   )

class MessagingAnimation extends StatefulWidget {
  const MessagingAnimation({Key? key}) : super(key: key);

  @override
  State<MessagingAnimation> createState() => _MessagingAnimationState();
}

class _MessagingAnimationState extends State<MessagingAnimation>
    with TickerProviderStateMixin {
  // Master timeline that loops indefinitely
  late AnimationController _masterController;

  // Each "bubble" flying across the panel
  final List<_BubbleData> _bubbles = [];
  final math.Random _rng = math.Random();

  // How many bubbles we keep in the pool
  static const int _poolSize = 12;

  // Labels shown on each system node
  static const String _labelLeft = 'QM Node A';
  static const String _labelRight = 'QM Node B';

  // Accent color (matches QuantMessage purple palette)
  static const Color _accent = Color(0xFF9B8FFF);
  static const Color _accentDim = Color(0x339B8FFF);
  static const Color _panelBg = Color(0xFF0C0C18);
  static const Color _borderColor = Color(0x1AFFFFFF);
  static const Color _nodeBg = Color(0xFF13132A);
  static const Color _nodeBorder = Color(0x339B8FFF);
  static const Color _pulseColor = Color(0x269B8FFF);

  // Sample message snippets cycling through bubbles
  static const List<String> _snippets = [
    'INIT_HANDSHAKE',
    '0xA3F9…4C2B',
    'PING 0ms',
    'DATA_STREAM',
    'AUTH_TOKEN',
    'ACK #4821',
    'SYNC_BLOCK',
    'ENCRYPT_OK',
    '0xFF01…88DA',
    'ROUTE_OK',
    'QKD_PULSE',
    'LATENCY 0.3ms',
    'PKT #9912',
    'SIGNED_MSG',
    'TX_COMMIT',
    'VERIFY OK',
  ];

  int _snippetIndex = 0;

  @override
  void initState() {
    super.initState();

    _masterController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_tick)..repeat();

    // Seed the bubble pool with staggered start times
    for (int i = 0; i < _poolSize; i++) {
      _bubbles.add(_makeBubble(
        initialProgress: i / _poolSize,
      ));
    }
  }

  _BubbleData _makeBubble({double initialProgress = 0.0}) {
    final leftToRight = _rng.nextBool();
    final speed = 0.004 + _rng.nextDouble() * 0.006; // progress per tick (~60 fps)
    final yFraction = 0.2 + _rng.nextDouble() * 0.6; // vertical lane
    final snippet = _snippets[_snippetIndex % _snippets.length];
    _snippetIndex++;

    // Pick a highlight color variant
    final colorVariant = _rng.nextInt(3);

    return _BubbleData(
      progress: initialProgress,
      speed: speed,
      leftToRight: leftToRight,
      yFraction: yFraction,
      snippet: snippet,
      colorVariant: colorVariant,
    );
  }

  void _tick() {
    if (!mounted) return;
    setState(() {
      for (int i = 0; i < _bubbles.length; i++) {
        _bubbles[i].progress += _bubbles[i].speed;
        if (_bubbles[i].progress > 1.0) {
          _bubbles[i] = _makeBubble();
        }
      }
    });
  }

  @override
  void dispose() {
    _masterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;

      return Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: _panelBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _borderColor, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Subtle grid lines in background
            CustomPaint(
              size: Size(w, h),
              painter: _GridPainter(),
            ),

            // Animated bubbles
            CustomPaint(
              size: Size(w, h),
              painter: _BubblePainter(
                bubbles: _bubbles,
                width: w,
                height: h,
                accent: _accent,
              ),
            ),

            // System node — LEFT
            Positioned(
              left: 12,
              top: h / 2 - 52,
              child: _SystemNode(
                label: _labelLeft,
                icon: Icons.developer_board_rounded,
                accent: _accent,
                nodeBg: _nodeBg,
                nodeBorder: _nodeBorder,
                pulseColor: _pulseColor,
                masterController: _masterController,
              ),
            ),

            // System node — RIGHT
            Positioned(
              right: 12,
              top: h / 2 - 52,
              child: _SystemNode(
                label: _labelRight,
                icon: Icons.hub_rounded,
                accent: _accent,
                nodeBg: _nodeBg,
                nodeBorder: _nodeBorder,
                pulseColor: _pulseColor,
                masterController: _masterController,
                flipPulse: true,
              ),
            ),

            // Top label
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: Colors.white.withOpacity(0.08)),
                  ),
                  child: const Text(
                    'LIVE CHANNEL',
                    style: TextStyle(
                      color: Color(0xFF9B8FFF),
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom stats bar
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _StatsBar(masterController: _masterController),
            ),
          ],
        ),
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bubble data model
// ─────────────────────────────────────────────────────────────────────────────

class _BubbleData {
  double progress; // 0.0 → 1.0 across the panel
  final double speed;
  final bool leftToRight;
  final double yFraction;
  final String snippet;
  final int colorVariant;

  _BubbleData({
    required this.progress,
    required this.speed,
    required this.leftToRight,
    required this.yFraction,
    required this.snippet,
    required this.colorVariant,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Bubble painter
// ─────────────────────────────────────────────────────────────────────────────

class _BubblePainter extends CustomPainter {
  final List<_BubbleData> bubbles;
  final double width;
  final double height;
  final Color accent;

  static const double _nodeWidth = 76.0;
  static const double _trackPad = _nodeWidth + 16;

  _BubblePainter({
    required this.bubbles,
    required this.width,
    required this.height,
    required this.accent,
  });

  static const List<Color> _variants = [
    Color(0xFF9B8FFF), // purple
    Color(0xFF4ADE80), // green
    Color(0xFF38BDF8), // cyan
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final trackStart = _trackPad;
    final trackEnd = width - _trackPad;
    final trackWidth = trackEnd - trackStart;

    for (final b in bubbles) {
      final color = _variants[b.colorVariant % _variants.length];
      final t = b.leftToRight ? b.progress : (1.0 - b.progress);
      final x = trackStart + t * trackWidth;
      final y = height * b.yFraction;

      // Fade in/out at edges
      final edgeFade = (b.progress < 0.08)
          ? b.progress / 0.08
          : (b.progress > 0.92)
          ? (1.0 - b.progress) / 0.08
          : 1.0;

      // Trail line behind the bubble
      final trailLength = 32.0;
      final trailDx = b.leftToRight ? -trailLength : trailLength;
      final trailPaint = Paint()
        ..shader = LinearGradient(
          colors: [color.withOpacity(0), color.withOpacity(0.35 * edgeFade)],
          begin: b.leftToRight ? Alignment.centerLeft : Alignment.centerRight,
          end: b.leftToRight ? Alignment.centerRight : Alignment.centerLeft,
        ).createShader(Rect.fromLTWH(x + trailDx, y - 1, trailLength, 2))
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke;
      canvas.drawLine(Offset(x + trailDx, y), Offset(x, y), trailPaint);

      // Pill body
      final textPainter = TextPainter(
        text: TextSpan(
          text: b.snippet,
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final pillW = textPainter.width + 16;
      final pillH = 20.0;
      final pillRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x, y), width: pillW, height: pillH),
        const Radius.circular(6),
      );

      // Shadow glow
      canvas.drawRRect(
        pillRect.inflate(3),
        Paint()
          ..color = color.withOpacity(0.12 * edgeFade)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );

      // Background
      canvas.drawRRect(
        pillRect,
        Paint()
          ..color =
          Color.lerp(const Color(0xFF0C0C18), color, 0.1)!.withOpacity(edgeFade)
          ..style = PaintingStyle.fill,
      );

      // Border
      canvas.drawRRect(
        pillRect,
        Paint()
          ..color = color.withOpacity(0.45 * edgeFade)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );

      // Text
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BubblePainter oldDelegate) => true;
}

// ─────────────────────────────────────────────────────────────────────────────
// Background grid painter
// ─────────────────────────────────────────────────────────────────────────────

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.025)
      ..strokeWidth = 0.5;

    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// System node widget (left / right)
// ─────────────────────────────────────────────────────────────────────────────

class _SystemNode extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accent;
  final Color nodeBg;
  final Color nodeBorder;
  final Color pulseColor;
  final AnimationController masterController;
  final bool flipPulse;

  const _SystemNode({
    required this.label,
    required this.icon,
    required this.accent,
    required this.nodeBg,
    required this.nodeBorder,
    required this.pulseColor,
    required this.masterController,
    this.flipPulse = false,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: masterController,
      builder: (context, _) {
        // Pulsing glow ring
        final pulseT = (masterController.value + (flipPulse ? 0.5 : 0.0)) % 1.0;
        final glowOpacity = (math.sin(pulseT * math.pi * 2) * 0.5 + 0.5);

        return SizedBox(
          width: 76,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: nodeBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: nodeBorder, width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.18 * glowOpacity),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(icon, color: accent, size: 22),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.55),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 4),
              // Activity indicator dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (i) {
                  final dotT =
                      (masterController.value * 3 - i * 0.33 + (flipPulse ? 1.5 : 0)) % 1.0;
                  final dotOpacity = (math.sin(dotT * math.pi * 2) * 0.5 + 0.5);
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.3 + 0.7 * dotOpacity),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom stats bar
// ─────────────────────────────────────────────────────────────────────────────

class _StatsBar extends StatefulWidget {
  final AnimationController masterController;
  const _StatsBar({required this.masterController});

  @override
  State<_StatsBar> createState() => _StatsBarState();
}

class _StatsBarState extends State<_StatsBar> {
  int _packetCount = 0;
  double _latency = 0.3;
  int _ticker = 0;

  @override
  void initState() {
    super.initState();
    widget.masterController.addListener(_update);
  }

  void _update() {
    if (!mounted) return;
    _ticker++;
    if (_ticker % 4 == 0) {
      setState(() {
        _packetCount += 1 + math.Random().nextInt(3);
        _latency = 0.1 + math.Random().nextDouble() * 0.6;
      });
    }
  }

  @override
  void dispose() {
    widget.masterController.removeListener(_update);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: const BoxDecoration(
        color: Color(0xFF09091A),
        border: Border(
          top: BorderSide(color: Color(0x14FFFFFF), width: 1),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _Stat(label: 'PKTS', value: '$_packetCount'),
          _Stat(label: 'LAT', value: '${_latency.toStringAsFixed(1)}ms'),
          _Stat(label: 'ENC', value: 'AES-256'),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color(0xFF4ADE80),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              const Text(
                'ONLINE',
                style: TextStyle(
                  color: Color(0xFF4ADE80),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label ',
          style: TextStyle(
            color: Colors.white.withOpacity(0.3),
            fontSize: 9,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF9B8FFF),
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}