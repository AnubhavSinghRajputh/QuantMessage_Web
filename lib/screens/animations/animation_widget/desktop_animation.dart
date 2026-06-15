// lib/screens/animations/animation_widget/desktop_animation.dart

import 'package:flutter/material.dart';
import 'dart:math' as math;

class DesktopAnimation extends StatelessWidget {
  final double? width;
  final double? height;
  final Color backgroundColor;
  final Color desktopBackgroundColor;
  final bool showGradient;

  const DesktopAnimation({
    super.key,
    this.width,
    this.height,
    this.backgroundColor = const Color(0xFFFF8A50), // Orange background
    this.desktopBackgroundColor = const Color(0xFF1A1A1A), // Dark desktop
    this.showGradient = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            if (showGradient) _buildBackgroundPattern(),
            _buildDesktopContent(),
            // Window controls (macOS style dots)
            Positioned(
              top: 20,
              left: 20,
              child: Row(
                children: [
                  _buildDot(const Color(0xFFFF5F57)),
                  const SizedBox(width: 8),
                  _buildDot(const Color(0xFFFEBC2E)),
                  const SizedBox(width: 8),
                  _buildDot(const Color(0xFF28C840)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Window control dot
  Widget _buildDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  // Subtle background pattern
  Widget _buildBackgroundPattern() {
    return CustomPaint(
      painter: _WavePatternPainter(),
      child: Container(),
    );
  }

  // Desktop content (the main UI inside)
  Widget _buildDesktopContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // LEFT SIDE - App sidebar with messages
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App Header
                  _buildAppHeader(),
                  const SizedBox(height: 20),

                  // Logo + Brand
                  _buildBrandHeader(),
                  const SizedBox(height: 24),

                  // Messages list
                  Expanded(
                    child: _buildMessagesList(),
                  ),

                  // Input box at bottom
                  _buildInputBox(),
                ],
              ),
            ),
          ),

          // RIGHT SIDE - Options panel
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withOpacity(0.05),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildOptionTile(
                    icon: Icons.chat_bubble_outline,
                    title: 'Chats',
                    count: 24,
                    color: const Color(0xFFFF8A50),
                    isActive: true,
                  ),
                  const SizedBox(height: 10),
                  _buildOptionTile(
                    icon: Icons.mark_chat_unread_outlined,
                    title: 'Unread',
                    count: 7,
                    color: const Color(0xFF4FC3F7),
                  ),
                  const SizedBox(height: 10),
                  _buildOptionTile(
                    icon: Icons.circle_outlined,
                    title: 'Status',
                    count: 3,
                    color: const Color(0xFF81C784),
                  ),
                  const SizedBox(height: 10),
                  _buildOptionTile(
                    icon: Icons.tag,
                    title: 'Channels',
                    count: 12,
                    color: const Color(0xFFBA68C8),
                  ),
                  const Spacer(),
                  // AI badge
                  _buildAIBadge(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppHeader() {
    return Row(
      children: [
        // QuantMessage Icon
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF8A50), Color(0xFFFFB347)],
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Icon(
            Icons.bolt,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'QuantMessage',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Icon(
          Icons.search,
          color: Colors.white.withOpacity(0.5),
          size: 18,
        ),
        const SizedBox(width: 12),
        Icon(
          Icons.more_horiz,
          color: Colors.white.withOpacity(0.5),
          size: 18,
        ),
      ],
    );
  }

  Widget _buildBrandHeader() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFFF8A50).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF8A50).withOpacity(0.3),
                  const Color(0xFFFFB347).withOpacity(0.3),
                ],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome,
                color: Color(0xFFFF8A50),
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Inbox',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Smart message manager',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    final messages = [
      _MessageData(
        name: 'Sarah Chen',
        preview: 'Hey! Can you review the design...',
        time: '2m',
        unread: true,
        avatarColor: const Color(0xFF4FC3F7),
      ),
      _MessageData(
        name: 'AI Assistant',
        preview: 'I\'ve sorted 12 messages by...',
        time: '5m',
        unread: true,
        avatarColor: const Color(0xFFFF8A50),
        isAI: true,
      ),
      _MessageData(
        name: 'Dev Team',
        preview: 'Sprint planning at 3 PM...',
        time: '15m',
        unread: false,
        avatarColor: const Color(0xFF81C784),
      ),
      _MessageData(
        name: 'Mike Ross',
        preview: 'The deploy looks good 👍',
        time: '1h',
        unread: false,
        avatarColor: const Color(0xFFBA68C8),
      ),
    ];

    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: messages.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        return _buildMessageTile(messages[index]);
      },
    );
  }

  Widget _buildMessageTile(_MessageData msg) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: msg.unread
            ? const Color(0xFFFF8A50).withOpacity(0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: msg.avatarColor.withOpacity(0.2),
            ),
            child: Center(
              child: msg.isAI
                  ? const Icon(
                Icons.auto_awesome,
                size: 16,
                color: Color(0xFFFF8A50),
              )
                  : Text(
                msg.name[0],
                style: TextStyle(
                  color: msg.avatarColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        msg.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight:
                          msg.unread ? FontWeight.w600 : FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      msg.time,
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  msg.preview,
                  style: TextStyle(
                    color: msg.unread ? Colors.white70 : Colors.white38,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (msg.unread)
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(left: 8),
              decoration: const BoxDecoration(
                color: Color(0xFFFF8A50),
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInputBox() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.add,
            color: Colors.white54,
            size: 16,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Ask AI to manage messages...',
              style: TextStyle(
                color: Colors.white38,
                fontSize: 11,
              ),
            ),
          ),
          const Icon(
            Icons.send,
            color: Color(0xFFFF8A50),
            size: 14,
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required int count,
    required Color color,
    bool isActive = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? color.withOpacity(0.4) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIBadge() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFFF8A50).withOpacity(0.2),
            const Color(0xFFFFB347).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFFF8A50).withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome,
            color: Color(0xFFFF8A50),
            size: 14,
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'AI Active',
              style: TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Color(0xFF81C784),
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

// Data model for messages
class _MessageData {
  final String name;
  final String preview;
  final String time;
  final bool unread;
  final Color avatarColor;
  final bool isAI;

  _MessageData({
    required this.name,
    required this.preview,
    required this.time,
    required this.unread,
    required this.avatarColor,
    this.isAI = false,
  });
}

// Custom painter for subtle wave pattern background
class _WavePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final path = Path();
    final yCenter = size.height * 0.3;

    path.moveTo(0, yCenter);
    for (double x = 0; x <= size.width; x++) {
      path.lineTo(
        x,
        yCenter + math.sin(x / 80) * 15,
      );
    }
    canvas.drawPath(path, paint);

    final path2 = Path();
    final y2 = size.height * 0.7;
    path2.moveTo(0, y2);
    for (double x = 0; x <= size.width; x++) {
      path2.lineTo(
        x,
        y2 + math.cos(x / 60) * 12,
      );
    }
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
