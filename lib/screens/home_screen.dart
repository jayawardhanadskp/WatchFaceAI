import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/watch_face_provider.dart';
import '../services/color_extraction_service.dart';
import '../widgets/modern_design.dart';
import '../widgets/wallpaper_picker.dart';
import '../widgets/watch_preview_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _promptController = TextEditingController();
  final _focusNode = FocusNode();

  int _selectedStyle = 0;
  String _selectedClock = 'Auto';
  String _selectedFormat = 'Auto';
  bool _inputFocused = false;

  File? _wallpaperFile;
  Gradient? _backgroundGradient;

  static const _styleLabels = ['Minimal', 'Bold', 'Neon', 'Classic'];
  static const _styleIcons = [
    Icons.crop_square_rounded,
    Icons.format_bold,
    Icons.electric_bolt,
    Icons.access_time,
  ];
  static const _clockTypes = ['Auto', 'Digital', 'Analog'];
  static const _timeFormats = ['Auto', '12h', '24h'];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() => _inputFocused = _focusNode.hasFocus);
    });
    _backgroundGradient = AppTheme.bgGradient;
  }

  @override
  void dispose() {
    _promptController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _pickWallpaper() async {
    final file = await WallpaperPicker.showWallpaperDialog(context);
    if (file != null) {
      setState(() => _wallpaperFile = file);
      final palette = await ColorExtractionService.extractColorsFromImageProvider(
        FileImage(file),
      );
      setState(() {
        _backgroundGradient = ColorExtractionService.generateGradient(palette);
      });
    }
  }

  void _submit() {
    final raw = _promptController.text.trim();
    if (raw.isEmpty) return;

    var full = '$raw — style: ${_getStyleHint(_selectedStyle)}';
    if (_selectedClock != 'Auto') {
      full += ' — strictly set clockType to ${_selectedClock.toLowerCase()}';
    }
    if (_selectedFormat != 'Auto') {
      full += ' — strictly set timeFormat to ${_selectedFormat.toLowerCase()}';
    }

    ref.read(watchFaceProvider.notifier).generate(full);
    _focusNode.unfocus();
  }

  String _getStyleHint(int index) {
    const hints = [
      'clean and minimal design, simple elements, monochrome palette',
      'bold design, high contrast, strong typography, vivid colors',
      'neon glowing colors, cyberpunk aesthetic, electric vibes',
      'classic elegant watch design, traditional, timeless, sophisticated',
    ];
    return hints[index];
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(watchFaceProvider);
    final config = state.currentConfig;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: _backgroundGradient ?? AppTheme.bgGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ──
              _buildHeader(),

              // ── Watch Preview ──
              Expanded(
                flex: 5,
                child: Center(
                  child: WatchPreviewWidget(config: config, size: 200)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .moveY(
                        begin: -6,
                        end: 6,
                        duration: 2400.ms,
                        curve: Curves.easeInOut,
                      )
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .scale(begin: const Offset(0.88, 0.88), duration: 400.ms),
                ),
              ),

              // ── Style Picker ──
              Expanded(
                flex: 3,
                child: _buildStyleSection(),
              ),

              // ── Clock Type + Time Format ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildClockFormatSection(),
              ),

              const SizedBox(height: 14),

              // ── Wallpaper Row ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildWallpaperRow(),
              ),

              const SizedBox(height: 14),

              // ── Divider ──
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  color: Colors.white10,
                  thickness: 1,
                  height: 1,
                ),
              ),

              const SizedBox(height: 14),

              // ── Error Banner ──
              if (state.errorMessage != null) ...[
                _buildErrorBanner(state.errorMessage!),
                const SizedBox(height: 10),
              ],

              // ── Prompt Input ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: _buildPromptInput(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── HEADER ──────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: AppTheme.primaryGradient,
            ),
            child: const Icon(Icons.watch, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'WatchFace AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
              Text(
                'POWERED BY GEMINI',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primaryColor.withAlpha(100),
              ),
            ),
            child: const Text(
              'AI',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.2, end: 0);
  }

  // ── STYLE SECTION ────────────────────────────────────────

  Widget _buildStyleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'WATCH STYLE',
            style: TextStyle(
              color: Colors.white24,
              fontSize: 10,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(_styleLabels.length, (i) {
              final isSelected = i == _selectedStyle;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedStyle = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: isSelected
                          ? AppTheme.primaryColor.withAlpha(40)
                          : Colors.white.withAlpha(13),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryColor.withAlpha(130)
                            : Colors.white.withAlpha(15),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _styleIcons[i],
                          size: 20,
                          color: isSelected
                              ? AppTheme.primaryColor
                              : Colors.white38,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _styleLabels[i],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isSelected
                                ? AppTheme.primaryColor
                                : Colors.white38,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: (80 * i).ms, duration: 300.ms)
                    .slideY(begin: 0.2, end: 0),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── CLOCK + FORMAT ───────────────────────────────────────

  Widget _buildClockFormatSection() {
    return Row(
      children: [
        Expanded(child: _buildSegmentBox(
          label: 'CLOCK TYPE',
          options: _clockTypes,
          selected: _selectedClock,
          onSelect: (v) => setState(() => _selectedClock = v),
        )),
        const SizedBox(width: 10),
        Expanded(child: _buildSegmentBox(
          label: 'TIME FORMAT',
          options: _timeFormats,
          selected: _selectedFormat,
          onSelect: (v) => setState(() => _selectedFormat = v),
        )),
      ],
    )
        .animate()
        .fadeIn(delay: 150.ms, duration: 350.ms)
        .slideY(begin: 0.15, end: 0);
  }

  Widget _buildSegmentBox({
    required String label,
    required List<String> options,
    required String selected,
    required ValueChanged<String> onSelect,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withAlpha(10),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white24,
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 30,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white.withAlpha(8),
            ),
            child: Row(
              children: options.map((opt) {
                final isActive = opt == selected;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onSelect(opt),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: isActive
                            ? AppTheme.primaryColor.withAlpha(60)
                            : Colors.transparent,
                      ),
                      child: Text(
                        opt,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive
                              ? const Color(0xFF818CF8)
                              : Colors.white30,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── WALLPAPER ROW ────────────────────────────────────────

  Widget _buildWallpaperRow() {
    return GestureDetector(
      onTap: _wallpaperFile != null
          ? () => setState(() {
                _wallpaperFile = null;
                _backgroundGradient = AppTheme.bgGradient;
              })
          : _pickWallpaper,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white.withAlpha(10),
          border: Border.all(
            color: _wallpaperFile != null
                ? AppTheme.primaryColor.withAlpha(80)
                : Colors.white.withAlpha(15),
            style: _wallpaperFile != null
                ? BorderStyle.solid
                : BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            // Thumbnail or placeholder icon
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: _wallpaperFile != null
                  ? Image.file(
                      _wallpaperFile!,
                      width: 38,
                      height: 38,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: AppTheme.primaryColor.withAlpha(25),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        color: AppTheme.primaryColor,
                        size: 18,
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _wallpaperFile != null
                        ? 'Wallpaper Applied'
                        : 'Add Wallpaper',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _wallpaperFile != null
                        ? 'Tap to remove'
                        : 'Extract colors from your image',
                    style: const TextStyle(
                      color: Colors.white30,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              _wallpaperFile != null ? Icons.close : Icons.chevron_right,
              color: Colors.white24,
              size: 18,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms, duration: 350.ms)
        .slideY(begin: 0.15, end: 0);
  }

  // ── ERROR BANNER ─────────────────────────────────────────

  Widget _buildErrorBanner(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppTheme.errorColor.withAlpha(20),
          border: Border.all(color: AppTheme.errorColor.withAlpha(80)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline,
                color: AppTheme.errorColor, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppTheme.errorColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── PROMPT INPUT ─────────────────────────────────────────

  Widget _buildPromptInput() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: AppTheme.surfaceColor,
        border: Border.all(
          color: _inputFocused
              ? AppTheme.primaryColor.withAlpha(180)
              : Colors.white.withAlpha(25),
          width: _inputFocused ? 1.5 : 1,
        ),
        boxShadow: _inputFocused
            ? [
                BoxShadow(
                  color: AppTheme.primaryColor.withAlpha(50),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _promptController,
              focusNode: _focusNode,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _submit(),
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              decoration: const InputDecoration(
                hintText: 'Describe your watch face design…',
                hintStyle: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 13,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: _submit,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  gradient: AppTheme.primaryGradient,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 17,
                ),
              )
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(
                    duration: 2200.ms,
                    color: Colors.white.withAlpha(80),
                  ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 250.ms, duration: 400.ms)
        .slideY(begin: 0.2, end: 0);
  }
}