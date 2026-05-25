import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/watch_face_provider.dart';
import 'screens/generating_screen.dart';
import 'screens/home_screen.dart';
import 'screens/result_screen.dart';
import 'services/sync_server.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  // Start the config sync server so the Wear OS watch can poll it
  await SyncServer.instance.start();
  runApp(const ProviderScope(child: WatchFacePhoneApp()));
}

class WatchFacePhoneApp extends StatelessWidget {
  const WatchFacePhoneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WatchFace AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0A0F),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          surface: Color(0xFF0A0A0F),
        ),
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screen = ref.watch(watchFaceProvider.select((s) => s.screen));

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.04),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey(screen),
        child: switch (screen) {
          AppScreen.home => const HomeScreen(),
          AppScreen.generating => const GeneratingScreen(),
          AppScreen.result => const ResultScreen(),
        },
      ),
    );
  }
}
