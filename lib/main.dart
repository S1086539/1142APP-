import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'providers/location_provider.dart';
import 'providers/page_provider.dart';

import 'screens/home/home_page.dart';
import 'screens/favorite/favorite_page.dart';
import 'screens/ai_trip/ai_trip_page.dart';

import 'widgets/common/city_search_sheet.dart';
import 'widgets/common/app_bottom_nav_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('zh_TW', null);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF08203E),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0),
      ),
      home: const MainScaffold(),
    );
  }
}

class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(pageIndexProvider);
    Widget _buildPage(int index) {
      switch (index) {
        case 0:
          return const HomePage();
        case 1:
          return const AITripPage();
        case 2:
          return const FavoritePage();
        default:
          return const HomePage();
      }
    }
    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 260),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: (child, animation) {
          final slideAnimation = Tween<Offset>(
            begin: const Offset(0.04, 0),
            end: Offset.zero,
          ).animate(animation);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: slideAnimation,
              child: child,
            ),
          );
        },
        child: KeyedSubtree(
          key: ValueKey<int>(index),
          child: _buildPage(index),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        elevation: 8,
        backgroundColor: Colors.lightBlueAccent,
        foregroundColor: Colors.black87,
        shape: const CircleBorder(),
        onPressed: () => _openCitySearch(context, ref),
        child: const Icon(
          Icons.search_rounded,
          size: 30,
        ),
      ),

      bottomNavigationBar: AppBottomNavBar(
        currentIndex: index,
        onHomeTap: () {
          ref.read(pageIndexProvider.notifier).setIndex(0);
        },
        onAiTripTap: () {
          ref.read(pageIndexProvider.notifier).setIndex(1);
        },
        onFavoriteTap: () {
          ref.read(pageIndexProvider.notifier).setIndex(2);
        },
      ),
    );
  }
  Future<void> _openCitySearch(
      BuildContext context,
      WidgetRef ref,
      ) async {
    final selectedCity = await showCitySearchSheet(context);

    if (!context.mounted) return;

    if (selectedCity == null) {
      return;
    }

    ref
        .read(activeLocationProvider.notifier)
        .updateLocation(selectedCity);

    ref.read(pageIndexProvider.notifier).setIndex(0);
  }
}