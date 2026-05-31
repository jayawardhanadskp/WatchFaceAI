import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

class ColorExtractionService {
  /// Extract dominant colors from an image
  static Future<ColorPalette> extractColorsFromImageProvider(
    ImageProvider imageProvider, {
    int numberOfColors = 5,
  }) async {
    try {
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        imageProvider,
        maximumColorCount: numberOfColors,
      );

      return ColorPalette(
        dominantColor: paletteGenerator.dominantColor?.color ?? Colors.grey,
        lightVibrant:
            paletteGenerator.lightVibrantColor?.color ?? Colors.white70,
        darkVibrant:
            paletteGenerator.darkVibrantColor?.color ?? Colors.grey[800]!,
        vibrant: paletteGenerator.vibrantColor?.color ?? Colors.blue,
        mutedColor: paletteGenerator.mutedColor?.color ?? Colors.grey[600],
        colors: paletteGenerator.colors.toList(),
      );
    } catch (e) {
      return ColorPalette.fallback();
    }
  }

  /// Generate a beautiful gradient from extracted colors
  static Gradient generateGradient(ColorPalette palette) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        palette.darkVibrant.withAlpha((0.3 * 255).toInt()),
        palette.vibrant.withAlpha((0.15 * 255).toInt()),
        palette.dominantColor.withAlpha((0.25 * 255).toInt()),
      ],
    );
  }

  /// Generate a radial gradient from extracted colors
  static Gradient generateRadialGradient(ColorPalette palette) {
    return RadialGradient(
      center: Alignment.topCenter,
      radius: 1.5,
      colors: [
        palette.lightVibrant.withAlpha((0.2 * 255).toInt()),
        palette.dominantColor.withAlpha((0.15 * 255).toInt()),
      ],
    );
  }

  /// Get contrasting text color based on background color
  static Color getContrastingTextColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }

  /// Blend two colors
  static Color blendColors(Color color1, Color color2, double ratio) {
    return Color.lerp(color1, color2, ratio) ?? color1;
  }
}

class ColorPalette {
  final Color dominantColor;
  final Color lightVibrant;
  final Color darkVibrant;
  final Color vibrant;
  final Color? mutedColor;
  final List<Color> colors;

  ColorPalette({
    required this.dominantColor,
    required this.lightVibrant,
    required this.darkVibrant,
    required this.vibrant,
    this.mutedColor,
    required this.colors,
  });

  factory ColorPalette.fallback() {
    return ColorPalette(
      dominantColor: const Color(0xFF0A0A0F),
      lightVibrant: Colors.white70,
      darkVibrant: Colors.grey[800]!,
      vibrant: const Color(0xFF6C63FF),
      mutedColor: Colors.grey[600],
      colors: [
        const Color(0xFF0A0A0F),
        const Color(0xFF6C63FF),
        Colors.white,
      ],
    );
  }

  Color getAccentColor() => vibrant;

  Color getBackgroundColor() => dominantColor;

  Color getTextColor() =>
      ColorExtractionService.getContrastingTextColor(dominantColor);
}
