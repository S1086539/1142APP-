class AIStylistPromptContext {
  final String destinationCity;
  final int dayCount;
  final String activitySummary;
  final String weatherNote;
  final String outfitSummary;
  final String imagePrompt;

  const AIStylistPromptContext({
    required this.destinationCity,
    required this.dayCount,
    required this.activitySummary,
    required this.weatherNote,
    required this.outfitSummary,
    required this.imagePrompt,
  });
}