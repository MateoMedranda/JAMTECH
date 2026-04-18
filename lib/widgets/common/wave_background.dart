import 'dart:math';
import 'package:flutter/material.dart';
import '../../config/theme/app_colors.dart';

class WaveBackground extends StatelessWidget {
  final Widget child;

  const WaveBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo base
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColors.background, Color(0xFFF0F9F9)],
            ),
          ),
        ),
        // Olas superiores
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 200),
            painter: WavePainter(
              color: AppColors.primary.withOpacity(0.3),
              waveHeight: 30,
              offset: 0,
            ),
          ),
        ),
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 180),
            painter: WavePainter(
              color: AppColors.primary.withOpacity(0.2),
              waveHeight: 40,
              offset: 50,
            ),
          ),
        ),
        // Olas inferiores
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 150),
            painter: BottomWavePainter(
              color: AppColors.primaryDark.withOpacity(0.15),
              waveHeight: 35,
              offset: 0,
            ),
          ),
        ),
        Positioned(
          bottom: -20,
          left: 0,
          right: 0,
          child: CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 130),
            painter: BottomWavePainter(
              color: AppColors.primary.withOpacity(0.1),
              waveHeight: 45,
              offset: 80,
            ),
          ),
        ),
        // Contenido
        child,
      ],
    );
  }
}

class WavePainter extends CustomPainter {
  final Color color;
  final double waveHeight;
  final double offset;

  WavePainter({
    required this.color,
    required this.waveHeight,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.5);

    // Crear las olas
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height * 0.5 +
            waveHeight * (0.5 + 0.5 * sin(i / size.width * 2 * pi + offset)),
      );
    }

    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BottomWavePainter extends CustomPainter {
  final Color color;
  final double waveHeight;
  final double offset;

  BottomWavePainter({
    required this.color,
    required this.waveHeight,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.5);

    // Crear las olas
    for (double i = 0; i <= size.width; i++) {
      path.lineTo(
        i,
        size.height * 0.5 -
            waveHeight * (0.5 + 0.5 * sin(i / size.width * 2 * pi + offset)),
      );
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
