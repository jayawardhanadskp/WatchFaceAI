import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

const _kAccent = Color(0xFF6C63FF);
const _kBg = Color(0xFF0A0A0F);

class GeneratingScreen extends StatefulWidget {
  const GeneratingScreen({super.key});

  @override
  State<GeneratingScreen> createState() => _GeneratingScreenState();
}

class _GeneratingScreenState extends State<GeneratingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pulseCtrl;
  late final AnimationController _rotateCtrl;
  late final AnimationController _dotCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _rotateCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();

    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _rotateCtrl.dispose();
    _dotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animated ring + watch circle
              SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer pulsing rings
                    AnimatedBuilder(
                      animation: Listenable.merge([_pulseCtrl, _rotateCtrl]),
                      builder: (context, child) => CustomPaint(
                        size: const Size(220, 220),
                        painter: _PulsingRingPainter(
                          pulse: _pulseCtrl.value,
                          rotation: _rotateCtrl.value * 2 * math.pi,
                          accentColor: _kAccent,
                        ),
                      ),
                    ),

                    // Watch face circle (dark with shimmer)
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF12121A),
                        border: Border.all(
                          color: _kAccent.withAlpha(60),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: _kAccent,
                        size: 36,
                      ),
                    )
                        .animate(onPlay: (c) => c.repeat(reverse: true))
                        .scaleXY(
                          begin: 0.95,
                          end: 1.05,
                          duration: 1800.ms,
                          curve: Curves.easeInOut,
                        ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // Main label
              const Text(
                'AI is designing your\nwatch face...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.2, end: 0),

              const SizedBox(height: 16),

              // Animated dots
              AnimatedBuilder(
                animation: _dotCtrl,
                builder: (context, child) => _AnimatedDots(progress: _dotCtrl.value),
              ),

              const SizedBox(height: 32),

              // Sub-label
              Text(
                'Calling Gemini 1.5 Flash',
                style: TextStyle(
                  color: Colors.white.withAlpha(100),
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              )
                  .animate()
                  .fadeIn(delay: 400.ms, duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedDots extends StatelessWidget {
  final double progress; // 0..1 cycling

  const _AnimatedDots({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final phase = (progress - i * 0.25).abs() % 1.0;
        final opacity = (math.sin(phase * math.pi * 2) * 0.5 + 0.5)
            .clamp(0.2, 1.0);
        return Container(
          width: 7,
          height: 7,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _kAccent.withValues(alpha: opacity),
          ),
        );
      }),
    );
  }
}

class _PulsingRingPainter extends CustomPainter {
  final double pulse; // 0..1
  final double rotation; // radians
  final Color accentColor;

  const _PulsingRingPainter({
    required this.pulse,
    required this.rotation,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final baseR = size.width / 2 - 4;

    // Outer glow ring
    final outerR = baseR + pulse * 8;
    canvas.drawCircle(
      center,
      outerR,
      Paint()
        ..color = accentColor.withValues(alpha: 0.08 + pulse * 0.12)
        ..style = PaintingStyle.fill,
    );

    // Mid ring
    canvas.drawCircle(
      center,
      baseR * 0.98,
      Paint()
        ..color = accentColor.withValues(alpha: 0.15 + pulse * 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Rotating primary arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: baseR),
      rotation,
      math.pi * 0.75,
      false,
      Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );

    // Rotating secondary arc (opposite, dimmer)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: baseR),
      rotation + math.pi,
      math.pi * 0.4,
      false,
      Paint()
        ..color = accentColor.withAlpha(100)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // Rotating inner arc (slower, different phase)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: baseR * 0.85),
      -rotation * 0.6,
      math.pi * 0.5,
      false,
      Paint()
        ..color = accentColor.withAlpha(80)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_PulsingRingPainter old) =>
      old.pulse != pulse || old.rotation != rotation;
}
