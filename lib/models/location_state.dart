class LocationState {
  final String cityName;

  const LocationState({
    required this.cityName,
  });

  LocationState copyWith({
    String? cityName,
  }) {
    return LocationState(
      cityName: cityName ?? this.cityName,
    );
  }
}