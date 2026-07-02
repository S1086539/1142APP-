import 'package:flutter_riverpod/flutter_riverpod.dart';

final favoritesProvider = NotifierProvider<FavoritesNotifier, List<String>>(() {
  return FavoritesNotifier();
});

class FavoritesNotifier extends Notifier<List<String>> {
  @override
  List<String> build() => [];
  void toggleFavorite(String city) {
    if (state.contains(city)) {
      state = state.where((item) => item != city).toList();
    } else {
      state = [...state, city];
    }
  }
}