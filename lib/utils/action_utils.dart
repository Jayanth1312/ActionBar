import 'package:url_launcher/url_launcher.dart';

class ActionUtils {
  //Email
  static Future<void> sendEmail(String text) async {
    final parts = text.split(' ');
    if (parts.length < 2) {
      print("Invalid email format! Use: @m user@example.com Subject Message");
      return;
    }

    final email = parts[0];
    final subjectMessage = parts.sublist(1).join(' ');

    try {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: email,
        query: 'subject=${Uri.encodeComponent(subjectMessage)}',
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        print("Could not open mail app.");
      }
    } catch (e) {
      print("Error opening mail app: $e");
    }
  }

  static Future<void> searchYouTube(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = 'https://www.youtube.com/results?search_query=$encodedQuery';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}
