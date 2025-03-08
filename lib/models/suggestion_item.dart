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
