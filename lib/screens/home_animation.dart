import 'package:flutter/material.dart';
import 'dart:ui_web' as ui_web; // Updated import for Web Platform Views
import 'package:web/web.dart' as web; // Modern replacement for dart:html
import 'package:pointer_interceptor/pointer_interceptor.dart';

class HomeAnimation extends StatefulWidget {
  const HomeAnimation({super.key});

  @override
  State<HomeAnimation> createState() => _HomeAnimationState();
}

class _HomeAnimationState extends State<HomeAnimation> {
  final String viewID = "instagram-reel-view";
  final String reelUrl = "https://www.instagram.com/reel/DUVkZBAEn8R/embed";

  @override
  void initState() {
    super.initState();

    // Modern way to register a platform view for Flutter Web
    ui_web.platformViewRegistry.registerViewFactory(
      viewID,
          (int viewId) {
        // Create the iFrame using package:web
        final web.HTMLIFrameElement iframe = web.document.createElement('iframe') as web.HTMLIFrameElement;

        iframe.src = reelUrl;
        iframe.style.border = 'none';
        iframe.style.width = '100%';
        iframe.style.height = '100%';
        iframe.allow = "autoplay; encrypted-media; picture-in-picture";

        return iframe;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: Container(
            // Maintains the rounded square/vertical box look
            width: 350,
            height: 550,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: PointerInterceptor(
                // Allows clicks to pass through to the Instagram iFrame
                child: HtmlElementView(
                  viewType: viewID,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
