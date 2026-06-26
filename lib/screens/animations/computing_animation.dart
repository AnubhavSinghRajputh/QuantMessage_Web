import 'dart:async';
import 'package:flutter/material.dart';
import '../premium_effects.dart';

class ComputingAnimation extends StatefulWidget {
  const ComputingAnimation({Key? key}) : super(key: key);

  @override
  State<ComputingAnimation> createState() => _ComputingAnimationState();
}

class _ComputingAnimationState extends State<ComputingAnimation>
    with TickerProviderStateMixin {

  late AnimationController _auraController;

  final List<String> _targetWords = [
    "#People",
    "#Coders",
    "#Teams",
    "#Hustlers",
    "#Students",
  ];

  String _currentWord = "";
  int _wordIndex = 0;

  final List<String> _statuses = [
    "synthesising",
    "analysing",
    "reviewing",
    "sending",
    "receiving",
    "managing",
  ];
  int _statusIndex = 0;
  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    _auraController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _startTypingCycle();
    _startStatusRotation();
  }

  void _startTypingCycle() async {
    while (mounted) {
      String target = _targetWords[_wordIndex];
      for (int i = 0; i <= target.length; i++) {
        if (!mounted) return;
        setState(() => _currentWord = target.substring(0, i));
        await Future.delayed(const Duration(milliseconds: 100));
      }
      await Future.delayed(const Duration(milliseconds: 1500));
      for (int i = target.length; i >= 0; i--) {
        if (!mounted) return;
        setState(() => _currentWord = target.substring(0, i));
        await Future.delayed(const Duration(milliseconds: 50));
      }
      setState(() => _wordIndex = (_wordIndex + 1) % _targetWords.length);
    }
  }

  void _startStatusRotation() {
    _statusTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;
      setState(() => _statusIndex = (_statusIndex + 1) % _statuses.length);
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _auraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use the available width, capped at 650 for large screens
        final double containerWidth = constraints.maxWidth < 650
            ? constraints.maxWidth
            : 650;

        // Scale factor: 1.0 at 650px wide, scales down for smaller screens
        final double scale = (containerWidth / 650).clamp(0.35, 1.0);

        // Responsive values derived from scale
        final double fontSize = 64 * scale;
        final double statusFontSize = 15 * scale;
        final double containerHeight = 400 * scale;
        final double borderRadius = 24 * scale;
        final double pillRadius = 30 * scale;
        final double pillPaddingH = 20 * scale;
        final double pillPaddingV = 10 * scale;
        final double gapBetweenPillAndText = 50 * scale;
        final double cursorHeight = 55 * scale;
        final double dotSize = 6 * scale;
        final double dotGap = 12 * scale;

        // On very small screens, stack the label and typed word vertically
        final bool isNarrow = containerWidth < 380;

        return Center(
          child: Container(
            width: containerWidth,
            height: isNarrow ? containerHeight * 1.3 : containerHeight,
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F12),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16 * scale),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Status pill
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CirculatingAura(
                          controller: _auraController,
                          borderRadius: pillRadius,
                          glowColor: Colors.greenAccent.withOpacity(0.3),
                          accentColor: Colors.greenAccent,
                          padding: const EdgeInsets.all(2),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: pillPaddingH,
                              vertical: pillPaddingV,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A0A0C),
                              borderRadius: BorderRadius.circular(pillRadius),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: dotSize,
                                  height: dotSize,
                                  decoration: BoxDecoration(
                                    color: Colors.greenAccent,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.greenAccent,
                                        blurRadius: 4 * scale,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: dotGap),
                                Text(
                                  "${_statuses[_statusIndex]}...",
                                  style: TextStyle(
                                    color: Colors.greenAccent,
                                    fontSize: statusFontSize,
                                    fontFamily: 'Inter',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: gapBetweenPillAndText),

                    // Text section — stacks vertically on very narrow screens
                    isNarrow
                        ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Built for >",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                            letterSpacing: -2.0,
                          ),
                        ),
                        SizedBox(height: 8 * scale),
                        _buildTypedWord(fontSize, scale, cursorHeight),
                      ],
                    )
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: Text(
                            "Built for > ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: fontSize,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Inter',
                              letterSpacing: -2.0,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        _buildTypedWord(fontSize, scale, cursorHeight),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypedWord(double fontSize, double scale, double cursorHeight) {
    // Approx char width scales with font size
    final double charWidth = fontSize * 0.5;

    return SizedBox(
      // Reserve enough space for the longest word + cursor
      width: _targetWords
          .map((w) => w.length * charWidth)
          .reduce((a, b) => a > b ? a : b) +
          8 * scale,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          Text(
            _currentWord,
            style: TextStyle(
              color: const Color(0xFFB87333),
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              fontFamily: 'Inter',
              letterSpacing: -2.0,
            ),
          ),
          Positioned(
            left: _currentWord.length * charWidth,
            child: _buildBlinkingCursor(scale, cursorHeight),
          ),
        ],
      ),
    );
  }

  Widget _buildBlinkingCursor(double scale, double cursorHeight) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 1.0, end: 0.0),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 3 * scale,
            height: cursorHeight,
            color: Colors.white.withOpacity(0.8),
          ),
        );
      },
    );
  }
}