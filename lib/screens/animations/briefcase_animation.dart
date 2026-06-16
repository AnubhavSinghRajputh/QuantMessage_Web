// lib/screens/animations/briefcase_animations.dart

import 'dart:math' as math;

import 'package:flutter/material.dart';


class BriefcaseAnimation extends StatefulWidget {
  final double size;
  final Duration duration;
  final Color  color;

  const BriefcaseAnimation({
    Key? key,
    this.size     = 200,
    this.duration = const Duration(seconds: 3),
    this.color    = Colors.white,
  }) : super(key: key);

  @override
  State<BriefcaseAnimation> createState() => _BriefcaseAnimationState();
}

class _BriefcaseAnimationState extends State<BriefcaseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double>   _lidAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);


    _lidAnimation = Tween<double>(begin: 0.0, end: -math.pi / 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _lidAnimation,
      builder: (context, child) {
        return CustomPaint(
          // Compact aspect ratio — keeps the briefcase visually small
          size: Size(widget.size, widget.size * 0.65),
          painter: _BriefcasePainter(
            lidAngle: _lidAnimation.value,
            color:    widget.color,
          ),
        );
      },
    );
  }
}

class _BriefcasePainter extends CustomPainter {
  final double lidAngle;
  final Color  color;

  _BriefcasePainter({required this.lidAngle, required this.color});

  @override
  void paint(Canvas canvas, Size size) {

    final Paint outlinePaint = Paint()
      ..color       = color
      ..style       = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeJoin  = StrokeJoin.round
      ..strokeCap   = StrokeCap.round;

    final Paint toolPaint = Paint()
      ..color       = color
      ..style       = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeJoin  = StrokeJoin.round
      ..strokeCap   = StrokeCap.round;

    final Paint bodyFill = Paint()
      ..color = color.withOpacity(0.04)
      ..style = PaintingStyle.fill;

    final Paint lidFill = Paint()
      ..color = color.withOpacity(0.07)
      ..style = PaintingStyle.fill;


    final double width     = size.width;
    final double height    = size.height;
    final double bodyTop   = height * 0.45;
    final double bodyHeight = height * 0.50;
    final double lidHeight = height * 0.40;

    _drawTool(
      canvas:  canvas,
      paint:   toolPaint,
      width:   width,
      height:  height,
      xFrac:   0.30,
      shaftTopFrac: bodyTop - lidHeight * 0.30,
      shaftBotFrac: bodyTop + bodyHeight * 0.45,
      headTopFrac:  bodyTop - lidHeight * 0.30,
      headSize:     width * 0.04,
      kind: _ToolKind.ruler,
    );

    _drawTool(
      canvas:  canvas,
      paint:   toolPaint,
      width:   width,
      height:  height,
      xFrac:   0.50,
      shaftTopFrac: bodyTop - lidHeight * 0.45,       // tallest (sticks up most)
      shaftBotFrac: bodyTop + bodyHeight * 0.45,
      headTopFrac:  bodyTop - lidHeight * 0.45,
      headSize:     width * 0.05,
      kind: _ToolKind.magnifier,
    );

    _drawTool(
      canvas:  canvas,
      paint:   toolPaint,
      width:   width,
      height:  height,
      xFrac:   0.70,
      shaftTopFrac: bodyTop - lidHeight * 0.25,
      shaftBotFrac: bodyTop + bodyHeight * 0.45,
      headTopFrac:  bodyTop - lidHeight * 0.25,
      headSize:     width * 0.035,
      kind: _ToolKind.pencil,
    );

    final Rect bodyRect = Rect.fromLTWH(0, bodyTop, width, bodyHeight);
    canvas.drawRect(bodyRect, bodyFill);
    canvas.drawRect(bodyRect, outlinePaint);

    final Offset lidPivot = Offset(0, bodyTop);
    canvas.save();
    canvas.translate(lidPivot.dx, lidPivot.dy);
    canvas.rotate(lidAngle);

    final Rect lidRect = Rect.fromLTWH(0, -lidHeight, width, lidHeight);
    canvas.drawRect(lidRect, lidFill);
    canvas.drawRect(lidRect, outlinePaint);
    canvas.restore();

    final double handleWidth  = width * 0.22;
    final double handleHeight = height * 0.10;
    final Rect handleRect = Rect.fromLTWH(
      (width - handleWidth) / 2,
      bodyTop - lidHeight - handleHeight * 0.3,
      handleWidth,
      handleHeight,
    );
    canvas.drawRect(handleRect, outlinePaint);

    final double latchW = width * 0.08;
    final double latchH = bodyHeight * 0.14;
    final Rect latchRect = Rect.fromLTWH(
      (width - latchW) / 2,
      bodyTop + bodyHeight * 0.05,
      latchW,
      latchH,
    );
    canvas.drawRect(latchRect, outlinePaint);
  }

  void _drawTool({
    required Canvas canvas,
    required Paint  paint,
    required double width,
    required double height,
    required double xFrac,
    required double shaftTopFrac,
    required double shaftBotFrac,
    required double headTopFrac,
    required double headSize,
    required _ToolKind kind,
  }) {
    final double x       = width  * xFrac;
    final double shaftTop = height * shaftTopFrac;
    final double shaftBot = height * shaftBotFrac;
    final double headTop  = height * headTopFrac;

    // Vertical shaft — short, stays within the briefcase area
    canvas.drawLine(
      Offset(x, shaftTop),
      Offset(x, shaftBot),
      paint,
    );

    // Tool head — depends on kind
    switch (kind) {
      case _ToolKind.ruler:
      // Horizontal "T" cap on top
        canvas.drawLine(
          Offset(x - headSize, headTop),
          Offset(x + headSize, headTop),
          paint,
        );
        // Two small tick marks
        canvas.drawLine(
          Offset(x - headSize * 0.7, headTop + headSize * 0.6),
          Offset(x + headSize * 0.4, headTop + headSize * 0.6),
          paint,
        );
        break;

      case _ToolKind.magnifier:
      // Open circle for the magnifier lens
        final double radius = headSize * 0.9;
        canvas.drawCircle(Offset(x, headTop + radius), radius, paint);
        // Small diagonal handle (just a tick)
        canvas.drawLine(
          Offset(x + radius * 0.7, headTop + radius * 1.7),
          Offset(x + radius * 1.1, headTop + radius * 2.1),
          paint,
        );
        break;

      case _ToolKind.pencil:
      // Small rectangle "eraser" on top
        final double eraserW = headSize * 0.5;
        final double eraserH = headSize * 0.5;
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(x, headTop + eraserH * 0.5),
            width:  eraserW,
            height: eraserH,
          ),
          paint,
        );
        // Tip triangle just below the eraser
        final double tipTop = headTop + eraserH;
        final double tipBot = headTop + eraserH * 2.2;
        final Path tip = Path()
          ..moveTo(x - eraserW * 0.4, tipTop)
          ..lineTo(x + eraserW * 0.4, tipTop)
          ..lineTo(x,                  tipBot)
          ..close();
        canvas.drawPath(tip, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _BriefcasePainter oldDelegate) =>
      oldDelegate.lidAngle != lidAngle || oldDelegate.color != color;
}

enum _ToolKind { ruler, magnifier, pencil }
