import 'package:flutter/material.dart';

/// Wraps the app to constrain max width on large screens (tablets) for better
/// readability and consistent phone-like layout. Centers content when constrained.
class ResponsiveWrapper extends StatelessWidget {
  const ResponsiveWrapper({super.key, required this.child, this.maxWidth});

  final Widget child;
  final double? maxWidth;

  static double get defaultMaxWidth => 500;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width <= 0) return child;
    final effectiveMax = maxWidth ?? defaultMaxWidth;
    if (width > effectiveMax) {
      return Center(
        child: SizedBox(
          width: effectiveMax,
          child: child,
        ),
      );
    }
    return child;
  }
}

/// Minimum touch target size (48 logical pixels recommended by Material).
const double kMinTouchTarget = 48;
