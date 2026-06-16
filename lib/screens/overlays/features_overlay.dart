// lib/screens/overlays/features_overlay.dart

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:math' as math;

import '../animations/features_web_animations.dart';
import '../animations/briefcase_animation.dart';
import '../premium_effects.dart';

/// Descriptive left panel + [FeaturesWebAnimation] on the right.
/// Black background, white typography — scrolls as part of [HomeScreen].
///
/// - Dynamic theme via [PremiumBackgroundStack] (animated dots + fluid mesh)
/// - Cascading fade-in for left info blocks tied to scroll position
/// - Hover effect on download buttons (white → black with white text)
/// - Left-accent + bottom border on every description block
class FeaturesOverlay extends StatefulWidget {
  final AnimationController? bgController;

  const FeaturesOverlay({Key? key, this.bgController}) : super(key: key);

  @override
  State<FeaturesOverlay> createState() => _FeaturesOverlayState();
}

class _FeaturesOverlayState extends State<FeaturesOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _heroTypingController;

  late final AnimationController _info1FadeController;
  late final AnimationController _info2FadeController;
  late final AnimationController _info3FadeController;
  late final Animation<double>   _info1Fade;
  late final Animation<double>   _info2Fade;
  late final Animation<double>   _info3Fade;
  late final Animation<Offset>   _info1Slide;
  late final Animation<Offset>   _info2Slide;
  late final Animation<Offset>   _info3Slide;

  late final AnimationController _panelFadeController;
  late final Animation<double>   _panelFade;

  bool _info1Revealed = false;
  bool _info2Revealed = false;
  bool _info3Revealed = false;

  ScrollPosition? _attachedScrollPosition;
  VoidCallback?   _scrollListener;

  @override
  void initState() {
    super.initState();

    _panelFadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _panelFade = CurvedAnimation(
      parent: _panelFadeController,
      curve: Curves.easeOut,
    );

    _heroTypingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _info1FadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _info2FadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _info3FadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _info1Fade = CurvedAnimation(parent: _info1FadeController, curve: Curves.easeOut);
    _info2Fade = CurvedAnimation(parent: _info2FadeController, curve: Curves.easeOut);
    _info3Fade = CurvedAnimation(parent: _info3FadeController, curve: Curves.easeOut);

    _info1Slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _info1FadeController, curve: Curves.easeOutCubic));
    _info2Slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _info2FadeController, curve: Curves.easeOutCubic));
    _info3Slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _info3FadeController, curve: Curves.easeOutCubic));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _panelFadeController.forward();
      _heroTypingController.forward();
      _attachScrollListener();
    });
  }

  void _attachScrollListener() {
    final scrollable = Scrollable.maybeOf(context);
    if (scrollable == null) return;

    final controller = scrollable.position;
    _attachedScrollPosition = controller;

    void onScroll() {
      if (!mounted || !controller.hasContentDimensions) return;

      final renderBox = context.findRenderObject();
      if (renderBox == null) return;

      final viewport = RenderAbstractViewport.maybeOf(renderBox);
      if (viewport == null) return;

      final offsetToReveal = viewport.getOffsetToReveal(renderBox, 0.0).offset;
      final scrollOffset   = controller.pixels;
      final viewportHeight = controller.viewportDimension;

      final panelTop = offsetToReveal - scrollOffset;

      if (!_info1Revealed && panelTop < viewportHeight * 0.75) {
        setState(() => _info1Revealed = true);
        _info1FadeController.forward();
      }
      if (!_info2Revealed && panelTop < viewportHeight * 0.85) {
        setState(() => _info2Revealed = true);
        _info2FadeController.forward();
      }
      if (!_info3Revealed && panelTop < viewportHeight * 0.95) {
        setState(() => _info3Revealed = true);
        _info3FadeController.forward();
      }
    }

    _scrollListener = onScroll;
    controller.addListener(onScroll);
    onScroll();
  }

  @override
  void dispose() {
    if (_attachedScrollPosition != null && _scrollListener != null) {
      _attachedScrollPosition!.removeListener(_scrollListener!);
    }

    _panelFadeController.dispose();
    _heroTypingController.dispose();
    _info1FadeController.dispose();
    _info2FadeController.dispose();
    _info3FadeController.dispose();
    super.dispose();
  }

  Widget _buildInfoBlock({
    required String title,
    required String description,
    required Animation<double>  fade,
    required Animation<Offset>  slide,
    bool showBorder = true,
  }) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: Container(
          width: double.infinity,
          decoration: showBorder
              ? BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.18),
                width: 1.0,
              ),
              left: BorderSide(
                color: Colors.white.withOpacity(0.35),
                width: 2.0,
              ),
            ),
          )
              : null,
          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily:    '__copernicus_669e4a',
                  color:         Colors.white,
                  fontSize:      20,
                  fontWeight:    FontWeight.bold,
                  height:        1.3,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontFamily:  'Inter',
                  color:       Colors.white.withOpacity(0.72),
                  fontSize:    14,
                  fontWeight:  FontWeight.w300,
                  height:      1.55,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroBlock(double maxWidth, bool isMobile) {
    final double briefcaseSize = isMobile
        ? math.min(maxWidth * 0.5, 180.0)
        : math.min(maxWidth * 0.35, 220.0);

    final double titleSize      = isMobile ? 34 : 56;
    final double subtitleSize   = isMobile ? 15 : 18;
    final double buttonFontSize = isMobile ? 13 : 14;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 0,
        vertical:   40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          BriefcaseAnimation(
            size:     briefcaseSize,
            duration: const Duration(seconds: 3),
            color:    Colors.white,
          ),
          const SizedBox(height: 24),

          TypingTextAnimation(
            controller:    _heroTypingController,
            fullText:      '< All In One Messaging Powered By A.I >',
            highlightPart: '< All In One Messaging Powered By A.I >',
            style: TextStyle(
              fontFamily:    '__copernicus_669e4a',
              color:         Colors.white,
              fontSize:      titleSize,
              fontWeight:    FontWeight.w800,
              height:        1.1,
              letterSpacing: -1.0,
            ),
          ),

          const SizedBox(height: 20),

          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: TextStyle(
                fontFamily: 'Inter',
                color:      Colors.white.withOpacity(0.85),
                fontSize:   subtitleSize,
                fontWeight: FontWeight.w400,
                height:     1.5,
              ),
              children: const [
                TextSpan(text: 'Use '),
                TextSpan(
                  text: 'QuantMessage',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    decorationThickness: 1.5,
                    decorationColor: Colors.white,
                  ),
                ),
                TextSpan(text: ' in the Android to hand off tasks.'),
              ],
            ),
          ),

          const SizedBox(height: 32),

          _buildDownloadRow(isMobile, buttonFontSize),
        ],
      ),
    );
  }

  Widget _buildDownloadRow(bool isMobile, double fontSize) {
    final buttons = <Widget>[
      _buildDownloadButton('macOS',           fontSize),
      _buildDownloadButton('Windows',         fontSize),
      _buildDownloadButton('Android', fontSize),
    ];

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < buttons.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            buttons[i],
          ],
        ],
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Download the desktop app:',
          style: TextStyle(
            color:      Colors.white.withOpacity(0.7),
            fontSize:   fontSize,
            fontWeight: FontWeight.w400,
          ),
        ),
        for (int i = 0; i < buttons.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          buttons[i],
        ],
      ],
    );
  }

  Widget _buildDownloadButton(String label, double fontSize) {
    return _HoverSwapButton(
      label:    label,
      fontSize: fontSize,
      onTap:    () => debugPrint('Download tapped: $label'),
    );
  }

  Widget _buildAnimationBox({required double height}) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF050505),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      clipBehavior: Clip.antiAlias,
      child: const Center(
        child: FeaturesWebAnimation(
          size:         380,
          useDarkTheme: true,
        ),
      ),
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildInfoBlock(
          title:       'Break down problems together',
          description: 'QuantMessage builds on your ideas, expands on your logic, '
              'and simplifies complexity one step at a time.',
          fade:        _info1Fade,
          slide:       _info1Slide,
        ),
        _buildInfoBlock(
          title:       'Tackle your toughest work',
          description: 'QuantMessage provides expert-level collaboration on the things '
              'you need to get done—from coding a product to critical data analysis.',
          fade:        _info2Fade,
          slide:       _info2Slide,
        ),
        _buildInfoBlock(
          title:       'Explore what\'s next',
          description: 'Like an expert in your pocket, collaborating with QuantMessage expands '
              'what you can build on your own or with teams.',
          fade:        _info3Fade,
          slide:       _info3Slide,
          showBorder:  false,
        ),
      ],
    );
  }

  Widget _buildBackground() {
    if (widget.bgController == null) {
      return Container(color: Colors.black);
    }

    return PremiumBackgroundStack(
      bgController:   widget.bgController!,
      showMovingDots: true,
      showFluidMesh:  true,
      baseColor:      const Color(0xFF050507),
      child:          const SizedBox.expand(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile    = screenWidth < 900;
    final maxWidth    = math.min(screenWidth - 32, 1352.0);

    return Container(
      width: double.infinity,
      color: Colors.black,
      child: Stack(
        children: [
          Positioned.fill(child: _buildBackground()),

          FadeTransition(
            opacity: _panelFade,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: _buildHeroBlock(maxWidth, isMobile),
                      ),

                      const SizedBox(height: 60),

                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: isMobile
                            ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildLeftColumn(),
                            const SizedBox(height: 32),
                            _buildAnimationBox(height: 400),
                          ],
                        )
                            : Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 45, child: _buildLeftColumn()),
                            const SizedBox(width: 40),
                            Expanded(flex: 55, child: _buildAnimationBox(height: 500)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _HoverSwapButton extends StatefulWidget {
  final String       label;
  final double       fontSize;
  final VoidCallback onTap;

  const _HoverSwapButton({
    required this.label,
    required this.fontSize,
    required this.onTap,
  });

  @override
  State<_HoverSwapButton> createState() => _HoverSwapButtonState();
}

class _HoverSwapButtonState extends State<_HoverSwapButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit:  (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color:        _hovered ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: _hovered ? Colors.white : Colors.white,
            width: 1.0,
          ),
          boxShadow: _hovered
              ? [
            BoxShadow(
              color:       Colors.white.withOpacity(0.18),
              blurRadius:  18,
              spreadRadius: 0,
              offset:      Offset.zero,
            ),
          ]
              : null,
        ),
        child: Material(
          color:        Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: widget.onTap,
            splashColor: Colors.white.withOpacity(0.08),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                style: TextStyle(
                  color:         _hovered ? Colors.white : Colors.black,
                  fontSize:      widget.fontSize,
                  fontWeight:    FontWeight.w600,
                  letterSpacing: 0.2,
                ),
                child: Text(widget.label),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
