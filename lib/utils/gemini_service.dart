import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static String get apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String apiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-lite:generateContent';

  static Future<String> getSummary(List<String> descriptions) async {
    try {
      final prompt = '''
Summarize the following information in 200 words of concise data. Make sure to end with a complete sentence:
${descriptions.join('\n')}
''';

      final response = await http.post(
        Uri.parse('$apiEndpoint?key=$apiKey'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          },
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String summary =
            data['candidates'][0]['content']['parts'][0]['text'] as String;

        summary = _ensureCompleteSentence(summary);

        return summary;
      } else {
        throw Exception('Failed to get summary: ${response.statusCode}');
      }
    } catch (e) {
      print('Gemini API error: $e');
      final combinedText = descriptions.join(' ');
      return _ensureCompleteSentence(combinedText.length > 150
          ? '${combinedText.substring(0, 150)}...'
          : combinedText);
    }
  }

  static String _ensureCompleteSentence(String text) {
    text = text.trim();

    if (text.endsWith('.') || text.endsWith('!') || text.endsWith('?')) {
      return text;
    }

    final lastPeriodIndex = text.lastIndexOf('.');
    final lastExclamationIndex = text.lastIndexOf('!');
    final lastQuestionIndex = text.lastIndexOf('?');

    final indices = [lastPeriodIndex, lastExclamationIndex, lastQuestionIndex]
        .where((index) => index > 0)
        .toList();

    if (indices.isEmpty) {
      return '$text.';
    }

    return text.substring(
        0, indices.reduce((max, index) => index > max ? index : max) + 1);
  }
}
