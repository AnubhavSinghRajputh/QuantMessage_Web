import 'package:flutter/material.dart';

class ButtonBulge extends StatefulWidget {
  final Widget child;
  final double hoverScale;
  final double pressedScale;
  final Duration duration;

  const ButtonBulge({
    super.key,
    required this.child,
    this.hoverScale = 1.05, // taki animation slightly hover kar sake
    this.pressedScale = 0.95, // button slightly smaller ho sake jab click kiya jaye
    this.duration = const Duration(milliseconds: 200),
  });

  @override
  State<ButtonBulge> createState() => _ButtonBulgeState();
}

class _ButtonBulgeState extends State<ButtonBulge> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    double currentScale = 1.0;
    if (_isPressed) {
      currentScale = widget.pressedScale;
    } else if (_isHovered) {
      currentScale = widget.hoverScale;
    }

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(

        onTapDown: (_) => setState(() => _isPressed = true),

        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: currentScale,
          duration: widget.duration,
          curve: Curves.easeOutBack,
          child: widget.child,
        ),
      ),
    );
  }
}
