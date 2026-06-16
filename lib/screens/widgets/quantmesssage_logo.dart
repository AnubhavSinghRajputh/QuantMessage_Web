// lib/screens/widgets/quantmessage_logo.dart


import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A customizable, production-ready QuantMessage logo widget.
/// Modified with a Black & Grey color theme.
class QuantLogo extends StatelessWidget {
  final QuantLogoVariant variant;
  final double height;
  final Color? primaryColor;
  final Color? secondaryColor;
  final Color? textColor;
  final Color? backgroundColor;
  final bool showGlow;
  final bool animate;
  final double iconSpacing;
  final bool transparentBackground; 

  const QuantLogo({
    super.key,
    this.variant                = QuantLogoVariant.full,
    this.height                 = 32,
    this.primaryColor,
    this.secondaryColor,
    this.textColor,
    this.backgroundColor,
    this.showGlow               = false,
    this.animate                = false,
    this.iconSpacing            = 8,
    this.transparentBackground  = false, // ⭐ NEW
  });

  @override
  Widget build(BuildContext context) {
    final icon = QuantLogoIcon(
      size:             height,
      primaryColor:     primaryColor,
      secondaryColor:   secondaryColor,
      backgroundColor:  backgroundColor,
      showGlow:         showGlow,
      animate:          animate,
      transparentBg:    transparentBackground,
    );

    final wordmark = QuantLogoWordmark(
      fontSize: height * 0.55,
      color:    textColor,
      animate:  animate,
    );

    switch (variant) {
      case QuantLogoVariant.full:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            SizedBox(width: iconSpacing),
            wordmark,
          ],
        );

      case QuantLogoVariant.icon:
        return icon;

      case QuantLogoVariant.wordmark:
        return wordmark;

      case QuantLogoVariant.stacked:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            SizedBox(height: iconSpacing),
            wordmark,
          ],
        );
    }
  }
}

// ─── LOGO VARIANTS ───────────────────────────────────────────────────────────

enum QuantLogoVariant {
  full,
  icon,
  wordmark,
  stacked,
}

// ─── ICON MARK ───────────────────────────────────────────────────────────────

class QuantLogoIcon extends StatefulWidget {
  final double size;
  final Color? primaryColor;
  final Color? secondaryColor;
  final Color? backgroundColor;
  final bool showGlow;
  final bool animate;
  final bool transparentBg; // ⭐ NEW

  const QuantLogoIcon({
    super.key,
    this.size           = 32,
    this.primaryColor,
    this.secondaryColor,
    this.backgroundColor,
    this.showGlow       = false,
    this.animate        = false,
    this.transparentBg  = false,
  });

  @override
  State<QuantLogoIcon> createState() => _QuantLogoIconState();
}

class _QuantLogoIconState extends State<QuantLogoIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    if (widget.animate) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: CustomPaint(
            painter: _QuantIconPainter(
              primary:       widget.primaryColor   ?? const Color(0xFF1A1A1A), // Dark grey
              secondary:     widget.secondaryColor ?? const Color(0xFF4A4A4A), // Mid grey
              background:    widget.backgroundColor ?? const Color(0xFFE0E0E0), // Light grey
              showGlow:      widget.showGlow,
              animation:     _controller.value,
              transparentBg: widget.transparentBg,
            ),
          ),
        );
      },
    );
  }
}

// ─── ICON PAINTER ────────────────────────────────────────────────────────────

class _QuantIconPainter extends CustomPainter {
  final Color primary;
  final Color secondary;
  final Color background;
  final bool showGlow;
  final double animation;
  final bool transparentBg;

  _QuantIconPainter({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.showGlow,
    required this.animation,
    required this.transparentBg,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width;

    // ── Outer glow (subtle grey glow) ──────────────────────────────────────
    if (showGlow) {
      final glowPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            primary.withOpacity(0.35),
            primary.withOpacity(0.0),
          ],
        ).createShader(Rect.fromCircle(
          center: Offset(s / 2, s / 2),
          radius: s * 0.8,
        ));
      canvas.drawCircle(
        Offset(s / 2, s / 2),
        s * 0.55,
        glowPaint,
      );
    }

    // ── Background rounded square (grey gradient) ──────────────────────────
    if (!transparentBg) {
      final bgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, s, s),
        Radius.circular(s * 0.28),
      );

      final bgPaint = Paint()
        ..shader = LinearGradient(
          colors: [background, _darken(background, 0.15)],
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(0, 0, s, s));

      canvas.drawRRect(bgRect, bgPaint);

      // Subtle inner border
      final borderPaint = Paint()
        ..color       = Colors.black.withOpacity(0.12)
        ..style        = PaintingStyle.stroke
        ..strokeWidth  = 1;

      canvas.drawRRect(bgRect, borderPaint);
    }

    // ── Top-left highlight (subtle shine) ───────────────────────────────────
    if (!transparentBg) {
      final highlightPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withOpacity(0.35),
            Colors.white.withOpacity(0.0),
          ],
          begin: Alignment.topLeft,
          end:   Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(0, 0, s, s));

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, s, s * 0.5),
          Radius.circular(s * 0.28),
        ),
        highlightPaint,
      );
    }

    // ── "Q" letterform (dark grey) ──────────────────────────────────────────
    final qCenter  = Offset(s * 0.5, s * 0.5);
    final qRadius  = s * 0.27;
    final qStroke  = s * 0.085;

    final pulse = 1.0 + (math.sin(animation * 2 * math.pi) * 0.04);

    // Q ring
    final ringPaint = Paint()
      ..color       = primary
      ..style        = PaintingStyle.stroke
      ..strokeWidth  = qStroke
      ..strokeCap    = StrokeCap.round;

    canvas.drawCircle(qCenter, qRadius * pulse, ringPaint);

    // Q tail
    final tailPaint = Paint()
      ..color       = primary
      ..style        = PaintingStyle.stroke
      ..strokeWidth  = qStroke * 1.1
      ..strokeCap    = StrokeCap.round;

    final tailStart = Offset(
      qCenter.dx + qRadius * 0.55,
      qCenter.dy + qRadius * 0.55,
    );
    final tailEnd = Offset(
      qCenter.dx + qRadius * 1.15,
      qCenter.dy + qRadius * 1.15,
    );
    canvas.drawLine(tailStart, tailEnd, tailPaint);

    // ── Quantum particles (3 grey dots) ─────────────────────────────────────
    final pulseParticle = 0.7 + (math.sin(animation * 2 * math.pi + 1) * 0.3);

    // Main particles (primary color)
    final particlePaint = Paint()..color = primary;
    canvas.drawCircle(
      Offset(s * 0.78, s * 0.22),
      s * 0.04 * pulseParticle,
      particlePaint,
    );
    canvas.drawCircle(
      Offset(s * 0.22, s * 0.78),
      s * 0.04 * pulseParticle,
      particlePaint,
    );

    // Dim particle (lighter grey)
    final dimParticlePaint = Paint()..color = secondary.withOpacity(0.7);
    canvas.drawCircle(
      Offset(s * 0.85, s * 0.5),
      s * 0.025 * pulseParticle,
      dimParticlePaint,
    );
  }

  // Helper: darken a color by a percentage
  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  bool shouldRepaint(covariant _QuantIconPainter oldDelegate) {
    return oldDelegate.primary        != primary        ||
        oldDelegate.secondary      != secondary      ||
        oldDelegate.background     != background     ||
        oldDelegate.showGlow       != showGlow       ||
        oldDelegate.animation      != animation      ||
        oldDelegate.transparentBg  != transparentBg;
  }
}

// ─── WORDMARK ────────────────────────────────────────────────────────────────

class QuantLogoWordmark extends StatefulWidget {
  final double fontSize;
  final Color? color;
  final bool animate;

  const QuantLogoWordmark({
    super.key,
    this.fontSize = 18,
    this.color,
    this.animate   = false,
  });

  @override
  State<QuantLogoWordmark> createState() => _QuantLogoWordmarkState();
}

class _QuantLogoWordmarkState extends State<QuantLogoWordmark>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    if (widget.animate) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) {
            if (widget.color != null) {
              return LinearGradient(
                colors: [widget.color!, widget.color!],
              ).createShader(bounds);
            }
            // Animated dark→light→dark grey gradient
            return LinearGradient(
              begin: Alignment(-1.0 + _controller.value * 2, 0),
              end:   Alignment( 0.5 + _controller.value * 2, 0),
              colors: const [
                Color(0xFF0A0A0A), // Near black
                Color(0xFF6B6B6B), // Light grey
                Color(0xFF1A1A1A), // Dark grey
                Color(0xFF0A0A0A), // Near black
              ],
              stops: const [0.0, 0.4, 0.7, 1.0],
            ).createShader(bounds);
          },
          child: Text(
            'QuantMessage',
            style: TextStyle(
              fontSize:      widget.fontSize,
              fontWeight:    FontWeight.w800,
              letterSpacing: -0.5,
              height:        1.0,
            ),
          ),
        );
      },
    );
  }
}

// ─── PRESET LOGO VARIANTS (Black & Grey theme) ──────────────────────────────

extension QuantLogoPresets on QuantLogo {
  /// Default black/grey logo for light backgrounds
  static Widget standard({
    double height      = 32,
    bool   showGlow    = false,
    bool   animate     = false,
    QuantLogoVariant variant = QuantLogoVariant.full,
  }) {
    return QuantLogo(
      variant:        variant,
      height:         height,
      primaryColor:   const Color(0xFF1A1A1A),  // Dark grey (Q + particles)
      secondaryColor: const Color(0xFF4A4A4A),  // Mid grey (dim particle)
      backgroundColor: const Color(0xFFE0E0E0), // Light grey (icon background)
      textColor:      const Color(0xFF0A0A0A),  // Near black (text)
      showGlow:       showGlow,
      animate:        animate,
    );
  }

  /// Dark mode logo (white/grey for dark backgrounds)
  static Widget darkMode({
    double height      = 32,
    bool   showGlow    = false,
    bool   animate     = false,
    QuantLogoVariant variant = QuantLogoVariant.full,
  }) {
    return QuantLogo(
      variant:        variant,
      height:         height,
      primaryColor:   const Color(0xFFFAFAFA),  // Off-white
      secondaryColor: const Color(0xFFB0B0B0),  // Light grey
      backgroundColor: const Color(0xFF2A2A2A), // Dark grey background
      textColor:      const Color(0xFFFAFAFA),  // Off-white text
      showGlow:       showGlow,
      animate:        animate,
    );
  }

  /// Pure monochrome (no background, all dark grey)
  static Widget monochrome({
    double height      = 32,
    bool   showGlow    = false,
    Color?  color,
    QuantLogoVariant variant = QuantLogoVariant.full,
  }) {
    final c = color ?? const Color(0xFF1A1A1A);
    return QuantLogo(
      variant:               variant,
      height:                height,
      primaryColor:          c,
      secondaryColor:        c.withOpacity(0.6),
      textColor:             c,
      transparentBackground: true, // No background box
      showGlow:              showGlow,
    );
  }

  /// White monochrome (for dark backgrounds)
  static Widget whiteMonochrome({
    double height      = 32,
    bool   showGlow    = false,
    QuantLogoVariant variant = QuantLogoVariant.full,
  }) {
    return QuantLogo(
      variant:               variant,
      height:                height,
      primaryColor:          Colors.white,
      secondaryColor:        Colors.white.withOpacity(0.6),
      textColor:             Colors.white,
      transparentBackground: true,
      showGlow:              showGlow,
    );
  }

  /// Premium gradient (charcoal to silver)
  static Widget premium({
    double height      = 32,
    bool   showGlow    = false,
    bool   animate     = false,
    QuantLogoVariant variant = QuantLogoVariant.full,
  }) {
    return QuantLogo(
      variant:        variant,
      height:         height,
      primaryColor:   const Color(0xFF0A0A0A),  // Charcoal
      secondaryColor: const Color(0xFF707070),  // Silver
      backgroundColor: const Color(0xFFC0C0C0), // Silver background
      textColor:      const Color(0xFF1A1A1A),
      showGlow:       showGlow,
      animate:        animate,
    );
  }

  /// Minimalist (no background, just the icon)
  static Widget minimalist({
    double height      = 32,
    Color?  color,
    QuantLogoVariant variant = QuantLogoVariant.full,
  }) {
    return QuantLogo(
      variant:               variant,
      height:                height,
      primaryColor:          color ?? const Color(0xFF1A1A1A),
      secondaryColor:        (color ?? const Color(0xFF1A1A1A)).withOpacity(0.6),
      textColor:             color ?? const Color(0xFF1A1A1A),
      transparentBackground: true,
    );
  }
}
