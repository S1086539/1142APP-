import 'package:flutter/material.dart';

import '../../services/location_service.dart';
import 'app_snack_bar.dart';

Future<String?> showCitySearchSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _CitySearchSheet(),
  );
}

class _CitySearchSheet extends StatefulWidget {
  const _CitySearchSheet();

  @override
  State<_CitySearchSheet> createState() => _CitySearchSheetState();
}

class _CitySearchSheetState extends State<_CitySearchSheet> {
  final TextEditingController _controller = TextEditingController();

  bool _isLocating = false;

  static const List<String> _cities = [
    '臺北市',
    '新北市',
    '桃園市',
    '臺中市',
    '臺南市',
    '高雄市',
    '基隆市',
    '新竹市',
    '嘉義市',
    '新竹縣',
    '苗栗縣',
    '彰化縣',
    '南投縣',
    '雲林縣',
    '嘉義縣',
    '屏東縣',
    '宜蘭縣',
    '花蓮縣',
    '臺東縣',
    '澎湖縣',
    '金門縣',
    '連江縣',
  ];

  static const List<String> _popularCities = [
    '臺北市',
    '新北市',
    '臺中市',
    '臺南市',
    '高雄市',
    '花蓮縣',
  ];

  List<String> get _filteredCities {
    final query = _controller.text.trim().replaceAll('台', '臺');

    if (query.isEmpty) {
      return _cities;
    }

    return _cities.where((city) {
      return city.contains(query);
    }).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    if (_isLocating) return;

    setState(() {
      _isLocating = true;
    });

    final city = await LocationService().getCurrentCity();

    if (!mounted) return;

    setState(() {
      _isLocating = false;
    });

    if (city == null) {
      AppSnackBar.show(
        context,
        message: '定位失敗，請確認定位權限或網路連線',
        type: AppSnackType.error,
      );
      return;
    }

    Navigator.pop(context, city);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: MediaQuery.of(context).size.height * 0.78,
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        decoration: const BoxDecoration(
          color: Color(0xFF102A46),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Column(
          children: [
            _buildHandle(),
            const SizedBox(height: 18),
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildLocationShortcut(),
            const SizedBox(height: 16),
            _buildPopularCities(),
            const SizedBox(height: 16),
            _buildSearchField(),
            const SizedBox(height: 16),
            Expanded(
              child: _buildCityList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 44,
      height: 5,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            '搜尋城市',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
      ],
    );
  }

  Widget _buildLocationShortcut() {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: _useCurrentLocation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.lightBlueAccent.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.lightBlueAccent.withValues(alpha: 0.28),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: _isLocating
                  ? const Padding(
                padding: EdgeInsets.all(11),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Icon(
                Icons.my_location_rounded,
                color: Colors.lightBlueAccent,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isLocating ? '正在定位中' : '使用目前定位',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    '自動偵測目前所在縣市',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularCities() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.star_rounded,
              size: 18,
              color: Colors.orangeAccent,
            ),
            SizedBox(width: 6),
            Text(
              '常用城市',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _popularCities.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final city = _popularCities[index];

              return InkWell(
                borderRadius: BorderRadius.circular(999),
                onTap: () {
                  Navigator.pop(context, city);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Text(
                    city,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _controller,
      autofocus: false,
      onChanged: (_) {
        setState(() {});
      },
      decoration: InputDecoration(
        hintText: '輸入縣市，例如：臺北市、花蓮縣',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            _controller.clear();
            setState(() {});
          },
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.10),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(
            color: Colors.lightBlueAccent.withValues(alpha: 0.8),
          ),
        ),
      ),
    );
  }

  Widget _buildCityList() {
    final cities = _filteredCities;

    if (cities.isEmpty) {
      return const Center(
        child: Text(
          '找不到支援的縣市',
          style: TextStyle(
            color: Colors.white60,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: cities.length,
      separatorBuilder: (_, __) => Divider(
        color: Colors.white.withValues(alpha: 0.08),
        height: 1,
      ),
      itemBuilder: (context, index) {
        final city = cities[index];

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_city_rounded,
              size: 20,
              color: Colors.lightBlueAccent,
            ),
          ),
          title: Text(
            city,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          trailing: const Icon(
            Icons.chevron_right_rounded,
            color: Colors.white54,
          ),
          onTap: () {
            Navigator.pop(context, city);
          },
        );
      },
    );
  }
}