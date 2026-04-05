import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/watch_face_provider.dart';
import '../widgets/watch_preview_widget.dart';

const _kAccent = Color(0xFF6C63FF);
const _kBg = Color(0xFF0A0A0F);
const _kSurface = Color(0xFF12121A);

const _kStyleLabels = ['Minimal', 'Bold', 'Neon', 'Classic'];
const _kStyleHints = [
  'clean and minimal design, simple elements, monochrome palette',
  'bold design, high contrast, strong typography, vivid colors',
  'neon glowing colors, cyberpunk aesthetic, electric vibes',
  'classic elegant watch design, traditional, timeless, sophisticated',
];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _promptController = TextEditingController();
  final _focusNode = FocusNode();
  int _selectedStyle = 0;
  bool _inputFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _inputFocused = _focusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _promptController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit() {
    final raw = _promptController.text.trim();
    if (raw.isEmpty) return;
    final full = '$raw — style: ${_kStyleHints[_selectedStyle]}';
    ref.read(watchFaceProvider.notifier).generate(full);
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(watchFaceProvider);
    final config = state.currentConfig;

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──
            _Header(),

            // ── Watch preview + style chips ──
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Floating watch preview
                      WatchPreviewWidget(config: config, size: 200)
                          .animate(
                            onPlay: (c) => c.repeat(reverse: true),
                          )
                          .moveY(
                            begin: -6,
                            end: 6,
                            duration: 2400.ms,
                            curve: Curves.easeInOut,
                          )
                          .animate()
                          .fadeIn(duration: 600.ms)
                          .scale(begin: const Offset(0.85, 0.85), duration: 500.ms),

                      const SizedBox(height: 28),

                      // Style chips
                      _StyleChips(
                        selected: _selectedStyle,
                        onSelected: (i) => setState(() => _selectedStyle = i),
                      )
                          .animate()
                          .fadeIn(delay: 200.ms, duration: 400.ms)
                          .slideY(begin: 0.2, end: 0),
                    ],
                  ),
                ),
              ),
            ),

            // ── Error banner ──
            if (state.errorMessage != null)
              _ErrorBanner(message: state.errorMessage!)
                  .animate()
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.3, end: 0),

            // ── Prompt input ──
            _PromptInput(
              controller: _promptController,
              focusNode: _focusNode,
              focused: _inputFocused,
              onSubmit: _submit,
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms)
                .slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }
}

// ─── Sub-widgets ────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [_kAccent, Color(0xFF9C5CFF)],
              ),
            ),
            child: const Icon(Icons.watch, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          const Text(
            'WatchFace AI',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: _kAccent.withAlpha(80)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Gemini',
              style: TextStyle(
                  color: _kAccent, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _StyleChips extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelected;

  const _StyleChips({required this.selected, required this.onSelected});

  static const _labels = _kStyleLabels;
  static const _icons = [
    Icons.crop_square_rounded,
    Icons.format_bold,
    Icons.electric_bolt,
    Icons.access_time,
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _labels.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final isSelected = i == selected;
          return GestureDetector(
            onTap: () => onSelected(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? _kAccent.withAlpha(40)
                    : _kSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? _kAccent : Colors.white.withAlpha(20),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_icons[i],
                      size: 14,
                      color: isSelected ? _kAccent : Colors.white54),
                  const SizedBox(width: 5),
                  Text(
                    _labels[i],
                    style: TextStyle(
                      color: isSelected ? _kAccent : Colors.white60,
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PromptInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool focused;
  final VoidCallback onSubmit;

  const _PromptInput({
    required this.controller,
    required this.focusNode,
    required this.focused,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: focused ? _kAccent.withAlpha(180) : Colors.white.withAlpha(20),
            width: focused ? 1.5 : 1,
          ),
          boxShadow: focused
              ? [
                  BoxShadow(
                    color: _kAccent.withAlpha(60),
                    blurRadius: 18,
                    spreadRadius: 0,
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSubmit(),
                style: const TextStyle(
                    color: Colors.white, fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Describe your watch face...',
                  hintStyle:
                      TextStyle(color: Colors.white38, fontSize: 15),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 20, vertical: 14),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _SendButton(onTap: onSubmit),
            ),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  final VoidCallback onTap;

  const _SendButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8B7FFF), _kAccent],
          ),
        ),
        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
      )
          .animate(onPlay: (c) => c.repeat())
          .shimmer(
            duration: 2000.ms,
            color: Colors.white.withAlpha(80),
          ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;

  const _ErrorBanner({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.redAccent.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withAlpha(80)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.redAccent, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.redAccent, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
