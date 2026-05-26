import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/watch_face_config.dart';

// Replace with your Gemini API key from https://aistudio.google.com
const _apiKey = 'AIzaSyB-zuqwyZ6slqQ7Id9FWc5aSsC2MFRLmQE';

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
    '  "imagePrompt": "A highly detailed, cinematic, and beautiful visual prompt for an AI image generator (e.g. Midjourney) that serves as the watch face background. Describe the subject, lighting, mood, colors, and 8k photorealistic quality in a comma separated prompt. Example: a glowing neon forest at night, deep purple and cyan bioluminescence, 4k, masterpiece"\n'
    '}\n'
    'The "imagePrompt" is crucial and MUST be extremely creative, visually stunning, and tailored to the vibe of the request.\n'
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

    // Generate the remaining 2 variants in parallel; silently drop failures
    final rest = await Future.wait([
      _generateSilent('$prompt — Variant 2: different color palette'),
      _generateSilent('$prompt — Variant 3: alternative layout'),
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
