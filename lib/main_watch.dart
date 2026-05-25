import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'models/watch_face_config.dart';
import 'widgets/watch_face_painter.dart';

/// The phone app runs a sync server on port 8080.
/// From the Android emulator, 10.0.2.2 reaches the host machine's localhost,
/// which is where the iOS simulator (or Android phone emulator) is running.
const _syncUrl = 'http://10.0.2.2:8080/';

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
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
      home: const WatchFaceScreen(),
    );
  }
}

class WatchFaceScreen extends StatefulWidget {
  const WatchFaceScreen({super.key});

  @override
  State<WatchFaceScreen> createState() => _WatchFaceScreenState();
}

class _WatchFaceScreenState extends State<WatchFaceScreen>
    with WidgetsBindingObserver {
  WatchFaceConfig _config = WatchFaceConfig.defaultConfig();
  DateTime _now = DateTime.now();

  Timer? _clockTimer;
  Timer? _configTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _fetchConfig();

    // Tick the clock every second
    _clockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted) setState(() => _now = DateTime.now());
      },
    );

    // Poll the phone's sync server every 2 seconds
    _configTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _fetchConfig(),
    );
  }

  Future<void> _fetchConfig() async {
    WatchFaceConfig? config;

    // 1. Try the phone's HTTP sync server first (works across devices)
    try {
      final response = await http
          .get(Uri.parse(_syncUrl))
          .timeout(const Duration(milliseconds: 800));
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body) as Map<String, dynamic>;
        config = WatchFaceConfig.fromJson(json);
      }
    } catch (_) {
      // Server unreachable — fall through to SharedPreferences
    }

    // 2. Fallback: SharedPreferences (works if both apps on same device)
    config ??= await WatchFaceConfig.load();

    if (mounted && config != _config) {
      setState(() => _config = config!);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _fetchConfig();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clockTimer?.cancel();
    _configTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: CustomPaint(
          painter: WatchFacePainter(config: _config, time: _now),
        ),
      ),
    );
  }
}
