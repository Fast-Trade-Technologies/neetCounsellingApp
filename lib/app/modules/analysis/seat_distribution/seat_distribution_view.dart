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
        title: 'Analysis Seat Distribution',
        subtitle: 'Seat Distribution',
        onBack: () => Get.back(),
        hideFilter: true,
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refresh(),
        color: AppColors.primaryBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              SizedBox(height: 14.h),
              _buildFilterRowCard(context),
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
                          controller.submit();
                        },
                      ),
                      ...states.map((e) => ListTile(
                            title: Text(e.name, style: AppTextStyles.bodyS),
                            onTap: () {
                              controller.setStateFilter(e);
                              Navigator.pop(ctx);
                              controller.submit();
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
                        .map(
                          (e) => ListTile(
                            title: Text(
                              e['name']!,
                              style: AppTextStyles.bodyS.copyWith(
                                color: (e['id'] ?? '').isEmpty
                                    ? AppColors.textMuted
                                    : AppColors.textDark,
                              ),
                            ),
                            onTap: () {
                              controller.setCourseFilter(
                                e['id'] ?? '',
                                e['name'] ?? 'Select Course',
                              );
                              Navigator.pop(ctx);
                              controller.submit();
                            },
                          ),
                        )
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
                  child: Obx(
                    () => ListView(
                      controller: scrollController,
                      shrinkWrap: true,
                      children: controller.yearOptions
                          .map(
                            (y) => ListTile(
                              title: Text(y, style: AppTextStyles.bodyS),
                              onTap: () {
                                controller.setYear(y);
                                Navigator.pop(ctx);
                                controller.submit();
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
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

  /// Header card: state name + subtitle + filter icon (same style as college_seats_view).
  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: Colors.white,
        elevation: 5,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.r),
          side: BorderSide(color: AppColors.border),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
          child: Obx(() {
            final stateName = controller.selectedStateName.value.isEmpty ||
                    controller.selectedStateName.value == 'All States'
                ? 'All States'
                : controller.selectedStateName.value;
            return Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        stateName,
                        style: AppTextStyles.welcomeHeading.copyWith(fontSize: 14.sp),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Select a year to view the Seat Distribution Analysis',
                        style: AppTextStyles.bodyM.copyWith(
                          color: const Color(0xFF47576B),
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _openFilterSheet(context),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Padding(
                      padding: EdgeInsets.all(8.w),
                      child: Icon(
                        Icons.filter_list_rounded,
                        size: 24.sp,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  /// Filter row card: All States, Select Course, Year (same style as image).
  Widget _buildFilterRowCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE6EDF5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _showStatePicker(context),
              borderRadius: BorderRadius.circular(12.r),
              child: Obx(() => DetailDropdown(
                    label: 'All States',
                    value: controller.selectedStateName.value.isEmpty ||
                            controller.selectedStateName.value == 'All States'
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
      padding: EdgeInsets.all(7.w),
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

          /// Table data from API (styled like image: light grey container, white rows, thin grey dividers)
          Obx(() {
            final rows = controller.tableRows;
            if (rows.isEmpty) return const SizedBox.shrink();
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F4F8),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE6EDF5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Padding(
                  //   padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 10.h),
                  //   child: Text(
                  //     'Seat Type Summary',
                  //     style: AppTextStyles.welcomeHeading.copyWith(fontSize: 14.sp),
                  //   ),
                  // ),
                  _buildSummaryTableHeader(),
                  for (int i = 0; i < rows.length; i++)
                    _buildSummaryTableRow(
                      _chartColors[i % _chartColors.length],
                      rows[i].seatTypeName,
                      rows[i].totalSeats.toString(),
                      rows[i].totalCategories.toString(),
                      rows[i].totalColleges.toString(),
                      isLast: i == rows.length - 1,
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  static const Color _summaryDividerColor = Color(0xFFE2E8F0);

  Widget _buildSummaryTableHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: AppColors.chipBorder,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          SizedBox(width: 10.w),
          Expanded(
            flex: 2,
            child: Text(
              'Seat Types',
              style: AppTextStyles.bodyS.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
                fontSize: 12.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Total Seats',
              style: AppTextStyles.bodyS.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
                fontSize: 12.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Total Categories',
              style: AppTextStyles.bodyS.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
                fontSize: 12.sp,
              ),
               textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Total Colleges',
              style: AppTextStyles.bodyS.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
                fontSize: 12.sp,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTableRow(
    Color dotColor,
    String type,
    String seats,
    String categories,
    String colleges, {
    required bool isLast,
  }) {
    return Container(
      height: 35.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: isLast
            ? BorderRadius.vertical(bottom: Radius.circular(16.r))
            : null,
        border: Border(
          bottom: isLast
              ? BorderSide.none
              : BorderSide(color: _summaryDividerColor, width: 1),
        ),
      ),
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
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.textDark,
                fontSize: 12.sp,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Text(
              seats,
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.textDark,
                fontSize: 12.sp,
              ),
            ),
          ),
          Expanded(
            child: Text(
              categories,
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.textDark,
                fontSize: 12.sp,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              colleges,
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.textDark,
                fontSize: 12.sp,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // ignore: unused_element
  Widget _buildTableHeader() {
    return _buildSummaryTableHeader();
  }

  Widget _buildTableRow(Color dotColor, String type, String seats, String colleges, String categories) {
    return _buildSummaryTableRow(dotColor, type, seats, categories, colleges, isLast: false);
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