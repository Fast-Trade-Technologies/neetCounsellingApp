import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';

/// Single place for all app snackbars. Change styling/duration here to reflect everywhere.
enum SnackbarType { success, error, warning, info }

class AppSnackbar {
  AppSnackbar._();

  static SnackPosition get _defaultPosition => SnackPosition.BOTTOM;
  static Duration get _defaultDuration => const Duration(seconds: 2);

  static Color _colorFor(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return AppColors.brandGreen;
      case SnackbarType.error:
        return Colors.red.shade600;
      case SnackbarType.warning:
        return AppColors.accentOrange;
      case SnackbarType.info:
        return AppColors.primaryBlue;
    }
  }

  /// Show snackbar with optional type (affects left bar color).
  static void show(
    String title,
    String message, {
    SnackbarType type = SnackbarType.info,
    SnackPosition? position,
    Duration? duration,
    bool dismissible = true,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: position ?? _defaultPosition,
      duration: duration ?? _defaultDuration,
      isDismissible: dismissible,
      dismissDirection: DismissDirection.horizontal,
      backgroundColor: Colors.white,
      colorText: AppColors.textDark,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 12,
      boxShadows: [
        BoxShadow(
          color: AppColors.textDark.withValues(alpha: 0.12),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      leftBarIndicatorColor: _colorFor(type),
    );
  }

  static void success(String title, String message, {Duration? duration}) =>
      show(title, message, type: SnackbarType.success, duration: duration);

  static void error(String title, String message, {Duration? duration}) =>
      show(title, message, type: SnackbarType.error, duration: duration);

  static void warning(String title, String message, {Duration? duration}) =>
      show(title, message, type: SnackbarType.warning, duration: duration);

  static void info(String title, String message, {Duration? duration}) =>
      show(title, message, type: SnackbarType.info, duration: duration);
}
