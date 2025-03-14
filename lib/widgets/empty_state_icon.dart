import 'package:flutter/material.dart';

class EmptyStateIcon extends StatelessWidget {
  const EmptyStateIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            SizedBox(height: constraints.maxHeight * 0.25),
            Icon(
              Icons.alternate_email_rounded,
              size: 150,
              color: Colors.grey.withOpacity(0.3),
            ),
            const SizedBox(height: 40),
            Column(children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Icon(
                      Icons.alternate_email_rounded,
                      size: 14,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'to start an action',
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Row(
                    children: [
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.priority_high_rounded,
                          size: 14,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'for AI overview',
                        style: TextStyle(
                          fontSize: 14,
                          color: textColor.withOpacity(0.8),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ])
          ],
        );
      },
    );
  }
}
