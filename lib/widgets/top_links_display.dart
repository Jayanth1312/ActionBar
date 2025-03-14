import 'package:flutter/material.dart';
import '../utils/web_scraper_service.dart';
import '../utils/web_search.dart';

class TopLinksDisplay extends StatelessWidget {
  final List<WebScrapingResult> links;
  final Function onClose;

  const TopLinksDisplay({
    Key? key,
    required this.links,
    required this.onClose,
  }) : super(key: key);

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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.link, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Top Results',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
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
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: links.length,
              itemBuilder: (context, index) {
                final result = links[index];
                return Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: textFieldBgColor, width: 0.5),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    title: Text(
                      result.title,
                      style: TextStyle(
                        color: textColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      result.url,
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    leading: CircleAvatar(
                      radius: 12,
                      backgroundColor: textFieldBgColor,
                      child: Icon(
                        Icons.public,
                        size: 16,
                        color: textColor,
                      ),
                    ),
                    onTap: () => result.url.isNotEmpty
                        ? _performWebSearch(result.url)
                        : null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _performWebSearch(String query) async {
    await WebSearch.performWebSearch(query);
  }
}
