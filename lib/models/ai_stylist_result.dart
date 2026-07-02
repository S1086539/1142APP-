import 'dart:typed_data';

class AIStylistResult {
  final String title;
  final String description;
  final List<String> outfitItems;
  final String imagePrompt;
  final String? imageUrl;
  final Uint8List? imageBytes;
  final String? mimeType;
  final DateTime createdAt;

  const AIStylistResult({
    required this.title,
    required this.description,
    required this.outfitItems,
    required this.imagePrompt,
    required this.createdAt,
    this.imageUrl,
    this.imageBytes,
    this.mimeType,
  });

  bool get hasImage {
    return imageBytes != null && imageBytes!.isNotEmpty;
  }
}