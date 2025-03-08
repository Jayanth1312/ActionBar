import 'package:flutter/material.dart';
import '../utils/web_search.dart';
import '../utils/action_utils.dart';
import '../utils/weather_service.dart';
import '../utils/alarm_utils.dart';
import '../utils/timer_utils.dart';
import '../widgets/weather_display.dart';
import '../widgets/status_message.dart';

class SuggestionItem {
  final String displayText;
  final String textToInsert;
  final int highlightStartIndex;
  final int highlightEndIndex;

  SuggestionItem({
    required this.displayText,
    required this.textToInsert,
    required this.highlightStartIndex,
    required this.highlightEndIndex,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  WeatherData? _weatherData;
  bool _isLoading = false;
  String? _errorMessage;
  String? _actionMessage;

  // Suggestions
  final List<SuggestionItem> _suggestions = [
    SuggestionItem(
      displayText: 'weather in new york',
      textToInsert: 'weather in new york',
      highlightStartIndex: 11,
      highlightEndIndex: 19,
    ),
    SuggestionItem(
      displayText: '@m mailid subject',
      textToInsert: '@m mailid subject',
      highlightStartIndex: 3,
      highlightEndIndex: 9,
    ),
    SuggestionItem(
      displayText: '@who is taylor swift',
      textToInsert: '@who is taylor swift',
      highlightStartIndex: 1,
      highlightEndIndex: 20,
    ),
    SuggestionItem(
      displayText: '@a 8 00 am',
      textToInsert: '@a 8 00 am',
      highlightStartIndex: 3,
      highlightEndIndex: 10,
    ),
    SuggestionItem(
      displayText: '@t 10min',
      textToInsert: '@t 10min',
      highlightStartIndex: 3,
      highlightEndIndex: 8,
    ),
  ];

  void _handleSubmitted(String text) async {
    setState(() {
      _errorMessage = null;
      _actionMessage = null;
    });

    String? actionMessage;

    //Email
    if (text.startsWith('@m ')) {
      ActionUtils.sendEmail(text.substring(3).trim());
      actionMessage = 'Composing email...';
    }
    //Alarm command
    else if (text.startsWith('@a ')) {
      final success = await AlarmUtils.createAlarm(text);
      if (success) {
        actionMessage = 'Opening alarm settings...';
      } else {
        _showError('Could not set alarm. Use format: @a 5 30 am or @a 17 45');
      }
    }
    //Timer command
    else if (text.startsWith('@t ')) {
      final success = await TimerUtils.createTimer(text);
      if (success) {
        actionMessage = 'Opening timer...';
      } else {
        _showError(
            'Could not start timer. Use format: @t 5min or @t 1hr 30min');
      }
    }
    //Google search
    else if (text.startsWith('@') && text.length > 1) {
      _performWebSearch(text.substring(1).trim());
      actionMessage = 'Searching web...';
    }
    //Weather search
    else if (text.toLowerCase().startsWith('weather in ') && text.length > 11) {
      _getWeather(text.substring(11).trim());
      actionMessage = 'Fetching weather...';
    }
    //Web search
    else if (text.startsWith('www') ||
        text.startsWith('http://') ||
        text.startsWith('https://')) {
      _performWebSearch(text);
      actionMessage = 'Opening website...';
    }

    // Toast message
    if (actionMessage != null && mounted) {
      setState(() {
        _actionMessage = actionMessage;
      });

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _actionMessage = null;
          });
        }
      });
    }

    _controller.clear();
  }

  // Focus node
  final FocusNode _focusNode = FocusNode();

  void _applyHighlightedSuggestion(SuggestionItem suggestion) {
    _controller.text = suggestion.textToInsert;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.selection = TextSelection(
        baseOffset: suggestion.highlightStartIndex,
        extentOffset: suggestion.highlightEndIndex,
      );

      _focusNode.requestFocus();
    });
  }

  Future<void> _getWeather(String city) async {
    setState(() {
      _isLoading = true;
    });

    final weatherData = await WeatherService.getWeather(city);

    setState(() {
      _weatherData = weatherData;
      _isLoading = false;
    });

    if (weatherData == null && mounted) {
      _showError('Could not fetch weather for "$city"');
    }
  }

  void _clearResults() {
    setState(() {
      _weatherData = null;
    });
  }

  Future<void> _performWebSearch(String query) async {
    final success = await WebSearch.performWebSearch(query);

    if (!success && mounted) {
      _showError('Could not launch search. Is a browser installed?');
    }
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final backgroundColor = theme.scaffoldBackgroundColor;
    final textFieldBgColor =
        theme.inputDecorationTheme.fillColor ?? const Color(0xFF333333);
    final hintColor =
        theme.inputDecorationTheme.hintStyle?.color ?? Colors.grey;
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.white;

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
                const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 20,
                  color: Colors.white,
                ),
          ),
        ),
        backgroundColor: backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage != null)
              StatusMessage(
                message: _errorMessage!,
                type: MessageType.error,
                onDismiss: () => setState(() => _errorMessage = null),
              ),
            if (_actionMessage != null)
              StatusMessage(
                message: _actionMessage!,
                type: MessageType.acknowledgement,
              ),

            const Spacer(),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_weatherData != null)
              Align(
                alignment: Alignment.topLeft,
                child: WeatherDisplay(
                  weatherData: _weatherData!,
                  onClose: _clearResults,
                ),
              ),

            // Suggestion list
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
              child: Container(
                height: 40,
                margin: const EdgeInsets.only(bottom: 10.0),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _suggestions.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () =>
                          _applyHighlightedSuggestion(_suggestions[index]),
                      child: Container(
                        height: 40,
                        margin: const EdgeInsets.only(right: 8.0),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12.0, vertical: 0),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(
                            color: const Color(0xFF333333),
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Center(
                          child: Text(
                            _suggestions[index].displayText,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 14,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
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
                    focusNode: _focusNode,
                    cursorColor: textColor,
                    controller: _controller,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 16,
                      fontFamily: 'Inter',
                    ),
                    decoration: InputDecoration(
                      hintText: "Start with @ to do stuff",
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
            ),
          ],
        ),
      ),
    );
  }
}
