import 'dart:async';

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
        child: CustomPaint(
          size: Size(widget.size, widget.size),
          painter: WatchFacePainter(
            config: widget.config,
            time: _now,
          ),
        ),
      ),
    );
  }
}
