import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static String get apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String apiEndpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';

  static Future<String> getSummary(List<String> descriptions) async {
    try {
      final prompt = '''
Summarize the following information within 200 words:
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
        return data['candidates'][0]['content']['parts'][0]['text'] as String;
      } else {
        throw Exception('Failed to get summary: ${response.statusCode}');
      }
    } catch (e) {
      print('Gemini API error: $e');
      return descriptions.join(' ');
    }
  }
}
