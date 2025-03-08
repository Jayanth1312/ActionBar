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
}
