import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/watch_face_config.dart';
import '../services/gemini_service.dart';
import '../services/sync_server.dart';

enum AppScreen { home, generating, result }

class WatchFaceState {
  final WatchFaceConfig currentConfig;
  final List<WatchFaceConfig> variants;
  final int selectedVariantIndex;
  final AppScreen screen;
  final String? errorMessage;

  const WatchFaceState({
    required this.currentConfig,
    this.variants = const [],
    this.selectedVariantIndex = 0,
    this.screen = AppScreen.home,
    this.errorMessage,
  });

  WatchFaceConfig get selectedVariant =>
      variants.isNotEmpty ? variants[selectedVariantIndex] : currentConfig;

  WatchFaceState copyWith({
    WatchFaceConfig? currentConfig,
    List<WatchFaceConfig>? variants,
    int? selectedVariantIndex,
    AppScreen? screen,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WatchFaceState(
      currentConfig: currentConfig ?? this.currentConfig,
      variants: variants ?? this.variants,
      selectedVariantIndex: selectedVariantIndex ?? this.selectedVariantIndex,
      screen: screen ?? this.screen,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class WatchFaceNotifier extends StateNotifier<WatchFaceState> {
  final GeminiService _gemini;

  WatchFaceNotifier(this._gemini)
      : super(const WatchFaceState(
            currentConfig: WatchFaceConfig(
          backgroundColor: '#0A0A0F',
          timeColor: '#FFFFFF',
          accentColor: '#6C63FF',
          showSteps: true,
          showBattery: true,
          showDate: true,
          fontStyle: 'normal',
          layout: 'minimal',
          borderStyle: 'ring',
        ))) {
    _loadSaved();
  }

  Future<void> _loadSaved() async {
    final config = await WatchFaceConfig.load();
    if (mounted) state = state.copyWith(currentConfig: config);
  }

  Future<void> generate(String prompt) async {
    state = state.copyWith(
      screen: AppScreen.generating,
      clearError: true,
    );

    try {
      final variants = await _gemini.generateVariants(prompt);
      if (!mounted) return;

      if (variants.isEmpty) {
        state = state.copyWith(
          screen: AppScreen.home,
          errorMessage:
              'Could not generate design. Check your Gemini API key.',
        );
        return;
      }

      state = state.copyWith(
        variants: variants,
        selectedVariantIndex: 0,
        screen: AppScreen.result,
        clearError: true,
      );
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          screen: AppScreen.home,
          errorMessage: e.toString().replaceFirst('Exception: ', ''),
        );
      }
    }
  }

  void selectVariant(int index) {
    if (index >= 0 && index < state.variants.length) {
      state = state.copyWith(selectedVariantIndex: index);
    }
  }

  Future<void> applyToWatch() async {
    if (state.variants.isEmpty) return;
    final config = state.variants[state.selectedVariantIndex];
    await config.save();
    // Push to the sync server so the watch receives it on its next poll
    SyncServer.instance.push(config);
    if (mounted) {
      state = state.copyWith(
        currentConfig: config,
        screen: AppScreen.home,
        clearError: true,
      );
    }
  }

  void goHome() {
    state = state.copyWith(screen: AppScreen.home, clearError: true);
  }
}

final _geminiServiceProvider = Provider<GeminiService>((_) => GeminiService());

final watchFaceProvider =
    StateNotifierProvider<WatchFaceNotifier, WatchFaceState>(
  (ref) => WatchFaceNotifier(ref.read(_geminiServiceProvider)),
);
