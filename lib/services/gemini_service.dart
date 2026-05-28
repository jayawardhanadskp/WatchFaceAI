import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/watch_face_config.dart';

// Replace with your Gemini API key from https://aistudio.google.com
const _apiKey = 'AIzaSyBz9lsJ6oGAHIdGu1kjZcYuokLX3XgvAhA';

const _systemInstruction =
    'You are an elite premium watch face designer. Given a user\'s description, return ONLY a valid JSON object with these fields:\n'
    '{\n'
    '  "backgroundColor": hex string,\n'
    '  "timeColor": hex string,\n'
    '  "accentColor": hex string,\n'
    '  "showSteps": boolean,\n'
    '  "showBattery": boolean,\n'
    '  "showDate": boolean,\n'
    '  "fontStyle": "thin" | "normal" | "bold",\n'
    '  "layout": "minimal" | "info" | "sport",\n'
    '  "borderStyle": "none" | "ring" | "square",\n'
    '  "clockType": "digital" | "analog",\n'
    '  "timeFormat": "12h" | "24h",\n'
    '  "imagePrompt": "A highly detailed, beautiful visual prompt for an AI image generator (e.g. Midjourney) that serves as the watch face background. Describe the subject, lighting, mood, colors. MUST EXPLICITLY specify \'No text, no clocks, no numbers, perfectly centered background\' in the prompt to prevent the AI from generating fake clocks."\n'
    '}\n'
    'The "imagePrompt" is crucial and MUST be extremely creative and stunning. Do not include text or clocks in the generated image.\n'
    'No explanation, no markdown, no code fences — just the raw JSON object.';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(_systemInstruction),
      generationConfig: GenerationConfig(
        temperature: 0.85,
        maxOutputTokens: 8192,
      ),
    );
  }

  /// Returns up to 3 design variants. Throws on total failure so the UI
  /// can display the real error message.
  Future<List<WatchFaceConfig>> generateVariants(String prompt) async {
    // Generate the first variant; let any exception propagate to the caller
    final first = await _generateOrThrow(prompt);

    // Generate the remaining 4 variants in parallel; silently drop failures
    final rest = await Future.wait([
      _generateSilent('$prompt — Variant 2: different color palette'),
      _generateSilent('$prompt — Variant 3: alternative layout'),
      _generateSilent('$prompt — Variant 4: highly minimalist'),
      _generateSilent('$prompt — Variant 5: vibrant and bold'),
    ]);

    return [first, ...rest.whereType<WatchFaceConfig>()];
  }

  /// Generates one variant and throws on any error (used for the first variant).
  Future<WatchFaceConfig> _generateOrThrow(String prompt) async {
    final response = await _model.generateContent([Content.text(prompt)]);
    final text = response.text;
    if (text == null || text.isEmpty) {
      throw Exception('Gemini returned an empty response.');
    }
    return _parseConfig(text);
  }

  /// Generates one variant and returns null on error (used for extras).
  Future<WatchFaceConfig?> _generateSilent(String prompt) async {
    try {
      return await _generateOrThrow(prompt);
    } catch (_) {
      return null;
    }
  }

  WatchFaceConfig _parseConfig(String text) {
    // Strip markdown code fences if the model adds them despite instructions
    final cleaned = text
        .replaceAll(RegExp(r'```json\s*', caseSensitive: false), '')
        .replaceAll(RegExp(r'```\s*'), '')
        .trim();

    final dynamic decoded = jsonDecode(cleaned);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Expected a JSON object, got: $cleaned');
    }
    return WatchFaceConfig.fromJson(decoded);
  }
}
