import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wear/wear.dart';

import 'models/watch_face_config.dart';
import 'widgets/watch_face_painter.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const WatchApp());
}

class WatchApp extends StatelessWidget {
  const WatchApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const WatchFaceScreen(),
    );
  }
}

class WatchFaceScreen extends StatefulWidget {
  const WatchFaceScreen({super.key});

  @override
  State<WatchFaceScreen> createState() => _WatchFaceScreenState();
}

class _WatchFaceScreenState extends State<WatchFaceScreen> {
  WatchFaceConfig _config = WatchFaceConfig.defaultConfig();
  DateTime _now = DateTime.now();

  Timer? _clockTimer;
  Timer? _configTimer;

  @override
  void initState() {
    super.initState();
    _loadConfig();

    // Tick the clock every second
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });

    // Poll SharedPreferences for config changes every 2 seconds
    _configTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      _loadConfig();
    });
  }

  Future<void> _loadConfig() async {
    final config = await WatchFaceConfig.load();
    if (mounted && config != _config) {
      setState(() => _config = config);
    }
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    _configTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WatchShape(
        builder: (context, shape, child) {
          return AmbientMode(
            builder: (context, mode, child) {
              // Simplify rendering in ambient mode to save battery
              final effectiveConfig = mode == WearMode.ambient
                  ? _config.copyWith(
                      showSteps: false,
                      showBattery: false,
                      borderStyle: 'none',
                    )
                  : _config;

              return SizedBox.expand(
                child: CustomPaint(
                  painter: WatchFacePainter(
                    config: effectiveConfig,
                    time: _now,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
