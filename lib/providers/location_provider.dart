import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/location_state.dart';
import '../services/location_service.dart';

final activeLocationProvider =
NotifierProvider<ActiveLocationNotifier, LocationState>(
  ActiveLocationNotifier.new,
);

class ActiveLocationNotifier extends Notifier<LocationState> {
  final _locationService = LocationService();

  @override
  LocationState build() {
    Future.microtask(updateToCurrentLocation);
    return const LocationState(
      cityName: "臺北市",
    );
  }

  void updateLocation(String city) {
    state = LocationState(cityName: city);
  }

  Future<void> updateToCurrentLocation() async {
    final city = await _locationService.getCurrentCity();

    if (city != null) {
      updateLocation(city);
    }
  }
}