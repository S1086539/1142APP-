class TripPreview {
  final String title;
  final String destinationCity;
  final int dayCount;
  final List<String> highlights;
  final String weatherNote;
  final List<TripPreviewDay> days;

  const TripPreview({
    required this.title,
    required this.destinationCity,
    required this.dayCount,
    required this.highlights,
    required this.weatherNote,
    this.days = const [],
  });

  String get signature {
    final dayText = days
        .map(
          (day) => 'Day ${day.dayNumber}: ${day.slots.map((slot) => slot.displayText).join('|')}',
    )
        .join('||');

    return [
      title,
      destinationCity,
      dayCount.toString(),
      highlights.join('|'),
      weatherNote,
      dayText,
    ].join('::');
  }
}

class TripPreviewDay {
  final int dayNumber;
  final List<TripPreviewTimeSlot> slots;

  const TripPreviewDay({
    required this.dayNumber,
    required this.slots,
  });
}

class TripPreviewTimeSlot {
  final String period;
  final String place;
  final String description;

  const TripPreviewTimeSlot({
    required this.period,
    required this.place,
    required this.description,
  });

  String get displayText {
    if (description.trim().isEmpty) {
      return place;
    }

    return '$place，$description';
  }
}