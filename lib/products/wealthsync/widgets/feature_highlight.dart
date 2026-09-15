// Ported from wealthsync_website. Stateless here: the original's scroll-in
// fade needed the visibility_detector package for one effect.
// ponytail: add the fade back (and the dep) if the zigzag reads dead on a
// long scroll.
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FeatureHighlight extends StatelessWidget {
  final String imagePath;
  final String title;
  final List<String> bullets;

  /// On desktop, place the image on the right instead of the left.
  /// Used to alternate the layout between consecutive features.
  final bool imageOnRight;

  const FeatureHighlight({
    super.key,
    required this.imagePath,
    required this.title,
    required this.bullets,
    this.imageOnRight = false,
  });

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              color: Colors.greenAccent,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.jetBrainsMono(
                color: Colors.white70,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    final phoneImage = ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.transparent],
          stops: [0.6, 1.0],
        ).createShader(bounds);
      },
      blendMode: BlendMode.dstIn,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Transform.scale(
          scale: isMobile ? 1.0 : 1.15,
          alignment: Alignment.topCenter,
          child: Image.asset(
            imagePath,
            fit: BoxFit.cover,
            height: isMobile ? 400 : 600,
            width: double.infinity,
            alignment: Alignment.topCenter,
          ),
        ),
      ),
    );

    final featureContent = Column(
      crossAxisAlignment: isMobile
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      children: [
        Text(
          title,
          textAlign: isMobile ? TextAlign.center : TextAlign.left,
          style: GoogleFonts.italiana(
            fontSize: isMobile ? 36 : 54,
            color: Colors.white,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 16),
        Column(
          crossAxisAlignment: isMobile
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: bullets.map(_buildBullet).toList(),
        ),
      ],
    );

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 20 : 30,
        horizontal: 24,
      ),
      child: isMobile
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                phoneImage,
                const SizedBox(height: 32),
                featureContent,
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: imageOnRight
                  ? [
                      Expanded(child: featureContent),
                      const SizedBox(width: 80),
                      SizedBox(width: 400, child: phoneImage),
                    ]
                  : [
                      SizedBox(width: 400, child: phoneImage),
                      const SizedBox(width: 80),
                      Expanded(child: featureContent),
                    ],
            ),
    );
  }
}
