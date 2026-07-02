import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/weather_provider.dart';
import '../../providers/location_provider.dart';
import '../../providers/favorite_provider.dart';

import '../../services/location_service.dart';

import '../../animations/weather_visual.dart';
import '../../animations/weather_background.dart';

import '../../widgets/weather/weather_detail_grid.dart';
import '../../widgets/weather/hourly_item.dart';
import '../../widgets/weather/weekly_row.dart';
import '../../widgets/weather/section_card.dart';
import '../../widgets/weather/hero_weather_card.dart';
import '../../widgets/weather/weather_alert_card.dart';
import '../../widgets/weather/weather_loading_view.dart';
import '../../widgets/weather/weather_error_view.dart';

import '../../widgets/common/app_snack_bar.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final city = ref.watch(activeLocationProvider).cityName;
    final weatherAsync = ref.watch(weatherProvider(city));
    final favorites = ref.watch(favoritesProvider);

    return weatherAsync.when(
      data: (w) {
        final visual = WeatherVisuals.getVisuals(w.description);
        final isFavorite = favorites.contains(w.cityName);

        return Stack(
          children: [
            WeatherBackground(
              description: w.description,
              colors: visual.bgColors,
            ),

            Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  tooltip: '使用目前定位',
                  icon: const Icon(Icons.my_location_rounded),
                  onPressed: () => _handleGPS(ref, context),
                ),
                actions: [
                  IconButton(
                    tooltip: '重新整理',
                    icon: const Icon(Icons.refresh_rounded),
                    onPressed: () {
                      _refreshWeather(
                        ref,
                        context,
                        city,
                      );
                    },
                  ),

                  IconButton(
                    tooltip: isFavorite ? '移除關注' : '加入關注',
                    icon: Icon(
                      isFavorite
                          ? Icons.bookmark_rounded
                          : Icons.bookmark_border_rounded,
                      color: isFavorite
                          ? Colors.yellowAccent
                          : Colors.white,
                    ),
                    onPressed: () {
                      ref
                          .read(favoritesProvider.notifier)
                          .toggleFavorite(w.cityName);

                      AppSnackBar.show(
                        context,
                        message: isFavorite
                            ? "已移除關注：${w.cityName}"
                            : "已加入關注：${w.cityName}",
                        type: isFavorite
                            ? AppSnackType.warning
                            : AppSnackType.success,
                      );
                    },
                  ),
                ],
              ),
              body: RefreshIndicator(
                color: Colors.lightBlueAccent,
                backgroundColor: const Color(0xFF102A46),
                onRefresh: () => _refreshWeather(
                  ref,
                  context,
                  city,
                ),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      HeroWeatherCard(
                        weather: w,
                        icon: visual.icon,
                      ),

                      WeatherAlertCard(
                        weather: w,
                      ),

                      SectionCard(
                        title: '未來 24 小時',
                        child: SizedBox(
                          height: 158,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: w.hourly.length,
                            itemBuilder: (context, index) {
                              final h = w.hourly[index];

                              return HourlyItem(
                                h,
                                isFirst: index == 0,
                              );
                            },
                          ),
                        ),
                      ),

                      SectionCard(
                        title: '未來 7 日預報',
                        child: Column(
                          children: w.weekly
                              .map((d) => WeeklyRow(d))
                              .toList(),
                        ),
                      ),

                      WeatherDetailGrid(
                        weather: w,
                      ),

                      const SizedBox(height: 110),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
      loading: () {
        return const WeatherLoadingView();
      },
      error: (error, stackTrace) {
        return WeatherErrorView(
          error: error,
          onRetry: () {
            ref.invalidate(weatherProvider(city));
          },
        );
      },
    );
  }

  Future<void> _refreshWeather(
      WidgetRef ref,
      BuildContext context,
      String city,
      ) async {
    try {
      AppSnackBar.show(
        context,
        message: '正在重新整理 $city 天氣資料',
        type: AppSnackType.info,
      );

      await ref.refresh(weatherProvider(city).future);

      if (!context.mounted) return;

      AppSnackBar.show(
        context,
        message: '$city 天氣資料已更新',
        type: AppSnackType.success,
      );
    } catch (e) {
      if (!context.mounted) return;

      AppSnackBar.show(
        context,
        message: '重新整理失敗，請確認網路連線後再試一次',
        type: AppSnackType.error,
      );
    }
  }

  Future<void> _handleGPS(
      WidgetRef ref,
      BuildContext context,
      ) async {
    final city = await LocationService().getCurrentCity();

    if (!context.mounted) return;

    if (city != null) {
      ref.read(activeLocationProvider.notifier).updateLocation(city);

      AppSnackBar.show(
        context,
        message: "已更新定位：$city",
        type: AppSnackType.success,
      );
    } else {
      AppSnackBar.show(
        context,
        message: "定位失敗，請確認定位權限或網路連線",
        type: AppSnackType.error,
      );
    }
  }
}