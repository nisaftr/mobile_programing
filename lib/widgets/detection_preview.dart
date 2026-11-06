import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_radius.dart';
import '../core/theme/app_typography.dart';
import '../models/violation_model.dart';

class PreviewBox {
  const PreviewBox({
    required this.box,
    required this.label,
    required this.color,
    this.isViolation = false,
  });

  final BoundingBox box;
  final String label;
  final Color color;
  final bool isViolation;
}

class DetectionPreview extends StatelessWidget {
  const DetectionPreview({
    super.key,
    required this.boxes,
    this.showOverlay = true,
    this.aspectRatio = 16 / 9,
    this.badge,
    this.footer,
  });

  final List<PreviewBox> boxes;
  final bool showOverlay;
  final double aspectRatio;
  final Widget? badge;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.lgAll,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CustomPaint(
              painter: _CctvPainter(boxes: showOverlay ? boxes : const []),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x33000000),
                    Color(0x00000000),
                    Color(0x88000000),
                  ],
                  stops: [0, 0.45, 1],
                ),
              ),
            ),
            if (badge != null) Positioned(top: 10, left: 10, child: badge!),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'CCTV',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontSize: 9,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (footer != null)
              Positioned(left: 10, right: 10, bottom: 10, child: footer!),
          ],
        ),
      ),
    );
  }
}

class _CctvPainter extends CustomPainter {
  _CctvPainter({required this.boxes});

  final List<PreviewBox> boxes;

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1B2C40), Color(0xFF0D1B2A)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, background);

    final horizon = size.height * 0.30;
    final road = Path()
      ..moveTo(size.width * 0.18, size.height)
      ..lineTo(size.width * 0.40, horizon)
      ..lineTo(size.width * 0.60, horizon)
      ..lineTo(size.width * 0.82, size.height)
      ..close();
    canvas.drawPath(road, Paint()..color = const Color(0xFF2D3B4A));

    final busway = Path()
      ..moveTo(size.width * 0.50, size.height)
      ..lineTo(size.width * 0.50, horizon)
      ..lineTo(size.width * 0.60, horizon)
      ..lineTo(size.width * 0.70, size.height)
      ..close();
    canvas.drawPath(
      busway,
      Paint()..color = AppColors.warning.withValues(alpha: 0.18),
    );

    final buswayBorder = Paint()
      ..color = AppColors.warning.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawLine(
      Offset(size.width * 0.50, horizon),
      Offset(size.width * 0.50, size.height),
      buswayBorder,
    );
    canvas.drawLine(
      Offset(size.width * 0.60, horizon),
      Offset(size.width * 0.70, size.height),
      buswayBorder,
    );

    final lanePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.28)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    for (var i = 1; i <= 3; i++) {
      final t = i / 4;
      final xTop = size.width * (0.40 + 0.20 * t);
      final xBottom = size.width * (0.18 + 0.64 * t);
      canvas.drawLine(
        Offset(xTop, horizon + 6),
        Offset(xBottom, size.height),
        lanePaint,
      );
    }

    final stopLine = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(size.width * 0.42, size.height * 0.62),
      Offset(size.width * 0.60, size.height * 0.62),
      stopLine,
    );

    for (final item in boxes) {
      final rect = Rect.fromLTWH(
        item.box.x * size.width,
        item.box.y * size.height,
        item.box.width * size.width,
        item.box.height * size.height,
      );
      final fill = Paint()
        ..color = item.color.withValues(alpha: 0.14)
        ..style = PaintingStyle.fill;
      final border = Paint()
        ..color = item.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = item.isViolation ? 2.4 : 1.8;
      canvas.drawRect(rect, fill);
      canvas.drawRect(rect, border);

      final label = item.isViolation ? '${item.label} • BUSWAY' : item.label;
      final painter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: (size.width * 0.026).clamp(9.0, 13.0),
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width * 0.55);
      final labelWidth = painter.width + 10;
      final labelHeight = painter.height + 6;
      final labelRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          rect.left,
          rect.top - labelHeight,
          labelWidth,
          labelHeight,
        ),
        const Radius.circular(4),
      );
      canvas.drawRRect(
        labelRect,
        Paint()..color = item.color.withValues(alpha: 0.92),
      );
      painter.paint(canvas, Offset(rect.left + 5, rect.top - labelHeight + 3));
    }

    final scan = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..strokeWidth = 1;
    for (var y = 0.0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), scan);
    }
  }

  @override
  bool shouldRepaint(covariant _CctvPainter oldDelegate) =>
      oldDelegate.boxes != boxes;
}
