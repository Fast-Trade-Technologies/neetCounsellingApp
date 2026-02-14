import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/detail_app_bar.dart';
import '../../../core/widgets/detail_dropdown.dart';
import '../../../core/widgets/filter_bottom_sheet.dart';
import 'seat_distribution_controller.dart';

class SeatDistributionView extends GetView<SeatDistributionController> {
  const SeatDistributionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DetailAppBar(
        title: 'Analysis College &...',
        subtitle: 'Seat distribution',
        onBack: () => Get.back(),
        onFilter: () => _openFilterSheet(context),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopCard(),
            SizedBox(height: 14.h),
            Obx(() => controller.showResults.value
                ? _buildPieChartCard()
                : SizedBox(height: 80.h)),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  void _openFilterSheet(BuildContext context) {
    showFilterSheet(
      context: context,
      onSubmit: controller.submit,
      child: Row(
        children: [
          Expanded(child: DetailDropdown(label: 'All States')),
          SizedBox(width: 10.w),
          Expanded(child: DetailDropdown(label: 'Select Course')),
          SizedBox(width: 10.w),
          Expanded(child: DetailDropdown(label: '2015')),
        ],
      ),
    );
  }

  Widget _buildTopCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.chipBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Uttar Pradesh', style: AppTextStyles.welcomeHeading),
          SizedBox(height: 4.h),
          Text(
            'Select 1 year to show the Seat Distribution Analysis',
            style: AppTextStyles.detailScreenSubtitle,
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.chipBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180.h,
            child: CustomPaint(
              size: Size(160.w, 160.w),
              painter: _PieChartPainter(),
            ),
          ),
          SizedBox(height: 16.h),
          _buildTableHeader(),
          SizedBox(height: 8.h),
          _buildTableRow(const Color(0xFF1A5276), 'Private', '6550', '8', '30'),
          _buildTableRow(const Color(0xFF17A589), 'Government State Quota', '4389', '3', '50'),
          _buildTableRow(const Color(0xFFF4D03F), 'Government State Quota', '4582', '3', '47'),
          _buildTableRow(const Color(0xFFE74C3C), 'Private', '8780', '4', '39'),
        ],
      ),
    );
  }

  Widget _buildTableHeader() {
    return Row(
      children: [
        SizedBox(width: 20.w),
        Expanded(
          flex: 2,
          child: Text(
            'Seat Types',
            style: AppTextStyles.bodyS.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ),
        Expanded(
          child: Text(
            'Total Seats',
            style: AppTextStyles.bodyS.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ),
        Expanded(
          child: Text(
            'Total Colleges',
            style: AppTextStyles.bodyS.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ),
        Expanded(
          child: Text(
            'Total Categories',
            style: AppTextStyles.bodyS.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTableRow(Color dotColor, String type, String seats, String colleges, String categories) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            flex: 2,
            child: Text(
              type,
              style: AppTextStyles.detailScreenSubtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(child: Text(seats, style: AppTextStyles.detailScreenSubtitle)),
          Expanded(child: Text(colleges, style: AppTextStyles.detailScreenSubtitle)),
          Expanded(child: Text(categories, style: AppTextStyles.detailScreenSubtitle)),
        ],
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      const Color(0xFF1A5276),
      const Color(0xFF17A589),
      const Color(0xFFF4D03F),
      const Color(0xFFE67E22),
      const Color(0xFF5DADE2),
      const Color(0xFF1A5276),
    ];
    final sweeps = [0.317, 0.081, 0.129, 0.056, 0.074, 0.037];
    var start = -1.5708;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.45;
    for (var i = 0; i < sweeps.length; i++) {
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweeps[i] * 2 * 3.14159,
        true,
        paint,
      );
      start += sweeps[i] * 2 * 3.14159;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
