import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/watch_face_provider.dart';
import '../widgets/modern_design.dart';
import '../widgets/watch_preview_widget.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(watchFaceProvider);
    final variants = state.variants;
    final selectedIdx = state.selectedVariantIndex;
    final selectedConfig = state.selectedVariant;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF1A1A2E), AppTheme.bgDark],
            center: Alignment.center,
            radius: 1.5,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () =>
                          ref.read(watchFaceProvider.notifier).goHome(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Choose a Design',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 44),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),

              // ── Large watch preview ──
              Expanded(
                child: Center(
                  child:
                      WatchPreviewWidget(
                            key: ValueKey(selectedIdx),
                            config: selectedConfig,
                            size: 240, // Slightly larger!
                          )
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1, 1),
                            duration: 400.ms,
                            curve: Curves.easeOutBack,
                          ),
                ),
              ),

              // ── Design info chips ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _InfoChip(
                      label: selectedConfig.layout.toUpperCase(),
                      icon: Icons.view_quilt_outlined,
                    ),
                    _InfoChip(
                      label: selectedConfig.fontStyle.toUpperCase(),
                      icon: Icons.text_fields,
                    ),
                    _InfoChip(
                      label: selectedConfig.borderStyle.toUpperCase(),
                      icon: Icons.border_style,
                    ),
                    _InfoChip(
                      label: selectedConfig.clockType.toUpperCase(),
                      icon: Icons.watch_later_outlined,
                    ),
                    _InfoChip(
                      label: selectedConfig.timeFormat,
                      icon: Icons.schedule,
                    ),
                    if (selectedConfig.showDate)
                      const _InfoChip(
                        label: 'DATE',
                        icon: Icons.calendar_today_outlined,
                      ),
                    if (selectedConfig.showSteps)
                      const _InfoChip(
                        label: 'STEPS',
                        icon: Icons.directions_walk,
                      ),
                    if (selectedConfig.showBattery)
                      const _InfoChip(
                        label: 'BATTERY',
                        icon: Icons.battery_5_bar,
                      ),
                  ],
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
              ),

              const SizedBox(height: 20),

              // ── Variant selector ──
              if (variants.length > 1) ...[
                const Padding(
                  padding: EdgeInsets.only(left: 20, bottom: 10),
                  child: Text(
                    'VARIANTS',
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                SizedBox(
                  height: 84,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: variants.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final isSelected = i == selectedIdx;
                      return GestureDetector(
                            onTap: () => ref
                                .read(watchFaceProvider.notifier)
                                .selectVariant(i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : Colors.white.withAlpha(30),
                                  width: isSelected ? 2.5 : 1.5,
                                ),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.primaryColor
                                              .withAlpha(100),
                                          blurRadius: 12,
                                          spreadRadius: 2,
                                        ),
                                      ]
                                    : [],
                              ),
                              child: WatchPreviewWidget(
                                config: variants[i],
                                size: 68,
                                showGlow: false,
                              ),
                            ),
                          )
                          .animate()
                          .fadeIn(delay: (100 * i).ms, duration: 300.ms)
                          .scale(
                            begin: const Offset(0.7, 0.7),
                            duration: 300.ms,
                            curve: Curves.easeOutBack,
                          );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ── Edit button ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child:
                    _EditButton(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.transparent,
                              isScrollControlled: true,
                              builder: (context) => const _EditorSheet(),
                            );
                          },
                        )
                        .animate()
                        .fadeIn(delay: 250.ms, duration: 400.ms)
                        .slideY(begin: 0.3, end: 0),
              ),
              const SizedBox(height: 12),

              // ── Apply button ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                child:
                    _ApplyButton(
                          onTap: () => ref
                              .read(watchFaceProvider.notifier)
                              .applyToWatch(),
                        )
                        .animate()
                        .fadeIn(delay: 300.ms, duration: 400.ms)
                        .slideY(begin: 0.3, end: 0)
                        .shimmer(
                          duration: 2000.ms,
                          color: Colors.white.withAlpha(60),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _InfoChip({required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppTheme.primaryColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplyButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ApplyButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27),
          gradient: AppTheme.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withAlpha(100),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.watch, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Apply to Watch',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  final VoidCallback onTap;

  const _EditButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(27),
          color: Colors.white.withAlpha(15),
          border: Border.all(color: AppTheme.primaryColor.withAlpha(100)),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_note, color: AppTheme.primaryColor, size: 20),
            SizedBox(width: 10),
            Text(
              'Customize Layout',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditorSheet extends ConsumerWidget {
  const _EditorSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(watchFaceProvider);
    if (state.variants.isEmpty) return const SizedBox.shrink();
    final config = state.variants[state.selectedVariantIndex];

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgDark.withAlpha(220),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2.5),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Customize Details',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Fine-tune elements of the selected watch face dynamically.',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 24),

                // Clock type selection
                _buildSegment<String>(
                  title: 'CLOCK TYPE',
                  options: ['analog', 'digital'],
                  labels: ['Analog', 'Digital'],
                  selected: config.clockType,
                  onChanged: (val) {
                    ref
                        .read(watchFaceProvider.notifier)
                        .updateConfig(clockType: val);
                  },
                ),
                const SizedBox(height: 20),

                // Time Format selection
                _buildSegment<String>(
                  title: 'TIME FORMAT',
                  options: ['12h', '24h'],
                  labels: ['12 Hour', '24 Hour'],
                  selected: config.timeFormat,
                  onChanged: (val) {
                    ref
                        .read(watchFaceProvider.notifier)
                        .updateConfig(timeFormat: val);
                  },
                ),
                const SizedBox(height: 20),

                // Complications toggles
                const Text(
                  'COMPLICATIONS',
                  style: TextStyle(
                    color: AppTheme.textTertiary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                _ComplicationToggle(
                  label: 'Show Date',
                  icon: Icons.calendar_today_outlined,
                  value: config.showDate,
                  onChanged: (val) {
                    ref
                        .read(watchFaceProvider.notifier)
                        .updateConfig(showDate: val);
                  },
                ),
                const SizedBox(height: 10),
                _ComplicationToggle(
                  label: 'Show Step Counter',
                  icon: Icons.directions_walk,
                  value: config.showSteps,
                  onChanged: (val) {
                    ref
                        .read(watchFaceProvider.notifier)
                        .updateConfig(showSteps: val);
                  },
                ),
                const SizedBox(height: 10),
                _ComplicationToggle(
                  label: 'Show Battery Level',
                  icon: Icons.battery_5_bar,
                  value: config.showBattery,
                  onChanged: (val) {
                    ref
                        .read(watchFaceProvider.notifier)
                        .updateConfig(showBattery: val);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSegment<T>({
    required String title,
    required List<T> options,
    required List<String> labels,
    required T selected,
    required ValueChanged<T> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textTertiary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: List.generate(options.length, (idx) {
              final opt = options[idx];
              final isSelected = opt == selected;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(opt),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryColor
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      labels[idx],
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _ComplicationToggle extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ComplicationToggle({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primaryColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: AppTheme.primaryColor,
            activeTrackColor: AppTheme.primaryColor.withAlpha(80),
            inactiveThumbColor: Colors.white60,
            inactiveTrackColor: Colors.white.withAlpha(20),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
