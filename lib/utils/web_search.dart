import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WebSearch {
  /// Performs a web search using the provided query
  static Future<bool> performWebSearch(String query) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final Uri url =
          Uri.parse('https://www.google.com/search?q=$encodedQuery');

      debugPrint('Attempting to launch URL: $url');

      if (await canLaunchUrl(url)) {
        await launchUrl(
          url,
          mode: LaunchMode.externalApplication,
        );
        return true;
      } else {
        debugPrint('Could not launch URL: $url');
        return false;
      }
    } catch (e) {
      debugPrint('Error launching URL: $e');
      return false;
    }
  }
}
