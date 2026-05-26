import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/watch_face_config.dart';

class WatchFacePainter extends CustomPainter {
  final WatchFaceConfig config;
  final DateTime time;
  final int steps;
  final int batteryPercent;

  const WatchFacePainter({
    required this.config,
    required this.time,
    this.steps = 6842,
    this.batteryPercent = 72,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final hasImage = config.imagePrompt != null && config.imagePrompt!.isNotEmpty;

    // Clip all content to circle
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
    );

    // Background fill (only if no image, or just a very subtle tint)
    if (!hasImage) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()..color = config.backgroundColorValue,
      );

      // Subtle radial gradient overlay for depth (if no image)
      final gradientPaint = Paint()
        ..shader = RadialGradient(
          center: Alignment.topLeft,
          radius: 1.4,
          colors: [
            Colors.white.withAlpha(15),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawCircle(center, radius, gradientPaint);
    }

    // Steps arc (background + progress)
    if (config.showSteps) {
      _drawStepsArc(canvas, center, radius, hasImage);
    }

    // Battery indicator
    if (config.showBattery) {
      _drawBattery(canvas, size, radius, center, hasImage);
    }

    // Time text
    _drawTime(canvas, center, radius, hasImage);

    // Date below time
    if (config.showDate) {
      _drawDate(canvas, center, radius, hasImage);
    }

    canvas.restore();

    // Border drawn outside clip so it sits on the edge cleanly
    _drawBorder(canvas, center, radius, size);
  }

  void _drawBorder(Canvas canvas, Offset center, double radius, Size size) {
    if (config.borderStyle == 'ring') {
      final strokeW = math.max(2.0, radius * 0.035);
      final paint = Paint()
        ..color = config.accentColorValue
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW;
      canvas.drawCircle(center, radius - strokeW / 2, paint);
    } else if (config.borderStyle == 'square') {
      final strokeW = math.max(2.0, radius * 0.03);
      final paint = Paint()
        ..color = config.accentColorValue
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeW;
      final inset = strokeW / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(inset, inset, size.width - strokeW,
              size.height - strokeW),
          const Radius.circular(6),
        ),
        paint,
      );
    }
  }

  void _drawTime(Canvas canvas, Offset center, double radius, bool hasImage) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    final timeStr = '$h:$m';

    final weight = switch (config.fontStyle) {
      'thin' => FontWeight.w200,
      'bold' => FontWeight.w800,
      _ => FontWeight.w500,
    };

    final fontSize = radius * 0.42; // slightly larger for premium feel
    final tp = _buildTextPainter(
      timeStr,
      fontSize: fontSize,
      color: config.timeColorValue,
      weight: weight,
      letterSpacing: fontSize * 0.02,
      hasImage: hasImage,
    );

    final yOffset = config.showDate ? -radius * 0.1 : 0.0;
    tp.paint(
      canvas,
      center - Offset(tp.width / 2, tp.height / 2) + Offset(0, yOffset),
    );
  }

  void _drawDate(Canvas canvas, Offset center, double radius, bool hasImage) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    final dateStr = '${months[time.month - 1]} ${time.day}';
    final tp = _buildTextPainter(
      dateStr,
      fontSize: radius * 0.14,
      color: config.accentColorValue,
      weight: FontWeight.w600,
      letterSpacing: 2.0,
      hasImage: hasImage,
    );
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy + radius * 0.22),
    );
  }

  void _drawBattery(
      Canvas canvas, Size size, double radius, Offset center, bool hasImage) {
    final x = center.dx + radius * 0.38;
    final y = center.dy - radius * 0.72;
    final w = radius * 0.22;
    final h = radius * 0.11;

    final strokePaint = Paint()
      ..color = config.accentColorValue.withAlpha(200)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Optional glow for battery outline
    if (hasImage) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, w, h), const Radius.circular(2)),
        Paint()
          ..color = config.accentColorValue.withAlpha(100)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, w, h), const Radius.circular(2)),
      strokePaint,
    );

    // Battery nub
    canvas.drawRect(
      Rect.fromLTWH(x + w, y + h * 0.3, w * 0.08, h * 0.4),
      Paint()..color = config.accentColorValue.withAlpha(200),
    );

    // Fill
    final fillColor =
        batteryPercent > 20 ? config.accentColorValue : Colors.redAccent;
    final fillWidth = (w - 3) * (batteryPercent / 100).clamp(0.0, 1.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x + 1.5, y + 1.5, fillWidth, h - 3),
        const Radius.circular(1),
      ),
      Paint()..color = fillColor,
    );

    // Percentage label
    final tp = _buildTextPainter(
      '$batteryPercent%',
      fontSize: radius * 0.1,
      color: config.accentColorValue,
      weight: FontWeight.w600,
      hasImage: hasImage,
    );
    tp.paint(canvas, Offset(x - tp.width * 0.1, y + h + radius * 0.02));
  }

  void _drawStepsArc(Canvas canvas, Offset center, double radius, bool hasImage) {
    const maxSteps = 10000;
    final progress = (steps / maxSteps).clamp(0.0, 1.0);
    const startAngle = math.pi * 0.75;
    const sweepAngle = math.pi * 1.5;
    final arcRadius = radius * 0.84;

    // Background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: arcRadius),
      startAngle,
      sweepAngle,
      false,
      Paint()
        ..color = config.accentColorValue.withAlpha(35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.035
        ..strokeCap = StrokeCap.round,
    );

    // Glow for progress arc
    if (progress > 0 && hasImage) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: arcRadius),
        startAngle,
        sweepAngle * progress,
        false,
        Paint()
          ..color = config.accentColorValue.withAlpha(120)
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.06
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: arcRadius),
        startAngle,
        sweepAngle * progress,
        false,
        Paint()
          ..color = config.accentColorValue
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.035
          ..strokeCap = StrokeCap.round,
      );
    }

    // Steps count label at bottom center
    final tp = _buildTextPainter(
      '$steps steps',
      fontSize: radius * 0.11,
      color: config.accentColorValue,
      weight: FontWeight.w600,
      letterSpacing: 0.5,
      hasImage: hasImage,
    );
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy + radius * 0.58),
    );
  }

  TextPainter _buildTextPainter(
    String text, {
    required double fontSize,
    required Color color,
    FontWeight weight = FontWeight.w400,
    double letterSpacing = 0,
    bool hasImage = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: weight,
          letterSpacing: letterSpacing,
          shadows: hasImage
              ? [
                  Shadow(
                    color: Colors.black.withAlpha(180),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                  Shadow(
                    color: color.withAlpha(80),
                    blurRadius: 16,
                    offset: const Offset(0, 0),
                  ),
                ]
              : null,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    return tp;
  }

  @override
  bool shouldRepaint(WatchFacePainter old) =>
      old.config != config ||
      old.time.minute != time.minute ||
      old.time.hour != time.hour;
}
