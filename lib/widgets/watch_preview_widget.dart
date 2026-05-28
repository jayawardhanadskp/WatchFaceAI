import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../models/watch_face_config.dart';
import 'watch_face_painter.dart';

class WatchPreviewWidget extends StatefulWidget {
  final WatchFaceConfig config;
  final double size;
  final bool showGlow;

  const WatchPreviewWidget({
    super.key,
    required this.config,
    this.size = 200,
    this.showGlow = true,
  });

  @override
  State<WatchPreviewWidget> createState() => _WatchPreviewWidgetState();
}

class _WatchPreviewWidgetState extends State<WatchPreviewWidget> {
  late DateTime _now;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = widget.config.accentColorValue;
    final hasImage = widget.config.imagePrompt != null && widget.config.imagePrompt!.isNotEmpty;

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: widget.showGlow
          ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: accentColor.withAlpha(100),
                  blurRadius: widget.size * 0.15,
                  spreadRadius: widget.size * 0.02,
                ),
              ],
            )
          : null,
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasImage)
              Image.network(
                'https://image.pollinations.ai/prompt/${Uri.encodeComponent(widget.config.imagePrompt!)}?width=800&height=800&nologo=true',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: widget.config.backgroundColorValue),
              )
            else
              Container(color: widget.config.backgroundColorValue),
            
            if (hasImage)
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.black.withAlpha(10), // Mostly clear in center
                      Colors.black.withAlpha(140), // Darker at edges for border/text contrast
                    ],
                    radius: 0.85,
                  ),
                ),
              ),

            CustomPaint(
              size: Size(widget.size, widget.size),
              painter: WatchFacePainter(
                config: widget.config,
                time: _now,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
