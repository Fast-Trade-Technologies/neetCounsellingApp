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
          // Counselling Type
          InkWell(
            onTap: () => _showCounsellingTypePicker(context),
            borderRadius: BorderRadius.circular(12.r),
            child: Obx(() => DetailDropdown(
                  label: 'Counselling Type',
                  value: controller.selectedCounsellingTypeId.value.isEmpty
                      ? null
                      : controller.selectedCounsellingTypeName.value,
                  items: null,
                )),
          ),
          SizedBox(height: 12.h),
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
                        items: controller.yearOptions,
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
                  child: Obx(() => ListView(
                        controller: scrollController,
                        shrinkWrap: true,
                        children: controller.yearOptions
                            .map((y) => ListTile(
                                  title: Text(y, style: AppTextStyles.bodyS),
                                  onTap: () {
                                    controller.setYear(y);
                                    Navigator.pop(ctx);
                                  },
                                ))
                            .toList(),
                      )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCounsellingTypePicker(BuildContext context) {
    final types = controller.counsellingTypeFilters;
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
                child: Text('Select Counselling Type', style: AppTextStyles.welcomeHeading),
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
                        title: Text('All Counselling Types', style: AppTextStyles.bodyS),
                        onTap: () {
                          controller.setCounsellingType(null);
                          Navigator.pop(ctx);
                        },
                      ),
                      ...types.map((e) => ListTile(
                            title: Text(e.name, style: AppTextStyles.bodyS),
                            onTap: () {
                              controller.setCounsellingType(e);
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
    return InkWell(
      onTap: () => _openFilterSheet(Get.context!),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
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
                  spacing: 8.w,
                  runSpacing: 6.h,
                  children: [
                    _filterChip('State', controller.selectedStateName.value.isEmpty ? 'All States' : controller.selectedStateName.value),
                    _filterChip(
                      'Counselling',
                      controller.selectedCounsellingTypeId.value.isEmpty
                          ? 'All'
                          : controller.selectedCounsellingTypeName.value,
                    ),
                    _filterChip('Course', controller.selectedCourseName.value),
                    _filterChip('Year', controller.selectedYear.value),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  'An organised overview of seat distribution in medical colleges, by quota, category and sub-category under state and central counselling.',
                  style: AppTextStyles.detailScreenSubtitle,
                ),
              ],
            )),
      ),
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
            final nodes = controller.treeData;
            if (nodes.isEmpty) {
              return SizedBox(
                height: 220.h,
                child: Center(
                  child: Text(
                    'No data for chart',
                    style: AppTextStyles.detailScreenSubtitle,
                  ),
                ),
              );
            }

            final stateName = controller.selectedStateName.value.isEmpty
                ? 'State Seat Distribution'
                : '${controller.selectedStateName.value}\nState Seat\nDistribution';

            return SizedBox(
              height: 260.h,
              child: CustomPaint(
                size: Size(220.w, 220.w),
                painter: _SeatDistributionSunburstPainter(
                  nodes: nodes.toList(),
                  centerTitle: stateName,
                  colors: _chartColors,
                ),
              ),
            );
          }),

          SizedBox(height: 16.h),

          /// Legend
          Obx(() {
            final labels = controller.seatLabels;
            final values = controller.seatSeries;

            return Column(
              children: [
                for (int i = 0; i < labels.length; i++)
                  _buildTableRow(
                    _chartColors[i % _chartColors.length],
                    labels[i],
                    values[i].toString(),
                    '',
                    '',
                  ),
              ],
            );
          }),

          SizedBox(height: 16.h),

          /// Table data from API
          Obx(() {
            final rows = controller.tableRows;
            if (rows.isEmpty) return const SizedBox.shrink();
            return Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFD),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.chipBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seat Type Summary',
                    style: AppTextStyles.welcomeHeading.copyWith(fontSize: 14.sp),
                  ),
                  SizedBox(height: 10.h),
                  _buildTableHeader(),
                  SizedBox(height: 6.h),
                  const Divider(height: 1),
                  SizedBox(height: 8.h),
                  for (int i = 0; i < rows.length; i++)
                    _buildTableRow(
                      _chartColors[i % _chartColors.length],
                      rows[i].seatTypeName,
                      rows[i].totalSeats.toString(),
                      rows[i].totalColleges.toString(),
                      rows[i].totalCategories.toString(),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ignore: unused_element
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
class _SeatDistributionSunburstPainter extends CustomPainter {
  _SeatDistributionSunburstPainter({
    required this.nodes,
    required this.centerTitle,
    required this.colors,
  });

  final List<SeatTreeNode> nodes;
  final String centerTitle;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;

    final innerRingRadius = radius * 0.40;
    final innerStroke = radius * 0.26;
    // Make outer ring start exactly where inner ring ends (no gap).
    final outerRingRadius = innerRingRadius + innerStroke;
    final outerStroke = radius * 0.24;

    final totalParent = nodes.fold<int>(0, (sum, n) => sum + n.value);
    if (totalParent == 0) return;

    double startAngle = -90.0;

    // Draw inner ring for Government vs Private (or other parent seat types)
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      if (node.value <= 0) continue;
      final parentSweep = (node.value / totalParent) * 360.0;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = innerStroke
        ..color = colors[i % colors.length];

      final rect = Rect.fromCircle(
        center: center,
        radius: innerRingRadius + innerStroke / 2,
      );

      canvas.drawArc(
        rect,
        _degToRad(startAngle),
        _degToRad(parentSweep),
        false,
        paint,
      );

      // Draw outer ring segments for children of this parent.
      // Each child’s sweep is proportional to its share of the PARENT value,
      // so the sum of children exactly matches the parent arc.
      final children = node.children;
      if (children.isNotEmpty) {
        double childStart = startAngle;
        for (int j = 0; j < children.length; j++) {
          final child = children[j];
          if (child.value <= 0) continue;
          final childSweep = parentSweep * (child.value / node.value);

          final childPaint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = outerStroke
            ..color = colors[(i + j + 1) % colors.length].withValues(alpha: 0.9);

          final outerRect = Rect.fromCircle(
            center: center,
            radius: outerRingRadius + outerStroke / 2,
          );

          canvas.drawArc(
            outerRect,
            _degToRad(childStart),
            _degToRad(childSweep),
            false,
            childPaint,
          );

          childStart += childSweep;
        }
      }

      startAngle += parentSweep;
    }

    // Center white circle
    final innerHoleRadius = innerRingRadius * 0.9;
    final holePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    canvas.drawCircle(center, innerHoleRadius, holePaint);

    // Center text
    final textSpan = TextSpan(
      text: centerTitle,
      style: const TextStyle(
        color: Colors.black87,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 3,
    )..layout(maxWidth: innerHoleRadius * 1.6);

    final textOffset = center - Offset(textPainter.width / 2, textPainter.height / 2);
    textPainter.paint(canvas, textOffset);
  }

  double _degToRad(double deg) => deg * 3.1415926535897932 / 180.0;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}