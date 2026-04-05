import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/watch_face_provider.dart';
import '../widgets/watch_preview_widget.dart';

const _kAccent = Color(0xFF6C63FF);
const _kBg = Color(0xFF0A0A0F);
const _kSurface = Color(0xFF12121A);

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(watchFaceProvider);
    final variants = state.variants;
    final selectedIdx = state.selectedVariantIndex;
    final selectedConfig = state.selectedVariant;

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
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
                    icon: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white70, size: 20),
                  ),
                  const Expanded(
                    child: Text(
                      'Choose a Design',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 44),
                ],
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .slideY(begin: -0.2, end: 0),

            // ── Large watch preview ──
            Expanded(
              child: Center(
                child: WatchPreviewWidget(
                  key: ValueKey(selectedIdx),
                  config: selectedConfig,
                  size: 220,
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
                  _InfoChip(label: selectedConfig.layout.toUpperCase(),
                      icon: Icons.view_quilt_outlined),
                  _InfoChip(label: selectedConfig.fontStyle.toUpperCase(),
                      icon: Icons.text_fields),
                  _InfoChip(label: selectedConfig.borderStyle.toUpperCase(),
                      icon: Icons.border_style),
                  if (selectedConfig.showDate)
                    const _InfoChip(label: 'DATE', icon: Icons.calendar_today_outlined),
                  if (selectedConfig.showSteps)
                    const _InfoChip(label: 'STEPS', icon: Icons.directions_walk),
                  if (selectedConfig.showBattery)
                    const _InfoChip(label: 'BATTERY', icon: Icons.battery_5_bar),
                ],
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms),
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
                  separatorBuilder: (context, index) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    final isSelected = i == selectedIdx;
                    return GestureDetector(
                      onTap: () =>
                          ref.read(watchFaceProvider.notifier).selectVariant(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? _kAccent
                                : Colors.white.withAlpha(30),
                            width: isSelected ? 2.5 : 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: _kAccent.withAlpha(100),
                                    blurRadius: 12,
                                    spreadRadius: 2,
                                  )
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

            // ── Apply button ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: _ApplyButton(
                onTap: () =>
                    ref.read(watchFaceProvider.notifier).applyToWatch(),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 400.ms)
                  .slideY(begin: 0.3, end: 0),
            ),
          ],
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
        color: _kSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: _kAccent),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
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
          gradient: const LinearGradient(
            colors: [Color(0xFF8B7FFF), _kAccent],
          ),
          boxShadow: [
            BoxShadow(
              color: _kAccent.withAlpha(100),
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
