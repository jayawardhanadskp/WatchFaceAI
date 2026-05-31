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
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [
              Color(0xFF1A1A2E), // Deep space blue/purple
              _kBg,
            ],
            center: Alignment.center,
            radius: 1.0,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated ring + watch circle
                SizedBox(
                  width: 260,
                  height: 260,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer pulsing rings
                      AnimatedBuilder(
                        animation: Listenable.merge([_pulseCtrl, _rotateCtrl]),
                        builder: (context, child) => CustomPaint(
                          size: const Size(260, 260),
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
                          boxShadow: [
                            BoxShadow(
                              color: _kAccent.withAlpha(40),
                              blurRadius: 30,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          color: _kAccent,
                          size: 40,
                        ),
                      )
                          .animate(onPlay: (c) => c.repeat(reverse: true))
                          .scaleXY(
                            begin: 0.95,
                            end: 1.05,
                            duration: 1800.ms,
                            curve: Curves.easeInOut,
                          )
                          .shimmer(
                            duration: 2000.ms,
                            color: Colors.white.withAlpha(100),
                          ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                // Main label
                const Text(
                  'Synthesizing Neural Matrix...\nGenerating AI Wallpaper',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                    letterSpacing: 1.2,
                  ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 20),

                // Animated dots
                AnimatedBuilder(
                  animation: _dotCtrl,
                  builder: (context, child) => _AnimatedDots(progress: _dotCtrl.value),
                ),

                const SizedBox(height: 40),

                // Sub-label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _kAccent.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _kAccent.withAlpha(80)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.psychology, size: 16, color: _kAccent),
                      const SizedBox(width: 8),
                      Text(
                        'Powered by Gemini & Pollinations',
                        style: TextStyle(
                          color: Colors.white.withAlpha(200),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 400.ms),
              ],
            ),
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
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _kAccent.withValues(alpha: opacity),
            boxShadow: [
              BoxShadow(
                color: _kAccent.withValues(alpha: opacity * 0.5),
                blurRadius: 6,
                spreadRadius: 2,
              )
            ],
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
    final baseR = size.width / 2 - 8;

    // Outer glow ring
    final outerR = baseR + pulse * 12;
    canvas.drawCircle(
      center,
      outerR,
      Paint()
        ..color = accentColor.withValues(alpha: 0.08 + pulse * 0.12)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );

    // Mid ring
    canvas.drawCircle(
      center,
      baseR * 0.98,
      Paint()
        ..color = accentColor.withValues(alpha: 0.2 + pulse * 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Rotating primary arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: baseR),
      rotation,
      math.pi * 0.85,
      false,
      Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4),
    );

    // Rotating secondary arc (opposite, dimmer)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: baseR),
      rotation + math.pi,
      math.pi * 0.5,
      false,
      Paint()
        ..color = const Color(0xFF00FFCC).withAlpha(150) // Cyan accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 6),
    );

    // Rotating inner arc (slower, different phase)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: baseR * 0.82),
      -rotation * 0.7,
      math.pi * 0.6,
      false,
      Paint()
        ..color = const Color(0xFFFF007F).withAlpha(120) // Pink accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.solid, 4),
    );
  }

  @override
  bool shouldRepaint(_PulsingRingPainter old) =>
      old.pulse != pulse || old.rotation != rotation;
}
