import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/weather_provider.dart';
import '../../providers/favorite_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/page_provider.dart';

import '../../widgets/weather/favorite_weather_card.dart';

import '../../widgets/common/app_snack_bar.dart';

class FavoritePage extends ConsumerWidget {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          "關注城市",
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            ref.read(pageIndexProvider.notifier).setIndex(0);
          },
        ),
      ),
      body: favorites.isEmpty
          ? const _EmptyFavoriteView()
          : ListView.builder(
        padding: const EdgeInsets.only(
          top: 8,
          bottom: 110,
        ),
        itemCount: favorites.length,
        itemBuilder: (ctx, i) {
          final cityName = favorites[i];
          final weatherAsync = ref.watch(weatherProvider(cityName));

          return weatherAsync.when(
            data: (w) => FavoriteWeatherCard(
              cityName: cityName,
              temperature: w.temperature,
              description: w.description,
              onTap: () {
                ref
                    .read(activeLocationProvider.notifier)
                    .updateLocation(cityName);

                ref.read(pageIndexProvider.notifier).setIndex(0);
              },
              onRemove: () {
                ref
                    .read(favoritesProvider.notifier)
                    .toggleFavorite(cityName);
                AppSnackBar.show(
                  context,
                  message: "已移除關注：$cityName",
                  type: AppSnackType.warning,
                );
              },
            ),
            loading: () => FavoriteWeatherCard(
              cityName: cityName,
              isLoading: true,
              onTap: () {},
              onRemove: () {
                ref
                    .read(favoritesProvider.notifier)
                    .toggleFavorite(cityName);
              },
            ),
            error: (_, __) => FavoriteWeatherCard(
              cityName: cityName,
              hasError: true,
              description: '讀取失敗',
              onTap: () {},
              onRemove: () {
                ref
                    .read(favoritesProvider.notifier)
                    .toggleFavorite(cityName);
              },
            ),
          );
        },
      ),
    );
  }
}

class _EmptyFavoriteView extends StatelessWidget {
  const _EmptyFavoriteView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bookmark_border_rounded,
              size: 64,
              color: Colors.white54,
            ),
            SizedBox(height: 16),
            Text(
              "目前無關注城市",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              "回到首頁後，點擊右上角收藏按鈕即可加入關注城市。",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white60,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}