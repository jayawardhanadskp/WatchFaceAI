import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WatchFaceConfig {
  final String backgroundColor;
  final String timeColor;
  final String accentColor;
  final bool showSteps;
  final bool showBattery;
  final bool showDate;
  final String fontStyle; // 'thin' | 'normal' | 'bold'
  final String layout; // 'minimal' | 'info' | 'sport'
  final String borderStyle; // 'none' | 'ring' | 'square'
  final String? imagePrompt; // The descriptive prompt for AI image generation
  final String clockType; // 'digital' | 'analog'
  final String timeFormat; // '12h' | '24h'

  const WatchFaceConfig({
    required this.backgroundColor,
    required this.timeColor,
    required this.accentColor,
    required this.showSteps,
    required this.showBattery,
    required this.showDate,
    required this.fontStyle,
    required this.layout,
    required this.borderStyle,
    this.imagePrompt,
    required this.clockType,
    required this.timeFormat,
  });

  factory WatchFaceConfig.defaultConfig() {
    return const WatchFaceConfig(
      backgroundColor: '#0A0A0F',
      timeColor: '#FFFFFF',
      accentColor: '#6C63FF',
      showSteps: true,
      showBattery: true,
      showDate: true,
      fontStyle: 'normal',
      layout: 'minimal',
      borderStyle: 'ring',
      imagePrompt: 'a beautiful futuristic glowing neon city skyline at night, cyberpunk aesthetic, 4k highly detailed, cinematic lighting',
      clockType: 'digital',
      timeFormat: '24h',
    );
  }

  factory WatchFaceConfig.fromJson(Map<String, dynamic> json) {
    return WatchFaceConfig(
      backgroundColor: _sanitizeHex(json['backgroundColor'] as String?) ?? '#0A0A0F',
      timeColor: _sanitizeHex(json['timeColor'] as String?) ?? '#FFFFFF',
      accentColor: _sanitizeHex(json['accentColor'] as String?) ?? '#6C63FF',
      showSteps: json['showSteps'] as bool? ?? true,
      showBattery: json['showBattery'] as bool? ?? true,
      showDate: json['showDate'] as bool? ?? true,
      fontStyle: _validFont(json['fontStyle'] as String?) ?? 'normal',
      layout: _validLayout(json['layout'] as String?) ?? 'minimal',
      borderStyle: _validBorder(json['borderStyle'] as String?) ?? 'none',
      imagePrompt: json['imagePrompt'] as String?,
      clockType: _validClockType(json['clockType'] as String?) ?? 'digital',
      timeFormat: _validTimeFormat(json['timeFormat'] as String?) ?? '24h',
    );
  }

  Map<String, dynamic> toJson() => {
        'backgroundColor': backgroundColor,
        'timeColor': timeColor,
        'accentColor': accentColor,
        'showSteps': showSteps,
        'showBattery': showBattery,
        'showDate': showDate,
        'fontStyle': fontStyle,
        'layout': layout,
        'borderStyle': borderStyle,
        'imagePrompt': imagePrompt,
        'clockType': clockType,
        'timeFormat': timeFormat,
      };

  WatchFaceConfig copyWith({
    String? backgroundColor,
    String? timeColor,
    String? accentColor,
    bool? showSteps,
    bool? showBattery,
    bool? showDate,
    String? fontStyle,
    String? layout,
    String? borderStyle,
    String? imagePrompt,
    String? clockType,
    String? timeFormat,
  }) {
    return WatchFaceConfig(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      timeColor: timeColor ?? this.timeColor,
      accentColor: accentColor ?? this.accentColor,
      showSteps: showSteps ?? this.showSteps,
      showBattery: showBattery ?? this.showBattery,
      showDate: showDate ?? this.showDate,
      fontStyle: fontStyle ?? this.fontStyle,
      layout: layout ?? this.layout,
      borderStyle: borderStyle ?? this.borderStyle,
      imagePrompt: imagePrompt ?? this.imagePrompt,
      clockType: clockType ?? this.clockType,
      timeFormat: timeFormat ?? this.timeFormat,
    );
  }

  Color get backgroundColorValue => _parseColor(backgroundColor, Colors.black);
  Color get timeColorValue => _parseColor(timeColor, Colors.white);
  Color get accentColorValue => _parseColor(accentColor, const Color(0xFF6C63FF));

  static Color _parseColor(String? hex, Color fallback) {
    if (hex == null) return fallback;
    try {
      final cleaned = hex.replaceAll('#', '').trim();
      if (cleaned.length == 6) {
        return Color(int.parse('FF$cleaned', radix: 16));
      }
      if (cleaned.length == 8) {
        return Color(int.parse(cleaned, radix: 16));
      }
    } catch (_) {}
    return fallback;
  }

  static String? _sanitizeHex(String? value) {
    if (value == null) return null;
    final cleaned = value.trim().replaceAll('#', '');
    if (cleaned.length == 6 || cleaned.length == 8) {
      try {
        int.parse(cleaned, radix: 16);
        return '#$cleaned';
      } catch (_) {}
    }
    return null;
  }

  static String? _validFont(String? v) =>
      (v == 'thin' || v == 'normal' || v == 'bold') ? v : null;

  static String? _validLayout(String? v) =>
      (v == 'minimal' || v == 'info' || v == 'sport') ? v : null;

  static String? _validBorder(String? v) =>
      (v == 'none' || v == 'ring' || v == 'square') ? v : null;

  static String? _validClockType(String? v) =>
      (v == 'digital' || v == 'analog') ? v : null;

  static String? _validTimeFormat(String? v) =>
      (v == '12h' || v == '24h') ? v : null;

  static const String _prefsKey = 'watchface_config';

  static Future<WatchFaceConfig> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_prefsKey);
    if (jsonStr == null) return WatchFaceConfig.defaultConfig();
    try {
      return WatchFaceConfig.fromJson(
          jsonDecode(jsonStr) as Map<String, dynamic>);
    } catch (_) {
      return WatchFaceConfig.defaultConfig();
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(toJson()));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WatchFaceConfig &&
          other.backgroundColor == backgroundColor &&
          other.timeColor == timeColor &&
          other.accentColor == accentColor &&
          other.showSteps == showSteps &&
          other.showBattery == showBattery &&
          other.showDate == showDate &&
          other.fontStyle == fontStyle &&
          other.layout == layout &&
          other.borderStyle == borderStyle &&
          other.imagePrompt == imagePrompt &&
          other.clockType == clockType &&
          other.timeFormat == timeFormat;

  @override
  int get hashCode => Object.hash(
      backgroundColor,
      timeColor,
      accentColor,
      showSteps,
      showBattery,
      showDate,
      fontStyle,
      layout,
      borderStyle,
      imagePrompt,
      clockType,
      timeFormat);
}
