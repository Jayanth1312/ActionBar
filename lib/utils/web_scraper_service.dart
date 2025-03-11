import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;

class WebScrapingResult {
  final String title;
  final String description;
  final String url;
  final String? faviconUrl;

  WebScrapingResult({
    required this.title,
    required this.description,
    required this.url,
    this.faviconUrl,
  });
}

class WebScraperService {
  static String extractFaviconUrl(String url) {
    try {
      final uri = Uri.parse(url.startsWith('http') ? url : 'https://$url');
      return '${uri.scheme}://${uri.host}/favicon.ico';
    } catch (e) {
      return '';
    }
  }

  static Future<List<WebScrapingResult>> scrapeTopResults(String query) async {
    try {
      final searchUrl =
          'https://html.duckduckgo.com/html/?q=${Uri.encodeComponent(query)}';
      final response = await http.get(
        Uri.parse(searchUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        },
      );

      if (response.statusCode == 200) {
        final document = parser.parse(response.body);
        final results = <WebScrapingResult>[];

        final searchResults = document.getElementsByClassName('result');

        for (var i = 0; i < searchResults.length && i < 3; i++) {
          final result = searchResults[i];

          final titleElement = result.querySelector('.result__title');
          final descElement = result.querySelector('.result__snippet');
          final linkElement = result.querySelector('.result__url');

          if (titleElement != null) {
            final title = titleElement.text.trim();
            final description =
                descElement?.text.trim() ?? 'No description available';
            final url = linkElement?.text.trim() ?? '';

            if (title.isNotEmpty) {
              results.add(WebScrapingResult(
                title: title,
                description: description,
                url: url.startsWith('http') ? url : 'https://$url',
                faviconUrl: extractFaviconUrl(url),
              ));
            }
          }
        }

        if (results.isEmpty) {
          results.add(WebScrapingResult(
            title: 'No results found',
            description: 'Try a different search query',
            url: '',
          ));
        }

        return results;
      }
      throw Exception('Failed to load search results');
    } catch (e) {
      print('Scraping error: $e');
      throw Exception('Error scraping web results: $e');
    }
  }
}
