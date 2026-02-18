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
        title: 'Seat Distribution',
        subtitle: 'An organised overview of seat distribution in medical colleges, by quota, category and sub-category under state and central counselling.',
        onBack: () => Get.back(),
        onFilter: () => _openFilterSheet(context),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refresh(),
        color: AppColors.primaryBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
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
      ),
    );
  }

  void _openFilterSheet(BuildContext context) {
    showFilterSheet(
      context: context,
      onSubmit: controller.submit,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _showStatePicker(context),
                  borderRadius: BorderRadius.circular(12.r),
                  child: Obx(() => DetailDropdown(
                    label: 'All States',
                    value: controller.selectedStateName.value.isEmpty || controller.selectedStateName.value == 'All States'
                        ? null
                        : controller.selectedStateName.value,
                    items: null,
                  )),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: InkWell(
                  onTap: () => _showCoursePicker(context),
                  borderRadius: BorderRadius.circular(12.r),
                  child: Obx(() => DetailDropdown(
                    label: 'Select Course',
                    value: controller.selectedCourseName.value == 'Select Course'
                        ? null
                        : controller.selectedCourseName.value,
                    items: null,
                  )),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: InkWell(
                  onTap: () => _showYearPicker(context),
                  borderRadius: BorderRadius.circular(12.r),
                  child: Obx(() => DetailDropdown(
                    label: 'Year',
                    value: controller.selectedYear.value,
                    items: SeatDistributionController.yearOptions,
                  )),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showStatePicker(BuildContext context) {
    final states = controller.stateFilters;
    final scrollController = ScrollController();
    final maxHeight = MediaQuery.of(context).size.height * 0.5;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text('Select State', style: AppTextStyles.welcomeHeading),
              ),
              SizedBox(
                height: maxHeight,
                child: Scrollbar(
                  controller: scrollController,
                  thumbVisibility: true,
                  child: ListView(
                    controller: scrollController,
                    shrinkWrap: true,
                    children: [
                      ListTile(
                        title: Text('All States', style: AppTextStyles.bodyS),
                        onTap: () {
                          controller.setStateFilter(null);
                          Navigator.pop(ctx);
                        },
                      ),
                      ...states.map((e) => ListTile(
                        title: Text(e.name, style: AppTextStyles.bodyS),
                        onTap: () {
                          controller.setStateFilter(e);
                          Navigator.pop(ctx);
                        },
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCoursePicker(BuildContext context) {
    final scrollController = ScrollController();
    final maxHeight = MediaQuery.of(context).size.height * 0.45;
    final options = SeatDistributionController.courseOptions;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text('Select Course', style: AppTextStyles.welcomeHeading),
              ),
              SizedBox(
                height: maxHeight,
                child: Scrollbar(
                  controller: scrollController,
                  thumbVisibility: true,
                  child: ListView(
                    controller: scrollController,
                    shrinkWrap: true,
                    children: options
                        .map((e) => ListTile(
                              title: Text(
                                e['name']!,
                                style: AppTextStyles.bodyS.copyWith(
                                  color: (e['id'] ?? '').isEmpty
                                      ? AppColors.textMuted
                                      : AppColors.textDark,
                                ),
                              ),
                              onTap: () {
                                controller.setCourseFilter(e['id'] ?? '', e['name'] ?? 'Select Course');
                                Navigator.pop(ctx);
                              },
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showYearPicker(BuildContext context) {
    final scrollController = ScrollController();
    final maxHeight = MediaQuery.of(context).size.height * 0.4;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text('Select Year', style: AppTextStyles.welcomeHeading),
              ),
              SizedBox(
                height: maxHeight,
                child: Scrollbar(
                  controller: scrollController,
                  thumbVisibility: true,
                  child: ListView(
                    controller: scrollController,
                    shrinkWrap: true,
                    children: SeatDistributionController.yearOptions
                        .map((y) => ListTile(
                              title: Text(y, style: AppTextStyles.bodyS),
                              onTap: () {
                                controller.setYear(y);
                                Navigator.pop(ctx);
                              },
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChip(String label, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.chipBorder.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.chipBorder),
      ),
      child: Text(
        '$label: $value',
        style: AppTextStyles.bodyS.copyWith(fontSize: 11.sp),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
      child: Obx(() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            controller.selectedStateName.value.isEmpty || controller.selectedStateName.value == 'All States'
                ? 'All States'
                : controller.selectedStateName.value,
            style: AppTextStyles.welcomeHeading,
          ),
          SizedBox(height: 8.h),
          Wrap(
            children: [
              _filterChip('State', controller.selectedStateName.value.isEmpty ? 'All States' : controller.selectedStateName.value),
              SizedBox(width: 8.w,height: 5.h),
              _filterChip('Course', controller.selectedCourseName.value),
              SizedBox(width: 8.w,height: 5.h),
              Padding(
                padding: EdgeInsets.only(bottom: 5.h,right: 5.w,top: 5.h),
                child: _filterChip('Year', controller.selectedYear.value)),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'An organised overview of seat distribution in medical colleges, by quota, category and sub-category under state and central counselling.',
            style: AppTextStyles.detailScreenSubtitle,
          ),
        ],
      )),
    );
  }

  static const List<Color> _chartColors = [
    Color(0xFF1A5276),
    Color(0xFF17A589),
    Color(0xFFF4D03F),
    Color(0xFFE74C3C),
    Color(0xFF5DADE2),
    Color(0xFFE67E22),
    Color(0xFF9B59B6),
    Color(0xFF1ABC9C),
  ];

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
          Obx(() {
            final rows = controller.tableRows;
            if (rows.isEmpty) {
              return SizedBox(height: 180.h, child: Center(child: Text('No data for chart', style: AppTextStyles.detailScreenSubtitle)));
            }
            return SizedBox(
              height: 220.h,
              child: CustomPaint(
                size: Size(200.w, 200.w),
                painter: _SeatDistributionPiePainter(rows: rows.toList(), colors: _chartColors),
              ),
            );
          }),
          SizedBox(height: 16.h),
          _buildTableHeader(),
          SizedBox(height: 8.h),
          Obx(() {
            final rows = controller.tableRows;
            if (rows.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text(
                  'No seat distribution data found.',
                  style: AppTextStyles.detailScreenSubtitle.copyWith(color: AppColors.textMuted),
                ),
              );
            }
            return Column(
              children: [
                for (int i = 0; i < rows.length; i++)
                  _buildTableRow(
                    _chartColors[i % _chartColors.length],
                    rows[i].seatTypeName,
                    '${rows[i].totalSeats}',
                    '${rows[i].totalColleges}',
                    '${rows[i].totalCategories}',
                  ),
              ],
            );
          }),
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
              maxLines: 2,
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

/// Pie chart painter driven by [SeatDistributionRow] data (totalSeats per seat type).
class _SeatDistributionPiePainter extends CustomPainter {
  _SeatDistributionPiePainter({required this.rows, required this.colors});

  final List<SeatDistributionRow> rows;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final total = rows.fold<int>(0, (sum, r) => sum + r.totalSeats);
    if (total <= 0) return;

    const startAngle = -3.14159 / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.42;

    var sweepStart = startAngle;
    for (var i = 0; i < rows.length; i++) {
      final sweep = (rows[i].totalSeats / total) * 2 * 3.14159;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        sweepStart,
        sweep,
        true,
        paint,
      );
      sweepStart += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _SeatDistributionPiePainter oldDelegate) =>
      oldDelegate.rows != rows;
}
