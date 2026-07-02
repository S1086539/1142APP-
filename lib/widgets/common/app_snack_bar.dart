import 'package:flutter/material.dart';

enum AppSnackType {
  success,
  warning,
  error,
  info,
}

class AppSnackBar {
  static void show(
      BuildContext context, {
        required String message,
        AppSnackType type = AppSnackType.info,
        Duration duration = const Duration(seconds: 2),
      }) {
    final data = _getSnackData(type);

    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        elevation: 0,
        backgroundColor: const Color(0xFF102A46).withValues(alpha: 0.96),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: data.color.withValues(alpha: 0.35),
          ),
        ),
        content: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: data.color.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(
                data.icon,
                size: 19,
                color: data.color,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static _SnackData _getSnackData(AppSnackType type) {
    switch (type) {
      case AppSnackType.success:
        return const _SnackData(
          icon: Icons.check_circle_rounded,
          color: Colors.greenAccent,
        );

      case AppSnackType.warning:
        return const _SnackData(
          icon: Icons.warning_amber_rounded,
          color: Colors.orangeAccent,
        );

      case AppSnackType.error:
        return const _SnackData(
          icon: Icons.error_outline_rounded,
          color: Colors.redAccent,
        );

      case AppSnackType.info:
        return const _SnackData(
          icon: Icons.info_outline_rounded,
          color: Colors.lightBlueAccent,
        );
    }
  }
}

class _SnackData {
  final IconData icon;
  final Color color;

  const _SnackData({
    required this.icon,
    required this.color,
  });
}