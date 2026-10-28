import 'package:flutter/material.dart';

class AnonymousAvatar extends StatelessWidget {
  final double size;
  final bool isOnline;
  final bool showBadge;

  const AnonymousAvatar({
    super.key,
    this.size = 48,
    this.isOnline = true,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF88A8A), // Coral pink dari mockup
            ),
            child: Center(
              child: CustomPaint(
                size: Size(size * 0.58, size * 0.58),
                painter: _SpyIconPainter(),
              ),
            ),
          ),
          if (showBadge && isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: size * 0.28,
                height: size * 0.28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4CAF50),
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SpyIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.1;

    // 1. Fedora Hat Crown
    final hatCrownPath = Path();
    hatCrownPath.moveTo(size.width * 0.25, size.height * 0.38);
    hatCrownPath.cubicTo(
      size.width * 0.28,
      size.height * 0.05,
      size.width * 0.40,
      size.height * 0.18,
      size.width * 0.50,
      size.height * 0.12,
    );
    hatCrownPath.cubicTo(
      size.width * 0.60,
      size.height * 0.18,
      size.width * 0.72,
      size.height * 0.05,
      size.width * 0.75,
      size.height * 0.38,
    );
    hatCrownPath.close();
    canvas.drawPath(hatCrownPath, paint);

    // 2. Hat Brim
    final brimPath = Path();
    brimPath.moveTo(size.width * 0.1, size.height * 0.42);
    brimPath.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.32,
      size.width * 0.9,
      size.height * 0.42,
    );
    brimPath.quadraticBezierTo(
      size.width * 0.5,
      size.height * 0.48,
      size.width * 0.1,
      size.height * 0.42,
    );
    brimPath.close();
    canvas.drawPath(brimPath, paint);

    // 3. Glasses (Two circles and a bridge)
    final leftCenter = Offset(size.width * 0.32, size.height * 0.68);
    final rightCenter = Offset(size.width * 0.68, size.height * 0.68);
    final glassRadius = size.width * 0.16;

    canvas.drawCircle(leftCenter, glassRadius, strokePaint);
    canvas.drawCircle(rightCenter, glassRadius, strokePaint);

    // Bridge between glasses
    canvas.drawLine(
      Offset(size.width * 0.44, size.height * 0.66),
      Offset(size.width * 0.56, size.height * 0.66),
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
