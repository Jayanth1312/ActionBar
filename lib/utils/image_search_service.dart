import '../widgets/image_display.dart';

class ImageSearchService {
  static Future<List<ImageSearchResult>> searchImages(String query) async {
    return [
      ImageSearchResult(
        imageUrl: 'https://example.com/image1.jpg',
        title: 'Search Result 1',
        sourceUrl: 'https://example.com/1',
      ),
      // Add more mock results
    ];
  }
}
