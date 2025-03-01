import 'package:flutter/material.dart';
import '../utils/web_search.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();

  void _handleSubmitted(String text) {
    if (text.startsWith('@') && text.length > 1) {
      _performWebSearch(text.substring(1).trim());
    }
    _controller.clear();
  }

  Future<void> _performWebSearch(String query) async {
    final success = await WebSearch.performWebSearch(query);

    if (!success && mounted) {
      _showErrorSnackBar('Could not launch search. Is a browser installed?');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final backgroundColor = theme.scaffoldBackgroundColor;
    final textFieldBgColor = theme.inputDecorationTheme.fillColor;
    final hintColor =
        theme.inputDecorationTheme.hintStyle?.color ?? Colors.grey;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Text(
            "ActionBar",
            style: theme.appBarTheme.titleTextStyle?.copyWith(
                  fontFamily: 'Inter',
                  fontSize: 20,
                ) ??
                TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                ),
          ),
        ),
        backgroundColor: backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: 0,
                itemBuilder: (context, index) {
                  return Container();
                },
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: textFieldBgColor,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 18.0,
                vertical: 6.0,
              ),
              margin: const EdgeInsets.only(bottom: 8.0),
              child: Theme(
                data: theme,
                child: TextField(
                  cursorColor: textColor,
                  controller: _controller,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontFamily: 'Inter',
                  ),
                  decoration: InputDecoration(
                    hintText: "Start with @ to do stuff...",
                    fillColor: textFieldBgColor,
                    filled: true,
                    hintStyle: TextStyle(
                      color: hintColor,
                      fontFamily: 'Inter',
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                  ),
                  onSubmitted: _handleSubmitted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
