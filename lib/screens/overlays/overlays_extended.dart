// lib/screens/overlays/overlays_extended.dart

import 'package:flutter/material.dart';
import '../animations/animation_widget/desktop_animation.dart';

class OverlaysExtended extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final String? description;
  final List<OverlayFeature>? features;
  final Widget? customContent;
  final bool showDesktop;
  final EdgeInsetsGeometry padding;
  final double? maxWidth;

  const OverlaysExtended({
    super.key,
    this.title,
    this.subtitle,
    this.description,
    this.features,
    this.customContent,
    this.showDesktop = true,
    this.padding = const EdgeInsets.all(32.0),
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? 1200,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withOpacity(0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section
            if (title != null || subtitle != null || description != null)
              _buildHeader(),

            // Desktop animation container
            if (showDesktop)
              _buildDesktopSection()
            else if (customContent != null)
              Padding(
                padding: padding,
                child: customContent!,
              ),

            // Features list
            if (features != null && features!.isNotEmpty)
              _buildFeaturesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withOpacity(0.06),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subtitle != null) ...[
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF8A50),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          if (title != null)
            Text(
              title!,
              style: const TextStyle(
                color: Color(0xFF0A0A0A),
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                height: 1.2,
              ),
            ),
          if (description != null) ...[
            const SizedBox(height: 12),
            Text(
              description!,
              style: TextStyle(
                color: Colors.black.withOpacity(0.65),
                fontSize: 15,
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDesktopSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withOpacity(0.06),
            width: 1,
          ),
        ),
      ),
      child: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Responsive sizing
            double width = constraints.maxWidth * 0.95;
            double height = (width * 0.625).clamp(300.0, 500.0);

            // On small screens, use full width
            if (constraints.maxWidth < 600) {
              width = constraints.maxWidth;
              height = (width * 0.7).clamp(280.0, 450.0);
            }

            return DesktopAnimation(
              width: width,
              height: height,
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Key Features',
            style: TextStyle(
              color: Color(0xFF0A0A0A),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          ...features!.map((feature) => _buildFeatureItem(feature)),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(OverlayFeature feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 2, right: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF8A50).withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              feature.icon ?? Icons.check,
              color: const Color(0xFFFF8A50),
              size: 14,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  feature.title,
                  style: const TextStyle(
                    color: Color(0xFF0A0A0A),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (feature.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    feature.description!,
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.6),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Data model for features
class OverlayFeature {
  final String title;
  final String? description;
  final IconData? icon;

  const OverlayFeature({
    required this.title,
    this.description,
    this.icon,
  });
}
