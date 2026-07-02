import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

class WeatherBackground extends StatefulWidget {
  final String description;
  final List<Color> colors;

  const WeatherBackground({
    super.key,
    required this.description,
    required this.colors,
  });

  @override
  State<WeatherBackground> createState() => _WeatherBackgroundState();
}

class _WeatherBackgroundState extends State<WeatherBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool get _isRainy => widget.description.contains('雨');

  bool get _isCloudy =>
      widget.description.contains('雲') || widget.description.contains('陰');

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: widget.colors,
          ),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            if (_isRainy) {
              return CustomPaint(
                painter: RainBackgroundPainter(
                  progress: _controller.value,
                ),
              );
            }

            if (_isCloudy) {
              return CustomPaint(
                painter: CloudBackgroundPainter(
                  progress: _controller.value,
                ),
              );
            }

            return CustomPaint(
              painter: SunnyBackgroundPainter(
                progress: _controller.value,
              ),
            );
          },
        ),
      ),
    );
  }
}

class SunnyBackgroundPainter extends CustomPainter {
  final double progress;

  SunnyBackgroundPainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(12);

    for (int i = 0; i < 45; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.75;

      final twinkle =
          (sin((progress * 2 * pi) + i) + 1) / 2;

      final radius = 1.2 + twinkle * 2.4;

      final paint = Paint()
        ..color = Colors.white.withValues(
          alpha: 0.15 + twinkle * 0.55,
        )
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          4,
        );

      canvas.drawCircle(
        Offset(x, y),
        radius,
        paint,
      );
    }

    final sunGlowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        40,
      );

    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.18),
      90,
      sunGlowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant SunnyBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class RainBackgroundPainter extends CustomPainter {
  final double progress;

  RainBackgroundPainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(30);

    for (int i = 0; i < 55; i++) {
      final baseX = random.nextDouble() * size.width;
      final speed = 80 + random.nextDouble() * 160;
      final startY = random.nextDouble() * size.height;

      final y = (startY + progress * speed) % size.height;
      final x = baseX + sin(progress * 2 * pi + i) * 10;

      final length = 18 + random.nextDouble() * 28;

      final paint = Paint()
        ..color = Colors.white.withValues(alpha: 0.18)
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(x, y),
        Offset(x - 8, y + length),
        paint,
      );
    }

    for (int i = 0; i < 14; i++) {
      final x = random.nextDouble() * size.width;
      final y =
          (random.nextDouble() * size.height + progress * 80) %
              size.height;

      final dropletPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          8,
        );

      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x, y),
          width: 20 + random.nextDouble() * 20,
          height: 55 + random.nextDouble() * 50,
        ),
        dropletPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RainBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class CloudBackgroundPainter extends CustomPainter {
  final double progress;

  CloudBackgroundPainter({
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(8);

    for (int i = 0; i < 12; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height * 0.75;

      final drift = sin(progress * 2 * pi + i) * 24;

      final paint = Paint()
        ..color = Colors.white.withValues(alpha: 0.08)
        ..maskFilter = const MaskFilter.blur(
          BlurStyle.normal,
          30,
        );

      canvas.drawCircle(
        Offset(baseX + drift, baseY),
        55 + random.nextDouble() * 70,
        paint,
      );
    }

    final mistPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..maskFilter = const MaskFilter.blur(
        BlurStyle.normal,
        60,
      );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.35),
        width: size.width * 0.9,
        height: size.height * 0.28,
      ),
      mistPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CloudBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}