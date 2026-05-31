import 'dart:ui';
import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color primaryColor = Color(0xFF6C63FF);
  static const Color primaryDark = Color(0xFF5554E2);
  static const Color primaryLight = Color(0xFF8B7FFF);

  // Background Colors
  static const Color bgDark = Color(0xFF0A0A0F);
  static const Color bgDarker = Color(0xFF050508);
  static const Color surfaceColor = Color(0xFF12121A);
  static const Color surfaceLighter = Color(0xFF1A1A2E);

  // Accent Colors
  static const Color accentNeon = Color(0xFF00FF88);
  static const Color accentOrange = Color(0xFFFF6B35);
  static const Color accentPink = Color(0xFFFF006E);
  static const Color accentCyan = Color(0xFF00D9FF);

  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0C0);
  static const Color textTertiary = Color(0xFF6B6B7B);

  // Semantic Colors
  static const Color successColor = Color(0xFF00D084);
  static const Color warningColor = Color(0xFFFFB700);
  static const Color errorColor = Color(0xFFFF3B30);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primaryColor],
  );

  static const LinearGradient neonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentNeon, accentCyan],
  );

  static const RadialGradient bgGradient = RadialGradient(
    center: Alignment.topCenter,
    radius: 1.5,
    colors: [
      Color(0xFF1A1A2E),
      bgDark,
    ],
  );
}

class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double borderRadius;
  final Color? backgroundColor;
  final Border? border;
  final List<BoxShadow>? boxShadow;
  final LinearGradient? gradient;
  final VoidCallback? onTap;

  const ModernCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 20,
    this.backgroundColor,
    this.border,
    this.boxShadow,
    this.gradient,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: border,
          gradient: gradient,
          boxShadow: boxShadow ??
              [
                BoxShadow(
                  color: Colors.black.withAlpha(30),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
        ),
        child: child,
      ),
    );
  }
}

class ModernButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Color? backgroundColor;
  final LinearGradient? gradient;
  final IconData? icon;
  final double? width;
  final double height;

  const ModernButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.backgroundColor,
    this.gradient,
    this.icon,
    this.width,
    this.height = 48,
  });

  @override
  State<ModernButton> createState() => _ModernButtonState();
}

class _ModernButtonState extends State<ModernButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.isEnabled && !widget.isLoading ? widget.onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          gradient: widget.gradient ?? AppTheme.primaryGradient,
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _isPressed
              ? []
              : [
                  BoxShadow(
                    color: AppTheme.primaryColor.withAlpha(60),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Opacity(
          opacity: widget.isEnabled ? 1.0 : 0.5,
          child: Material(
            color: Colors.transparent,
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      height: widget.height - 16,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon,
                              color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class ModernChip extends StatefulWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool> onSelected;
  final IconData? icon;
  final Color? selectedColor;

  const ModernChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    this.icon,
    this.selectedColor,
  });

  @override
  State<ModernChip> createState() => _ModernChipState();
}

class _ModernChipState extends State<ModernChip> {
  late bool _isSelected;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.isSelected;
  }

  @override
  void didUpdateWidget(ModernChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    _isSelected = widget.isSelected;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() => _isSelected = !_isSelected);
        widget.onSelected(_isSelected);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: _isSelected
              ? (widget.selectedColor ?? AppTheme.primaryColor).withAlpha(40)
              : AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isSelected
                ? (widget.selectedColor ?? AppTheme.primaryColor)
                : Colors.white.withAlpha(30),
            width: _isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                size: 16,
                color: _isSelected
                    ? (widget.selectedColor ?? AppTheme.primaryColor)
                    : AppTheme.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              widget.label,
              style: TextStyle(
                color: _isSelected
                    ? (widget.selectedColor ?? AppTheme.primaryColor)
                    : AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: _isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GlassEffect extends StatelessWidget {
  final Widget child;
  final double opacity;
  final double blur;
  final BorderRadius? borderRadius;

  const GlassEffect({
    super.key,
    required this.child,
    this.opacity = 0.1,
    this.blur = 10,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((opacity * 255).toInt()),
            borderRadius: borderRadius ?? BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withAlpha(50),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
