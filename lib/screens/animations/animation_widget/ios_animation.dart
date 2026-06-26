import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';

class IOSMessageLine {
  const IOSMessageLine({
    required this.type,
    this.text = '',
    this.delayBefore = const Duration(milliseconds: 300),
    this.animateTyping = true,
    this.typingSpeed = const Duration(milliseconds: 14),
    this.holdAfter = const Duration(milliseconds: 500),
    this.typingIndicatorDuration = const Duration(milliseconds: 1100),
  });

  final IOSLineType type;
  final String text;
  final Duration delayBefore;
  final bool animateTyping;
  final Duration typingSpeed;
  final Duration holdAfter;
  final Duration typingIndicatorDuration;
}

enum IOSLineType { sent, received, timestamp, readReceipt }

enum _BubbleKind { sent, received, typingDots, timestamp, readReceipt }

class _ChatEntry {
  _ChatEntry({required this.kind, this.text = ''});
  final _BubbleKind kind;
  String text;
}

class IOSAnimation extends StatefulWidget {
  const IOSAnimation({
    super.key,
    this.width = 780,
    this.height = 540,
    this.contactName = 'TaskFlow Assistant',
    this.contactSubtitle = 'AI · Always available',
    this.contactInitials = 'TF',
    this.statusBarTime = '9:41',
    this.cardColor = const Color(0xFFC9D9D2),
    this.frameColor = const Color(0xFF111113),
    this.chatBackgroundColor = const Color(0xFFFFFFFF),
    this.sentBubbleColor = const Color(0xFF0A84FF),
    this.receivedBubbleColor = const Color(0xFFE9E9EB),
    this.sentTextColor = Colors.white,
    this.receivedTextColor = const Color(0xFF1C1C1E),
    this.accentColor = const Color(0xFF0A84FF),
    this.script,
    this.loop = true,
    this.loopPause = const Duration(seconds: 2),
    this.borderRadius = 28,
    this.deviceBorderRadius = 46,
    this.autoStart = true,
  });

  final double width;
  final double height;
  final String contactName;
  final String contactSubtitle;
  final String contactInitials;
  final String statusBarTime;
  final Color cardColor;
  final Color frameColor;
  final Color chatBackgroundColor;
  final Color sentBubbleColor;
  final Color receivedBubbleColor;
  final Color sentTextColor;
  final Color receivedTextColor;
  final Color accentColor;
  final List<IOSMessageLine>? script;
  final bool loop;
  final Duration loopPause;
  final double borderRadius;
  final double deviceBorderRadius;
  final bool autoStart;

  @override
  State<IOSAnimation> createState() => _IOSAnimationState();
}

class _IOSAnimationState extends State<IOSAnimation> with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _floatAnim;

  late final AnimationController _shimmerController;
  late final Animation<double> _shimmerAnim;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);
    _floatAnim = CurvedAnimation(
      parent: _floatController,
      curve: Curves.easeInOut,
    );

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);
    _shimmerAnim = CurvedAnimation(
      parent: _shimmerController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Constants for the MacBook design
    const double macW = 820.0;
    const double macH = 540.0;

    return AnimatedBuilder(
      animation: _floatAnim,
      builder: (context, child) {
        final dy = -6 + _floatAnim.value * 12;
        return Transform.translate(
          offset: Offset(0, dy),
          child: child,
        );
      },
      child: Center(
        // FittedBox is the key: it scales the child to fit the parent
        // without causing pixel overflow errors.
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: macW,
            height: macH + 44,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLid(macW, macH),
                _buildBase(macW),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLid(double macW, double macH) {
    const Color topBezel = Color(0xFF3A3A3C);
    const Color lidSurface = Color(0xFF2C2C2E);

    return Container(
      width: macW,
      height: macH,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(14),
          topRight: Radius.circular(14),
        ),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3D3D3F), lidSurface, Color(0xFF252527)],
          stops: [0.0, 0.55, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.55),
            blurRadius: 48,
            spreadRadius: 4,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: const Color(0xFF0A84FF).withOpacity(0.18),
            blurRadius: 80,
            spreadRadius: -4,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: macH * 0.38,
            left: 0,
            right: 0,
            child: AnimatedBuilder(
              animation: _shimmerAnim,
              builder: (context, _) => Center(
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.06 + _shimmerAnim.value * 0.06),
                        blurRadius: 28,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 18,
            left: 22,
            right: 22,
            bottom: 10,
            child: _buildScreen(macW - 44, macH - 28),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 18,
            child: Container(
              decoration: const BoxDecoration(
                color: topBezel,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 6,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.45)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScreen(double w, double h) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0D1B2A), Color(0xFF1B2838), Color(0xFF0A1628)],
              ),
            ),
          ),
          CustomPaint(
            size: Size(w, h),
            painter: _DesktopTexturePainter(),
          ),
          _buildMenuBar(w),
          Positioned(
            top: 26,
            left: w * 0.05,
            right: w * 0.05,
            bottom: 10,
            child: _buildChatWindow(w * 0.9, h - 36),
          ),
          AnimatedBuilder(
            animation: _shimmerAnim,
            builder: (context, _) => Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: h * 0.45,
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withOpacity(0.04 + _shimmerAnim.value * 0.03),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuBar(double w) {
    return Container(
      height: 24,
      color: Colors.black.withOpacity(0.62),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          const Icon(Icons.apple, color: Colors.white, size: 13),
          const SizedBox(width: 10),
          _menuItem('Messages'),
          _menuItem('File'),
          _menuItem('Edit'),
          _menuItem('View'),
          const Spacer(),
          const Icon(Icons.wifi, color: Colors.white70, size: 12),
          const SizedBox(width: 6),
          const Icon(Icons.battery_full, color: Colors.white70, size: 12),
          const SizedBox(width: 6),
          Text(widget.statusBarTime, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _menuItem(String label) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 5),
    child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w500)),
  );

  Widget _buildChatWindow(double w, double h) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          _buildWindowTitleBar(),
          Expanded(
            child: _ChatBody(
              script: widget.script ?? defaultIOSScript,
              loop: widget.loop,
              loopPause: widget.loopPause,
              autoStart: widget.autoStart,
              contactName: widget.contactName,
              contactSubtitle: widget.contactSubtitle,
              contactInitials: widget.contactInitials,
              sentBubbleColor: widget.sentBubbleColor,
              receivedBubbleColor: widget.receivedBubbleColor,
              sentTextColor: widget.sentTextColor,
              receivedTextColor: widget.receivedTextColor,
              accentColor: widget.accentColor,
              windowWidth: w,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWindowTitleBar() {
    return Container(
      height: 36,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF0F0F0), Color(0xFFE4E4E4)],
        ),
        border: Border(bottom: BorderSide(color: Color(0xFFCCCCCC), width: 0.8)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          _trafficLight(const Color(0xFFFF5F57)),
          const SizedBox(width: 6),
          _trafficLight(const Color(0xFFFFBD2E)),
          const SizedBox(width: 6),
          _trafficLight(const Color(0xFF28C840)),
          const Spacer(),
          Text(widget.contactName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF333333))),
          const Spacer(),
          const SizedBox(width: 60),
        ],
      ),
    );
  }

  Widget _trafficLight(Color color) => Container(
    width: 12,
    height: 12,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 3)],
    ),
  );

  Widget _buildBase(double macW) {
    return Container(
      width: macW,
      height: 44,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF3A3A3C), Color(0xFF2A2A2C)],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(6),
          bottomRight: Radius.circular(6),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(child: CustomPaint(painter: _KeyboardPainter())),
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 8),
              width: 120,
              height: 22,
              decoration: BoxDecoration(
                color: const Color(0xFF333335),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.white.withOpacity(0.08), width: 0.8),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 2,
            child: Container(color: const Color(0xFF1A1A1C)),
          ),
        ],
      ),
    );
  }
}

class _ChatBody extends StatefulWidget {
  const _ChatBody({
    required this.script,
    required this.loop,
    required this.loopPause,
    required this.autoStart,
    required this.contactName,
    required this.contactSubtitle,
    required this.contactInitials,
    required this.sentBubbleColor,
    required this.receivedBubbleColor,
    required this.sentTextColor,
    required this.receivedTextColor,
    required this.accentColor,
    required this.windowWidth,
  });

  final List<IOSMessageLine> script;
  final bool loop;
  final Duration loopPause;
  final bool autoStart;
  final String contactName;
  final String contactSubtitle;
  final String contactInitials;
  final Color sentBubbleColor;
  final Color receivedBubbleColor;
  final Color sentTextColor;
  final Color receivedTextColor;
  final Color accentColor;
  final double windowWidth;

  @override
  State<_ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<_ChatBody> with TickerProviderStateMixin {
  final List<_ChatEntry> _entries = [];
  String _composingText = '';
  Timer? _typingTimer;
  Timer? _delayTimer;
  bool _disposed = false;
  late final AnimationController _pulseController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    if (widget.autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _playFrom(0));
    }
  }

  void _resetAndReplay() {
    _typingTimer?.cancel();
    _delayTimer?.cancel();
    setState(() {
      _entries.clear();
      _composingText = '';
    });
    _playFrom(0);
  }

  void _playFrom(int index) {
    if (_disposed) return;
    if (index >= widget.script.length) {
      if (widget.loop) {
        _delayTimer = Timer(widget.loopPause, _resetAndReplay);
      }
      return;
    }
    final line = widget.script[index];
    _delayTimer = Timer(line.delayBefore, () {
      if (_disposed) return;
      switch (line.type) {
        case IOSLineType.sent: _playSent(line, index); break;
        case IOSLineType.received: _playReceived(line, index); break;
        case IOSLineType.timestamp:
        case IOSLineType.readReceipt: _playMeta(line, index); break;
      }
    });
  }

  void _playSent(IOSMessageLine line, int index) {
    if (!line.animateTyping || line.text.isEmpty) {
      setState(() => _composingText = line.text);
      _delayTimer = Timer(const Duration(milliseconds: 250), () => _sendComposed(line, index));
      return;
    }
    int charIndex = 0;
    _typingTimer = Timer.periodic(line.typingSpeed, (timer) {
      if (_disposed) { timer.cancel(); return; }
      charIndex++;
      setState(() => _composingText = line.text.substring(0, charIndex.clamp(0, line.text.length)));
      if (charIndex >= line.text.length) {
        timer.cancel();
        _delayTimer = Timer(const Duration(milliseconds: 350), () => _sendComposed(line, index));
      }
    });
  }

  void _sendComposed(IOSMessageLine line, int index) {
    if (_disposed) return;
    setState(() {
      _composingText = '';
      _entries.add(_ChatEntry(kind: _BubbleKind.sent, text: line.text));
    });
    _scrollToBottomSoon();
    _delayTimer = Timer(line.holdAfter, () => _playFrom(index + 1));
  }

  void _playReceived(IOSMessageLine line, int index) {
    final dotsEntry = _ChatEntry(kind: _BubbleKind.typingDots);
    setState(() => _entries.add(dotsEntry));
    _scrollToBottomSoon();
    _delayTimer = Timer(line.typingIndicatorDuration, () {
      if (_disposed) return;
      setState(() => _entries.remove(dotsEntry));
      if (!line.animateTyping || line.text.isEmpty) {
        setState(() => _entries.add(_ChatEntry(kind: _BubbleKind.received, text: line.text)));
        _scrollToBottomSoon();
        _delayTimer = Timer(line.holdAfter, () => _playFrom(index + 1));
        return;
      }
      final entry = _ChatEntry(kind: _BubbleKind.received, text: '');
      setState(() => _entries.add(entry));
      int charIndex = 0;
      _typingTimer = Timer.periodic(line.typingSpeed, (timer) {
        if (_disposed) { timer.cancel(); return; }
        charIndex++;
        setState(() => entry.text = line.text.substring(0, charIndex.clamp(0, line.text.length)));
        _scrollToBottomSoon();
        if (charIndex >= line.text.length) {
          timer.cancel();
          _delayTimer = Timer(line.holdAfter, () => _playFrom(index + 1));
        }
      });
    });
  }

  void _playMeta(IOSMessageLine line, int index) {
    final kind = line.type == IOSLineType.timestamp ? _BubbleKind.timestamp : _BubbleKind.readReceipt;
    setState(() => _entries.add(_ChatEntry(kind: kind, text: line.text)));
    _scrollToBottomSoon();
    _delayTimer = Timer(line.holdAfter, () => _playFrom(index + 1));
  }

  void _scrollToBottomSoon() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _typingTimer?.cancel();
    _delayTimer?.cancel();
    _pulseController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildContactRow(),
        const Divider(height: 1, thickness: 0.5, color: Color(0xFFDDDDDD)),
        Expanded(child: _buildChatList()),
        _buildInputBar(),
      ],
    );
  }

  Widget _buildContactRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: const Color(0xFFF7F7F7),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: widget.accentColor,
            child: Text(widget.contactInitials, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 10),
          Expanded( // Wrap in Expanded to prevent overflow of name/subtitle
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(widget.contactName, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                Text(widget.contactSubtitle, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.5, color: Colors.black.withOpacity(0.4))),
              ],
            ),
          ),
          Icon(Icons.videocam_rounded, color: widget.accentColor, size: 18),
          const SizedBox(width: 12),
          Icon(Icons.phone_rounded, color: widget.accentColor, size: 16),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      physics: const ClampingScrollPhysics(),
      itemCount: _entries.length,
      itemBuilder: (context, i) => _buildEntry(_entries[i]),
    );
  }

  Widget _buildEntry(_ChatEntry entry) {
    switch (entry.kind) {
      case _BubbleKind.timestamp:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(child: Text(entry.text, style: TextStyle(color: Colors.black.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.w500))),
        );
      case _BubbleKind.readReceipt:
        return Padding(
          padding: const EdgeInsets.only(right: 6, top: 2, bottom: 6),
          child: Align(alignment: Alignment.centerRight, child: Text(entry.text, style: TextStyle(color: Colors.black.withOpacity(0.38), fontSize: 10.5))),
        );
      case _BubbleKind.sent:
        return _Bubble(
          alignment: Alignment.centerRight,
          color: widget.sentBubbleColor,
          textColor: widget.sentTextColor,
          text: entry.text,
          tailOnRight: true,
          maxWidth: widget.windowWidth * 0.58,
        );
      case _BubbleKind.received:
        return _Bubble(
          alignment: Alignment.centerLeft,
          color: widget.receivedBubbleColor,
          textColor: widget.receivedTextColor,
          text: entry.text,
          tailOnRight: false,
          maxWidth: widget.windowWidth * 0.58,
        );
      case _BubbleKind.typingDots:
        return Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: widget.receivedBubbleColor, borderRadius: BorderRadius.circular(18)),
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, _) => Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(3, (i) {
                  final phase = (_pulseController.value * 2 * math.pi) - (i * 0.6);
                  final bounce = (math.sin(phase) + 1) / 2;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Transform.translate(
                      offset: Offset(0, -bounce * 4),
                      child: Container(width: 6, height: 6, decoration: BoxDecoration(color: Colors.black.withOpacity(0.35), shape: BoxShape.circle)),
                    ),
                  );
                }),
              ),
            ),
          ),
        );
    }
  }

  Widget _buildInputBar() {
    final hasText = _composingText.isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 7, 10, 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFE2E2E4), width: 0.6)),
        color: Color(0xFFFAFAFA),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(Icons.add_circle, color: Colors.black.withOpacity(0.25), size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              constraints: const BoxConstraints(minHeight: 28),
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFDCDCDE), width: 0.8),
              ),
              child: hasText
                  ? RichText(
                text: TextSpan(children: [
                  TextSpan(text: _composingText, style: const TextStyle(color: Colors.black87, fontSize: 12.5)),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, _) {
                        final visible = (_pulseController.value * 2) % 1 < 0.5;
                        return Opacity(
                          opacity: visible ? 1 : 0,
                          child: Container(width: 1.5, height: 13, margin: const EdgeInsets.only(left: 1), color: widget.accentColor),
                        );
                      },
                    ),
                  ),
                ]),
              )
                  : Text('iMessage', style: TextStyle(color: Colors.black.withOpacity(0.33), fontSize: 12.5)),
            ),
          ),
          const SizedBox(width: 7),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 24,
            height: 24,
            decoration: BoxDecoration(color: hasText ? widget.accentColor : widget.accentColor.withOpacity(0.22), shape: BoxShape.circle),
            child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 14),
          ),
        ],
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.alignment, required this.color, required this.textColor, required this.text, required this.tailOnRight, required this.maxWidth});
  final Alignment alignment;
  final Color color;
  final Color textColor;
  final String text;
  final bool tailOnRight;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(tailOnRight ? 16 : 4),
              bottomRight: Radius.circular(tailOnRight ? 4 : 16),
            ),
          ),
          child: Text(text, style: TextStyle(color: textColor, fontSize: 13, height: 1.35)),
        ),
      ),
    );
  }
}

class _DesktopTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final paint = Paint()..color = Colors.white.withOpacity(0.06);
    for (int i = 0; i < 120; i++) {
      canvas.drawCircle(Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height), rng.nextDouble() * 1.2, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class _KeyboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.04)..style = PaintingStyle.stroke..strokeWidth = 0.6;
    const double startY = 6;
    const double keyH = 10.0;
    const double keyW = 18.0;
    const double gap = 3.0;
    final double totalKeys = ((size.width - 40) / (keyW + gap)).floorToDouble();
    final double startX = (size.width - (totalKeys * (keyW + gap) - gap)) / 2;
    for (int i = 0; i < totalKeys.toInt(); i++) {
      final x = startX + i * (keyW + gap);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(x, startY, keyW, keyH), const Radius.circular(2)), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

const List<IOSMessageLine> defaultIOSScript = [
  IOSMessageLine(type: IOSLineType.timestamp, text: 'Today 9:41 AM', animateTyping: false, delayBefore: Duration(milliseconds: 300), holdAfter: Duration(milliseconds: 300)),
  IOSMessageLine(type: IOSLineType.sent, text: 'Hey — can you check if the TaskFlow API deploy went out ok?', delayBefore: Duration(milliseconds: 400), typingSpeed: Duration(milliseconds: 16), holdAfter: Duration(milliseconds: 500)),
  IOSMessageLine(type: IOSLineType.received, text: 'Checking the deploy logs now, one sec.', animateTyping: false, typingIndicatorDuration: Duration(milliseconds: 1300), holdAfter: Duration(milliseconds: 500)),
  IOSMessageLine(type: IOSLineType.received, text: 'Deploy finished 4 minutes ago — all green. 12 routes updated, no failed health checks.', animateTyping: false, typingIndicatorDuration: Duration(milliseconds: 1400), holdAfter: Duration(milliseconds: 600)),
  IOSMessageLine(type: IOSLineType.sent, text: 'Perfect, thank you!', delayBefore: Duration(milliseconds: 300), typingSpeed: Duration(milliseconds: 18), holdAfter: Duration(milliseconds: 400)),
  IOSMessageLine(type: IOSLineType.readReceipt, text: 'Delivered', animateTyping: false, delayBefore: Duration(milliseconds: 200), holdAfter: Duration(milliseconds: 2200)),
];
