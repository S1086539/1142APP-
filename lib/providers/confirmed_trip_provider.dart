import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/trip_preview.dart';

final confirmedTripProvider =
NotifierProvider<ConfirmedTripNotifier, TripPreview?>(
  ConfirmedTripNotifier.new,
);

class ConfirmedTripNotifier extends Notifier<TripPreview?> {
  @override
  TripPreview? build() {
    return null;
  }

  void confirm(TripPreview preview) {
    state = preview;
  }

  void clear() {
    state = null;
  }

  bool isConfirmed(TripPreview preview) {
    return state?.signature == preview.signature;
  }
}