import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../utils/web_scraper_service.dart';
import '../utils/web_search.dart';

class AIOverviewDisplay extends StatelessWidget {
  final List<WebScrapingResult> results;
  final Function onClose;
  final Function(String) onError;
  final Function(String) onActionMessage;
  final bool showDetailedResults;

  const AIOverviewDisplay({
    super.key,
    required this.results,
    required this.onClose,
    required this.onError,
    required this.onActionMessage,
    this.showDetailedResults = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyMedium?.color ?? Colors.white;
    final textFieldBgColor =
        theme.inputDecorationTheme.fillColor ?? const Color(0xFF333333);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: textFieldBgColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.assistant, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'AI overview',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => onClose(),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: textFieldBgColor,
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: textColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SelectableText(
                    results.first.description,
                    style: TextStyle(
                      color: textColor.withOpacity(0.9),
                      fontSize: 14,
                    ),
                    toolbarOptions: ToolbarOptions(
                      copy: true,
                      selectAll: true,
                      cut: false,
                      paste: false,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: textFieldBgColor, width: 1),
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Text(
                    'Sources',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ...results
                      .map(
                        (result) => Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: InkWell(
                            onTap: () => result.url.isNotEmpty
                                ? _performWebSearch(result.url)
                                : null,
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: textFieldBgColor,
                              child: Icon(
                                Icons.public,
                                size: 16,
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  const Spacer(),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () =>
                            _copyToClipboard(results.first.description),
                        child: Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: textFieldBgColor,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.copy,
                              size: 16,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _shareSummary(results.first.description),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: textFieldBgColor,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.share,
                              size: 16,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (showDetailedResults)
              ...results
                  .map((result) => Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(color: textFieldBgColor, width: 1),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16.0),
                          title: Text(
                            result.title,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              result.description,
                              style: TextStyle(
                                color: textColor.withOpacity(0.7),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          onTap: () => result.url.isNotEmpty
                              ? _performWebSearch(result.url)
                              : null,
                        ),
                      ))
                  .toList(),
          ],
        ),
      ),
    );
  }

  Future<void> _performWebSearch(String query) async {
    await WebSearch.performWebSearch(query);
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  void _shareSummary(String text) {
    Share.share(text);
  }
}
