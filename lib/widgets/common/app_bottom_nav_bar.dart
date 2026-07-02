import 'package:flutter/material.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final VoidCallback onHomeTap;
  final VoidCallback onFavoriteTap;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onHomeTap,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 86,
      padding: EdgeInsets.zero,
      color: Colors.black.withValues(alpha: 0.48),
      elevation: 0,
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 74,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _NavItem(
                  icon: Icons.home_rounded,
                  label: '首頁',
                  selected: currentIndex == 0,
                  onTap: onHomeTap,
                ),

                const SizedBox(width: 64),

                _NavItem(
                  icon: Icons.bookmark_rounded,
                  label: '關注',
                  selected: currentIndex == 1,
                  onTap: onFavoriteTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? Colors.lightBlueAccent : Colors.white54;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: SizedBox(
        width: 76,
        height: 58,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.lightBlueAccent.withValues(alpha: 0.16)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(
                icon,
                size: 23,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}