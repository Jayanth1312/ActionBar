import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';

class WebScrapingResult {
  final String title;
  final String description;
  final String url;
  final String? faviconUrl;
  final String? fullContent;

  WebScrapingResult({
    required this.title,
    required this.description,
    required this.url,
    this.faviconUrl,
    this.fullContent,
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

  static Future<List<WebScrapingResult>> scrapeTopResults(String query,
      {int maxResults = 3}) async {
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
        final searchResults = document.getElementsByClassName('result');
        final topUrls = <String>[];

        for (var i = 0;
            i < searchResults.length && topUrls.length < maxResults;
            i++) {
          final result = searchResults[i];
          final linkElement = result.querySelector('.result__a');

          if (linkElement != null) {
            final href = linkElement.attributes['href'];
            if (href != null && href.isNotEmpty) {
              final uri = Uri.parse(href);
              final redirectParam = uri.queryParameters['uddg'];
              final url = redirectParam ?? href;

              if (url.startsWith('http')) {
                topUrls.add(url);
              }
            }
          }
        }
        final futures = topUrls.map((url) => _scrapeWebsite(url));
        final results = (await Future.wait(futures))
            .where((result) => result != null)
            .cast<WebScrapingResult>()
            .toList();

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

  static Future<WebScrapingResult?> _scrapeWebsite(String url) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36'
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final document = parser.parse(response.body);

        final title =
            document.querySelector('title')?.text.trim() ?? 'No title';

        String description = '';
        final metaDescription =
            document.querySelector('meta[name="description"]');
        if (metaDescription != null) {
          description = metaDescription.attributes['content'] ?? '';
        }

        if (description.isEmpty) {
          final firstParagraph = document.querySelector('p');
          if (firstParagraph != null) {
            description = firstParagraph.text.trim();
          }
        }

        final fullContent = _extractMainContent(document);

        return WebScrapingResult(
          title: title,
          description:
              description.isEmpty ? 'No description available' : description,
          url: url,
          faviconUrl: extractFaviconUrl(url),
          fullContent: fullContent,
        );
      }
      return null;
    } catch (e) {
      print('Error scraping website $url: $e');
      return null;
    }
  }

  static String _extractMainContent(Document document) {
    final contentSelectors = [
      'article',
      'main',
      '.content',
      '#content',
      '.post-content',
      '.article-content',
      '.entry-content',
      '.post',
      '#main-content'
    ];

    for (var selector in contentSelectors) {
      final contentElement = document.querySelector(selector);
      if (contentElement != null) {
        _removeElements(contentElement, 'script');
        _removeElements(contentElement, 'style');
        _removeElements(contentElement, 'nav');
        _removeElements(contentElement, 'header');
        _removeElements(contentElement, 'footer');
        _removeElements(contentElement, 'aside');

        return contentElement.text.trim();
      }
    }

    final paragraphs = document.querySelectorAll('p');
    if (paragraphs.isNotEmpty) {
      return paragraphs.map((p) => p.text.trim()).join('\n\n');
    }

    return document.body?.text.trim() ?? '';
  }

  static void _removeElements(Element parent, String selector) {
    parent.querySelectorAll(selector).forEach((element) {
      element.remove();
    });
  }
}
