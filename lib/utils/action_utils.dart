import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'dart:io';

class ActionUtils {
  //Note
  static Future<bool> createNote(String title, String content) async {
    try {
      if (Platform.isAndroid) {
        try {
          final AndroidIntent intent = AndroidIntent(
            action: 'android.intent.action.MAIN',
            package: 'com.oneplus.note',
            componentName:
                'com.oneplus.note.ui.NoteEditActivity',
            arguments: <String, dynamic>{
              'android.intent.extra.SUBJECT':
                  title,
              'android.intent.extra.TEXT': content,
            },
            flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
          );
          await intent.launch();
          return true;
        } catch (e) {
          print('Error with first OnePlus Notes attempt: $e');

          try {
            final AndroidIntent intent = AndroidIntent(
              action: 'android.intent.action.SEND',
              type: 'text/plain',
              package: 'com.oneplus.note',
              arguments: <String, dynamic>{
                'android.intent.extra.SUBJECT': title,
                'android.intent.extra.TEXT': content,
              },
            );
            await intent.launch();
            return true;
          } catch (e) {
            print('Error with second OnePlus Notes attempt: $e');

            return await _createNoteInGoogleKeep(title, content);
          }
        }
      } else if (Platform.isIOS) {
        final url =
            'mobilenotes://create?title=${Uri.encodeComponent(title)}&body=${Uri.encodeComponent(content)}';
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return true;
        }
        return false;
      } else {
        return await _createNoteInGoogleKeep(title, content);
      }
    } catch (e) {
      print('Error creating note: $e');
      return false;
    }
  }

  static Future<bool> _createNoteInGoogleKeep(
      String title, String content) async {
    try {
      final AndroidIntent intent = AndroidIntent(
        action: 'android.intent.action.SEND',
        type: 'text/plain',
        package: 'com.google.android.keep',
        arguments: <String, dynamic>{
          'android.intent.extra.SUBJECT': title,
          'android.intent.extra.TEXT': content,
        },
      );
      await intent.launch();
      return true;
    } catch (e) {
      try {
        final url =
            'https://keep.google.com/#create/text=${Uri.encodeComponent(title)}\n${Uri.encodeComponent(content)}';
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
          return true;
        }
      } catch (e) {
        print('Error opening Google Keep: $e');
      }
      return false;
    }
  }

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

  // YouTube
  static Future<void> searchYouTube(String query) async {
    final encodedQuery = Uri.encodeComponent(query);
    final url = 'https://www.youtube.com/results?search_query=$encodedQuery';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }
}
