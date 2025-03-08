import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'dart:io';

class WebSearch {
  static Future<bool> performWebSearch(String query) async {
    bool isUrl = _isUrl(query);

    try {
      if (isUrl) {
        return _launchUrl(query);
      } else if (Platform.isAndroid) {
        final AndroidIntent intent = AndroidIntent(
          action: 'android.intent.action.WEB_SEARCH',
          arguments: {'query': query},
          package: 'com.google.android.googlequicksearchbox',
        );
        await intent.launch();
        return true;
      } else {
        return _launchUrl(
            'https://www.google.com/search?q=${Uri.encodeComponent(query)}');
      }
    } catch (e) {
      print('Error launching search: $e');
      return false;
    }
  }

  static bool _isUrl(String text) {
    return text.toLowerCase().startsWith('www.') ||
        text.toLowerCase().startsWith('http://') ||
        text.toLowerCase().startsWith('https://');
  }

  static Future<bool> _launchUrl(String urlString) async {
    if (!urlString.toLowerCase().startsWith('http://') &&
        !urlString.toLowerCase().startsWith('https://')) {
      urlString = 'https://$urlString';
    }

    try {
      final Uri url = Uri.parse(urlString);
      return await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      print('Error parsing URL: $e');
      return false;
    }
  }
}
