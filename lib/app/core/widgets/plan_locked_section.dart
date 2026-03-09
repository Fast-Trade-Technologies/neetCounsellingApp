import 'dart:math';
import 'dart:ui';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/url_launcher_util.dart' show launchPaymentPage, iosPurchaseDisclaimer;

/// Renders a list where items after [unlockedCount] are blurred/locked and a single
/// centered upgrade CTA is shown (same pattern used across the app).
class PlanLockedSection extends StatelessWidget {
  const PlanLockedSection({
    super.key,
    required this.isActivePlan,
    required this.itemCount,
    required this.unlockedCount,
    required this.itemBuilder,
    this.itemSpacing,
    this.title = 'Upgrade to Unlock Full List',
    this.buttonText = 'Buy Package',
    this.lockedPreviewCount = 3,
  });

  final bool isActivePlan;
  final int itemCount;
  final int unlockedCount;
  final IndexedWidgetBuilder itemBuilder;
  final double? itemSpacing;
  final String title;
  final String buttonText;
  /// How many locked items to preview under the blur overlay.
  /// This keeps the locked section short so the page doesn't scroll too much when locked.
  final int lockedPreviewCount;

  @override
  Widget build(BuildContext context) {
    final spacing = itemSpacing ?? 12.h;
    final bool isIOS = !kIsWeb && Platform.isIOS;

    if (itemCount <= 0) return const SizedBox.shrink();
    if (isActivePlan || itemCount <= unlockedCount) {
      return Column(
        children: [
          for (int i = 0; i < itemCount; i++) ...[
            itemBuilder(context, i),
            if (i < itemCount - 1) SizedBox(height: spacing),
          ],
        ],
      );
    }

    final visible = unlockedCount.clamp(0, itemCount);
    final lockedCount = (itemCount - visible).clamp(0, itemCount);

    return Column(
      children: [
        for (int i = 0; i < visible; i++) ...[
          itemBuilder(context, i),
          if (i < itemCount - 1) SizedBox(height: spacing),
        ],
        if (lockedCount > 0) ...[
          SizedBox(height: spacing),
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                  child: Opacity(
                    opacity: 0.25,
                    child: IgnorePointer(
                      child: Column(
                        children: [
                          for (int i = visible;
                              i < visible + min(lockedCount, lockedPreviewCount);
                              i++) ...[
                            itemBuilder(context, i),
                            if (i < visible + min(lockedCount, lockedPreviewCount) - 1)
                              SizedBox(height: spacing),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: AppColors.chipBorder),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textDark.withValues(alpha: 0.10),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_rounded, size: 34.sp, color: Colors.redAccent),
                    SizedBox(height: 8.h),
                    Text(title, style: AppTextStyles.welcomeHeading, textAlign: TextAlign.center),
                    SizedBox(height: 10.h),
                    if (!isIOS) ...[
                      InkWell(
                        onTap: () => launchPaymentPage(),
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: AppColors.navBarActive,
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Text(
                            buttonText,
                            style: AppTextStyles.buttonText.copyWith(fontSize: 12.sp),
                          ),
                        ),
                      ),
                    ],
                    if (isIOS) ...[
                      SizedBox(height: 12.h),
                      Text(
                        iosPurchaseDisclaimer,
                        style: AppTextStyles.bodyS.copyWith(
                          fontSize: 10.sp,
                          color: AppColors.textMuted,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

