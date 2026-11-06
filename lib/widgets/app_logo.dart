import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/app_typography.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 72,
    this.showText = false,
    this.light = false,
  });

  final double size;
  final bool showText;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.blue, AppColors.navy],
        ),
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.25),
            blurRadius: size * 0.3,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: CustomPaint(painter: _LogoPainter()),
    );

    if (!showText) return mark;

    final titleColor = light ? Colors.white : AppColors.navy;
    final subtitleColor = light
        ? Colors.white.withValues(alpha: 0.72)
        : AppColors.textSecondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(height: 16),
        Text(
          'ETLE Smart Detection',
          textAlign: TextAlign.center,
          style: AppTypography.title.copyWith(
            color: titleColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Pemantauan Pelanggaran Jalur Busway',
          textAlign: TextAlign.center,
          style: AppTypography.caption.copyWith(color: subtitleColor),
        ),
      ],
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.035
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final shield = Path()
      ..moveTo(size.width * 0.5, size.height * 0.16)
      ..lineTo(size.width * 0.76, size.height * 0.27)
      ..lineTo(size.width * 0.76, size.height * 0.54)
      ..quadraticBezierTo(
        size.width * 0.74,
        size.height * 0.73,
        size.width * 0.5,
        size.height * 0.84,
      )
      ..quadraticBezierTo(
        size.width * 0.26,
        size.height * 0.73,
        size.width * 0.24,
        size.height * 0.54,
      )
      ..lineTo(size.width * 0.24, size.height * 0.27)
      ..close();
    canvas.drawPath(shield, stroke);

    final lane = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.028
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.43, size.height * 0.36),
      Offset(size.width * 0.43, size.height * 0.68),
      lane,
    );
    canvas.drawLine(
      Offset(size.width * 0.57, size.height * 0.36),
      Offset(size.width * 0.57, size.height * 0.68),
      lane,
    );

    final lens = Paint()
      ..color = AppColors.blue
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.52),
      size.width * 0.075,
      lens,
    );
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.52),
      size.width * 0.11,
      stroke..strokeWidth = size.width * 0.03,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
