import 'package:flutter/material.dart';
import '../utils/web_search.dart';
import '../utils/action_utils.dart';
import '../utils/weather_service.dart';
import '../utils/alarm_utils.dart';
import '../utils/timer_utils.dart';
import '../widgets/weather_display.dart';
import '../widgets/status_message.dart';
import '../utils/web_scraper_service.dart';
import '../utils/gemini_service.dart';
import '../widgets/empty_state_icon.dart';
import '../widgets/top_links_display.dart';
import '../widgets/ai_overview_display.dart';

class SuggestionItem {
  final String displayText;
  final String textToInsert;
  final int highlightStartIndex;
  final int highlightEndIndex;
  final IconData? icon;

  SuggestionItem({
    required this.displayText,
    required this.textToInsert,
    required this.highlightStartIndex,
    required this.highlightEndIndex,
    this.icon,
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
  List<WebScrapingResult>? _webResults;
  String? _errorMessage;
  String? _actionMessage;
  List<WebScrapingResult>? _linkResults;

  // Suggestions
  final List<SuggestionItem> _suggestions = [
    SuggestionItem(
      displayText: 'Overview',
      textToInsert: '!flutter development',
      highlightStartIndex: 1,
      highlightEndIndex: 20,
      icon: Icons.assistant,
    ),
    SuggestionItem(
      displayText: 'Weather',
      textToInsert: '@w new york',
      highlightStartIndex: 3,
      highlightEndIndex: 11,
      icon: Icons.cloud,
    ),
    SuggestionItem(
      displayText: 'New note',
      textToInsert: '@n title',
      highlightStartIndex: 3,
      highlightEndIndex: 7,
      icon: Icons.description,
    ),
    SuggestionItem(
      displayText: 'Mail',
      textToInsert: '@m mailid subject',
      highlightStartIndex: 3,
      highlightEndIndex: 9,
      icon: Icons.email,
    ),
    SuggestionItem(
      displayText: 'YouTube',
      textToInsert: '@yt funny cat videos',
      highlightStartIndex: 4,
      highlightEndIndex: 20,
      icon: Icons.video_library,
    ),
    SuggestionItem(
      displayText: 'Alarm',
      textToInsert: '@a 8 00 am',
      highlightStartIndex: 3,
      highlightEndIndex: 10,
      icon: Icons.alarm,
    ),
    SuggestionItem(
      displayText: 'Timer',
      textToInsert: '@t 10min',
      highlightStartIndex: 3,
      highlightEndIndex: 8,
      icon: Icons.timer,
    ),
    SuggestionItem(
      displayText: 'Links',
      textToInsert: '@l flutter development',
      highlightStartIndex: 3,
      highlightEndIndex: 22,
      icon: Icons.link,
    ),
  ];

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  void _handleSubmitted(String text) async {
    setState(() {
      _errorMessage = null;
      _actionMessage = null;
    });

    String? actionMessage;

    //Web Results
    if (text.startsWith('!') && text.length > 1) {
      await _handleWebScraping(text.substring(1).trim());
    }
    //Link Search
    else if (text.startsWith('@l ') && text.length > 3) {
      await _handleLinkSearch(text.substring(3).trim());
    }
    //Notes
    else if (text.startsWith('@n ') && text.length > 3) {
      final title = text.substring(3).trim();

      setState(() {
        _actionMessage = 'Creating note...';
      });

      final success = await ActionUtils.createNote(title, "");

      if (success) {
        setState(() {
          _actionMessage = 'Note created successfully';
        });

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _actionMessage = null;
            });
          }
        });
      } else {
        _showError('Could not create note');
      }
    }
    //Email
    else if (text.startsWith('@m ')) {
      ActionUtils.sendEmail(text.substring(3).trim());
    }
    //Alarm
    else if (text.startsWith('@a ')) {
      final success = await AlarmUtils.createAlarm(text);
      if (!success) {
        _showError('Could not set alarm.');
      }
    }
    //Timer
    else if (text.startsWith('@t ')) {
      final success = await TimerUtils.createTimer(text);
      if (!success) {
        _showError('Could not start timer');
      }
    }
    //YouTube search
    else if (text.startsWith('@yt ') && text.length > 4) {
      await ActionUtils.searchYouTube(text.substring(4).trim());
      actionMessage = 'Searching YouTube...';
    }
    //Weather
    else if (text.toLowerCase().startsWith('@w ') && text.length > 3) {
      _getWeather(text.substring(3).trim());
    }
    //Google search
    else if (text.startsWith('') && text.length > 1) {
      _performWebSearch(text.substring(1).trim());
    }
    //Web search
    else if (text.startsWith('www') ||
        text.startsWith('http://') ||
        text.startsWith('https://')) {
      _performWebSearch(text);
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
      _actionMessage = 'Fetching weather for "$city"...';
    });

    final weatherData = await WeatherService.getWeather(city);

    setState(() {
      _weatherData = weatherData;
      _actionMessage = null;
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
    await WebSearch.performWebSearch(query);
  }

  Future<void> _handleWebScraping(String query) async {
    setState(() {
      _actionMessage = 'Fetching web results...';
      _webResults = null;
    });

    try {
      final results = await WebScraperService.scrapeTopResults(query);

      final contentToSummarize = results
          .map((r) => r.fullContent != null && r.fullContent!.isNotEmpty
              ? r.fullContent!
              : r.description)
          .toList();

      final summary = await GeminiService.getSummary(contentToSummarize);

      final summarizedResults = results
          .map((r) => WebScrapingResult(
                title: r.title,
                description: summary,
                url: r.url,
                faviconUrl: r.faviconUrl,
                fullContent: r.fullContent,
              ))
          .toList();

      if (mounted) {
        setState(() {
          _webResults = summarizedResults;
          _actionMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to fetch web results: ${e.toString()}');
        setState(() {
          _actionMessage = null;
        });
      }
    }
  }

  Future<void> _handleLinkSearch(String query) async {
    setState(() {
      _actionMessage = 'Searching for links...';
      _linkResults = null;
    });

    try {
      final results =
          await WebScraperService.scrapeTopResults(query, maxResults: 10);

      if (mounted) {
        setState(() {
          _linkResults = results;
          _actionMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to fetch links: ${e.toString()}');
        setState(() {
          _actionMessage = null;
        });
      }
    }
  }

  List<SuggestionItem> _getFilteredSuggestions(String text) {
    if (text.isEmpty) {
      return [];
    }

    if (text.startsWith('@')) {
      if (text.length > 1) {
        final secondChar = text.substring(1, 2).toLowerCase();

        return _suggestions
            .where((suggestion) =>
                suggestion.textToInsert.startsWith('@') &&
                suggestion.textToInsert.length > 1 &&
                suggestion.textToInsert.substring(1, 2).toLowerCase() ==
                    secondChar)
            .toList();
      } else {
        return _suggestions
            .where((suggestion) => suggestion.textToInsert.startsWith('@'))
            .toList();
      }
    } else if (text.startsWith('!')) {
      return _suggestions
          .where((suggestion) => suggestion.textToInsert.startsWith('!'))
          .toList();
    }
    return [];
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

    final suggestionBorderColor = textFieldBgColor;
    final suggestionTextColor = Colors.grey;
    final suggestionBgColor = textFieldBgColor.withOpacity(0.5);

    final bool isEmptyState = _weatherData == null &&
        _webResults == null &&
        _linkResults == null &&
        _errorMessage == null &&
        _actionMessage == null;

    final filteredSuggestions = _getFilteredSuggestions(_controller.text);

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
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () async {
              final success = await ActionUtils.openGoogleLens();

              if (!success && mounted) {
                _showError('Can\'t open Google Lens');
              }

              Future.delayed(const Duration(seconds: 1), () {
                if (mounted) {
                  setState(() {
                    _actionMessage = null;
                  });
                }
              });
            },
          ),
        ],
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      body: Stack(
        children: [
          // Main content stack
          Stack(
            children: [
              isEmptyState
                  ? const Positioned.fill(
                      child: EmptyStateIcon(),
                    )
                  : CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 130),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_weatherData != null)
                                  Align(
                                    alignment: Alignment.topLeft,
                                    child: WeatherDisplay(
                                      weatherData: _weatherData!,
                                      onClose: _clearResults,
                                    ),
                                  ),
                                if (_webResults != null)
                                  AIOverviewDisplay(
                                    results: _webResults!,
                                    onClose: () {
                                      setState(() {
                                        _webResults = null;
                                      });
                                    },
                                    onError: _showError,
                                    onActionMessage: (message) {
                                      setState(() {
                                        _actionMessage = message;
                                      });

                                      Future.delayed(const Duration(seconds: 1),
                                          () {
                                        if (mounted) {
                                          setState(() {
                                            _actionMessage = null;
                                          });
                                        }
                                      });
                                    },
                                  ),
                                if (_linkResults != null)
                                  TopLinksDisplay(
                                    links: _linkResults!,
                                    onClose: () {
                                      setState(() {
                                        _linkResults = null;
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            ],
          ),

          // Add this new block for Status Messages
          if (_errorMessage != null || _actionMessage != null)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Column(
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
                ],
              ),
            ),

          // Bottom text field positioning
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (filteredSuggestions.isNotEmpty)
                      Container(
                        height: 40,
                        margin: const EdgeInsets.fromLTRB(8.0, 8.0, 0, 10.0),
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: filteredSuggestions.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () => _applyHighlightedSuggestion(
                                  filteredSuggestions[index]),
                              child: Container(
                                height: 40,
                                margin: const EdgeInsets.only(right: 8.0),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 0),
                                decoration: BoxDecoration(
                                  color: suggestionBgColor,
                                  border: Border.all(
                                    color: suggestionBorderColor,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (filteredSuggestions[index].icon != null)
                                      Icon(
                                        filteredSuggestions[index].icon,
                                        color: suggestionTextColor,
                                        size: 16,
                                      ),
                                    SizedBox(
                                        width:
                                            filteredSuggestions[index].icon !=
                                                    null
                                                ? 6.0
                                                : 0),
                                    Text(
                                      filteredSuggestions[index].displayText,
                                      style:
                                          theme.textTheme.bodySmall?.copyWith(
                                                color: suggestionTextColor,
                                                fontSize: 14,
                                                fontFamily: 'Inter',
                                              ) ??
                                              TextStyle(
                                                color: suggestionTextColor,
                                                fontSize: 14,
                                                fontFamily: 'Inter',
                                              ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                    // Text Field
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: textFieldBgColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18.0,
                          vertical: 6.0,
                        ),
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
                              hintText: "Type something...",
                              fillColor: textFieldBgColor,
                              filled: true,
                              hintStyle: TextStyle(
                                color: hintColor,
                                fontFamily: 'Inter',
                                fontSize: 16,
                              ),
                              border: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12.0),
                            ),
                            onChanged: (text) {
                              setState(() {});
                            },
                            onSubmitted: _handleSubmitted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
