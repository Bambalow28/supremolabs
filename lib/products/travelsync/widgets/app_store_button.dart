import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../app_links.dart';

/// Badge-style button that opens the App Store listing.
class AppStoreButton extends StatefulWidget {
  final bool large;

  const AppStoreButton({super.key, this.large = false});

  @override
  State<AppStoreButton> createState() => _AppStoreButtonState();
}

class _AppStoreButtonState extends State<AppStoreButton> {
  bool _hovered = false;

  Future<void> _open() async {
    final uri = Uri.parse(appStoreUrl);
    await launchUrl(uri, webOnlyWindowName: '_blank');
  }

  @override
  Widget build(BuildContext context) {
    final large = widget.large;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: _open,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: EdgeInsets.symmetric(
            horizontal: large ? 24 : 18,
            vertical: large ? 14 : 11,
          ),
          transform: _hovered
              ? (Matrix4.identity()..translateByDouble(0.0, -2.0, 0.0, 1.0))
              : Matrix4.identity(),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hovered ? 0.35 : 0.22),
                blurRadius: _hovered ? 26 : 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.apple, color: Colors.black, size: large ? 30 : 26),
              SizedBox(width: large ? 12 : 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Download on the',
                    style: TextStyle(
                      fontSize: large ? 10 : 9,
                      color: Colors.black54,
                      letterSpacing: 0.3,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    'App Store',
                    style: TextStyle(
                      fontSize: large ? 22 : 19,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.05,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
