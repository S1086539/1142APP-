import '../models/ai_stylist_prompt_context.dart';
import '../models/trip_preview.dart';

class AIStylistPromptBuilder {
  static AIStylistPromptContext build(TripPreview trip) {
    final activitySummary = _buildActivitySummary(trip);
    final outfitSummary = _buildOutfitSummary(trip);

    final imagePrompt = '''
Create a realistic fashion styling image for a Taiwan travel itinerary.

Destination:
${trip.destinationCity}

Trip length:
${trip.dayCount <= 1 ? 'One day trip' : '${trip.dayCount} days trip'}

Activities:
$activitySummary

Weather considerations:
${trip.weatherNote}

Outfit direction:
$outfitSummary

Image requirements:
A full-body travel outfit flat lay or editorial-style outfit photo.
Modern, clean, practical, stylish but not exaggerated.
Suitable for Taiwanese weather and city travel.
Include clothes, shoes, and small travel accessories.
No text in the image.
No logo.
No watermark.
Natural lighting.
High quality.
''';

    return AIStylistPromptContext(
      destinationCity: trip.destinationCity,
      dayCount: trip.dayCount,
      activitySummary: activitySummary,
      weatherNote: trip.weatherNote,
      outfitSummary: outfitSummary,
      imagePrompt: imagePrompt.trim(),
    );
  }

  static String _buildActivitySummary(TripPreview trip) {
    final slots = trip.days
        .expand((day) => day.slots)
        .map((slot) => '${slot.period}：${slot.displayText}')
        .toList();

    if (slots.isNotEmpty) {
      return slots.take(12).join('\n');
    }

    if (trip.highlights.isNotEmpty) {
      return trip.highlights.take(8).join('\n');
    }

    return '城市散步、在地美食、戶外景點與輕旅行。';
  }

  static String _buildOutfitSummary(TripPreview trip) {
    final weatherNote = trip.weatherNote;

    final buffer = StringBuffer();

    buffer.writeln('Comfortable travel outfit for walking and taking photos.');

    if (weatherNote.contains('雨') || weatherNote.contains('降雨')) {
      buffer.writeln('Include light waterproof outerwear, water-resistant shoes, and a compact umbrella.');
    }

    if (weatherNote.contains('熱') ||
        weatherNote.contains('高溫') ||
        weatherNote.contains('曝曬')) {
      buffer.writeln('Use breathable fabric, light colors, sun protection, and comfortable sneakers.');
    }

    if (weatherNote.contains('冷') || weatherNote.contains('外套')) {
      buffer.writeln('Include a light jacket or layered outfit suitable for cooler weather.');
    }

    if (_hasOutdoorActivity(trip)) {
      buffer.writeln('Suitable for outdoor walking, scenic spots, and light activity.');
    }

    if (_hasFoodOrCityWalk(trip)) {
      buffer.writeln('Casual city style suitable for food streets, cafes, and urban walking.');
    }

    return buffer.toString().trim();
  }

  static bool _hasOutdoorActivity(TripPreview trip) {
    final text = _allTripText(trip);

    return text.contains('步道') ||
        text.contains('海岸') ||
        text.contains('海邊') ||
        text.contains('湖') ||
        text.contains('山') ||
        text.contains('公園') ||
        text.contains('散步');
  }

  static bool _hasFoodOrCityWalk(TripPreview trip) {
    final text = _allTripText(trip);

    return text.contains('夜市') ||
        text.contains('小吃') ||
        text.contains('美食') ||
        text.contains('咖啡') ||
        text.contains('市區') ||
        text.contains('老街');
  }

  static String _allTripText(TripPreview trip) {
    final slotText = trip.days
        .expand((day) => day.slots)
        .map((slot) => slot.displayText)
        .join(' ');

    return [
      trip.title,
      trip.destinationCity,
      trip.highlights.join(' '),
      trip.weatherNote,
      slotText,
    ].join(' ');
  }
}