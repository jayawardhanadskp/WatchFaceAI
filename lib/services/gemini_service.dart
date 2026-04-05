import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/watch_face_config.dart';

// Replace with your Gemini API key from https://aistudio.google.com
const _apiKey = 'YOUR_GEMINI_API_KEY';

const _baseUrl =
    'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

const _systemPrompt =
    'You are a watch face designer. Given a user\'s description, return ONLY a valid JSON object with these fields:\n'
    '{\n'
    '  "backgroundColor": hex string,\n'
    '  "timeColor": hex string,\n'
    '  "accentColor": hex string,\n'
    '  "showSteps": boolean,\n'
    '  "showBattery": boolean,\n'
    '  "showDate": boolean,\n'
    '  "fontStyle": "thin" | "normal" | "bold",\n'
    '  "layout": "minimal" | "info" | "sport",\n'
    '  "borderStyle": "none" | "ring" | "square"\n'
    '}\n'
    'No explanation, no markdown, just the JSON.';

class GeminiService {
  /// Returns up to 3 design variants for the given [prompt].
  Future<List<WatchFaceConfig>> generateVariants(String prompt) async {
    final variantPrompts = [
      prompt,
      '$prompt — Variant 2: try a different color palette',
      '$prompt — Variant 3: try an alternative layout style',
    ];

    final futures = variantPrompts.map(_generate);
    final results = await Future.wait(futures);
    return results.whereType<WatchFaceConfig>().toList();
  }

  Future<WatchFaceConfig?> _generate(String prompt) async {
    final url = Uri.parse('$_baseUrl?key=$_apiKey');

    final requestBody = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': '$_systemPrompt\n\nUser description: $prompt'}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.85,
        'maxOutputTokens': 512,
      },
    });

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: requestBody,
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        throw Exception(
            'Gemini API returned ${response.statusCode}: ${response.body}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) return null;

      final text =
          candidates[0]['content']['parts'][0]['text'] as String? ?? '';

      // Strip markdown code fences if present
      final cleaned = text
          .replaceAll(RegExp(r'```json\s*', caseSensitive: false), '')
          .replaceAll(RegExp(r'```\s*'), '')
          .trim();

      final json = jsonDecode(cleaned) as Map<String, dynamic>;
      return WatchFaceConfig.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}
