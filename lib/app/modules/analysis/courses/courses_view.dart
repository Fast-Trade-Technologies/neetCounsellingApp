import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/detail_app_bar.dart';
import 'courses_controller.dart';

class CoursesView extends GetView<CoursesController> {
  const CoursesView({super.key});

  static const List<Color> _chartColors = [
    Color(0xFF58D68D),
    Color(0xFFE8B4B8),
    Color(0xFF5DADE2),
    Color(0xFF58D68D),
    Color(0xFFF4D03F),
    Color(0xFFE74C3C),
    Color(0xFF9B59B6),
    Color(0xFF28A745),
    Color(0xFFE8B4B8),
    Color(0xFF3498DB),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DetailAppBar(
        title: 'Courses',
        subtitle: 'Neet Counselling / Analysis / Courses',
        hideFilter: true,
        onBack: () => Get.back(),
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
              _buildHeaderCard(),
              SizedBox(height: 14.h),
              _buildFilterRowCard(context),
              SizedBox(height: 16.h),
              _buildResultsCard(context),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Courses',
                style: AppTextStyles.welcomeHeading.copyWith(fontSize: 14.sp),
              ),
              SizedBox(height: 4.h),
              Text(
                'Browse all courses offered through NEET counselling to find the right fit for your career.',
                style: AppTextStyles.bodyM.copyWith(
                  color: const Color(0xFF47576B),
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
      child: Obx(() {
        if (controller.filtersLoading.value) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        return Row(
          children: [
            Expanded(
              child: _LabelDropdown(
                label: 'Degree Type',
                value: controller.selectedDegreeTypeName.value,
                // Add a non-selectable header item (label-only) for better readability.
                items: ["Degree Types", ...controller.degreeTypeNames],
                onChanged: controller.setDegreeType,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _LabelDropdown(
                label: 'Course',
                value: controller.selectedCourseName.value,
                items: controller.courseNames,
                onChanged: controller.setCourse,
              ),
            ),
          ],
        );
      }),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
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
    );
  }

  Widget _buildResultsCard(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.filteredCourses.isEmpty) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: _cardDecoration(),
          child: const Center(child: CircularProgressIndicator()),
        );
      }
      if (controller.error.value.isNotEmpty && controller.filteredCourses.isEmpty) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Showing Results', style: AppTextStyles.welcomeHeading),
              SizedBox(height: 16.h),
              Center(
                child: Text(
                  controller.error.value,
                  style: AppTextStyles.bodyS.copyWith(color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      }
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Showing Results', style: AppTextStyles.welcomeHeading),
            SizedBox(height: 16.h),
            LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 400;
              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 220.w,
                      child: _buildDonutChart(),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(child: _buildTableSection()),
                  ],
                );
              }
              return Column(
                children: [
                  SizedBox(width: double.infinity, child: _buildDonutChart()),
                  SizedBox(height: 16.h),
                  _buildTableSection(),
                ],
              );
            },
          ),
        ],
      ),
    );
    });
  }

  Widget _buildDonutChart() {
    final nodes = controller.treeDataNodes;
    if (nodes.isEmpty) {
      return SizedBox(
        height: 220.w,
        width: 220.w,
        child: Center(
          child: Text(
            'No chart data',
            style: AppTextStyles.bodyS.copyWith(color: AppColors.textMuted),
          ),
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 260.w,
          width: 260.w,
          child: CustomPaint(
            size: Size(260.w, 260.w),
            painter: _CoursesSunburstPainter(
              nodes: nodes.toList(),
              centerTitle: 'UG\nMedical',
              colors: _chartColors,
            ),
          ),
        ),
        SizedBox(height: 12.h),
        // Wrap(
        //   spacing: 8.w,
        //   runSpacing: 4.h,
        //   children: nodes.asMap().entries.map((e) {
        //     final label = e.value.name;
        //     final color = _chartColors[e.key % _chartColors.length];
        //     return Row(
        //       mainAxisSize: MainAxisSize.min,
        //       children: [
        //         Container(
        //           width: 8.w,
        //           height: 8.w,
        //           decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        //         ),
        //         SizedBox(width: 4.w),
        //         Text(
        //           label,
        //           style: AppTextStyles.bodyS.copyWith(fontSize: 9.sp, color: AppColors.textDark),
        //         ),
        //       ],
        //     );
        //   }).toList(),
        // ),
      ],
    );
  }

  Widget _buildTableSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Obx(() => _EntriesDropdown(
              value: controller.entriesPerPage.value,
              options: CoursesController.entriesOptions,
              onChanged: controller.setEntriesPerPage,
            )),
            SizedBox(width: 12.w),
            Expanded(
              child: TextField(
                onChanged: controller.setSearchQuery,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: AppTextStyles.fieldHint,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                  isDense: true,
                ),
                style: AppTextStyles.bodyS.copyWith(color: AppColors.textDark),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Obx(() {
          final list = controller.paginatedCourses;
          if (list.isEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 24.h),
              child: Text(
                'No courses found.',
                style: AppTextStyles.bodyS.copyWith(color: AppColors.textMuted),
              ),
            );
          }
          return Column(
            children: [
              ...list.asMap().entries.map((e) => Padding(
                    padding: EdgeInsets.only(bottom: e.key < list.length - 1 ? 12.h : 0),
                    child: _CourseCard(course: e.value, serialNumber: e.key + 1),
                  )),
              SizedBox(height: 10.h),
              // Text(
              //   'Showing 1 to ${list.length} of $total entries',
              //   style: AppTextStyles.bodyS.copyWith(fontSize: 11.sp, color: AppColors.textMuted),
              // ),
            ],
          );
        }),
      ],
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.serialNumber});

  final CourseItem course;
  final int serialNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.chipBg,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              '$serialNumber',
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.degreeTerms,
                  style: AppTextStyles.bodyS.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  course.degreeType,
                  style: AppTextStyles.detailScreenSubtitle.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  course.year,
                  style: AppTextStyles.bodyS.copyWith(
                    color: AppColors.textDark,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LabelDropdown extends StatelessWidget {
  const _LabelDropdown({
    required this.label,
    required this.value,
    required this.items,
    this.extraItems = const [],
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final List<String> extraItems;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final allItems = <String>[...items, ...extraItems];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.detailScreenSubtitle.copyWith(
            fontSize: 11.sp,
            color: AppColors.textMuted,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.textDark.withValues(alpha: 0.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              isDense: true,
              icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20.sp, color: AppColors.textMuted),
              style: AppTextStyles.bodyS.copyWith(color: AppColors.textDark, fontSize: 12.sp),
              items: allItems.map((e) {
                final isHeader = e.trim().startsWith('—') && e.trim().endsWith('—');
                return DropdownMenuItem<String>(
                  value: e,
                  enabled: !isHeader,
                  child: Text(
                    e,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: isHeader
                        ? AppTextStyles.bodyS.copyWith(
                            color: AppColors.textMuted,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                          )
                        : null,
                  ),
                );
              }).toList(),
              onChanged: (v) => v != null ? onChanged(v) : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _EntriesDropdown extends StatelessWidget {
  const _EntriesDropdown({required this.value, required this.options, required this.onChanged});

  final int value;
  final List<int> options;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 155.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text(
          //   'Entries per page',
          //   style: AppTextStyles.detailScreenSubtitle.copyWith(fontSize: 11.sp, color: AppColors.textMuted),
          // ),
          // SizedBox(height: 6.h),
          Container(
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textDark.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: value,
                isExpanded: true,
                isDense: false,
                icon: Icon(Icons.keyboard_arrow_down_rounded, size: 22.sp, color: AppColors.primaryBlue),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                elevation: 8,
                style: AppTextStyles.bodyS.copyWith(color: AppColors.textDark, fontWeight: FontWeight.w600, fontSize: 13.sp),
                items: options.map((e) => DropdownMenuItem<int>(value: e, child: Text('$e', maxLines: 1, overflow: TextOverflow.ellipsis))).toList(),
                onChanged: (v) => v != null ? onChanged(v) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sunburst chart for courses: inner ring = course name, outer ring = year/duration (from API tree_data).
class _CoursesSunburstPainter extends CustomPainter {
  _CoursesSunburstPainter({
    required this.nodes,
    required this.centerTitle,
    required this.colors,
  });

  final List<CourseTreeNode> nodes;
  final String centerTitle;
  final List<Color> colors;

  double _degToRad(double deg) => deg * math.pi / 180.0;

  /// Shorten duration text: use capital Y for year, no trailing "s". e.g. "5.5 Years (1 Year Internship)" -> "5.5Y +1Y Int."
  static String _shorten(String year) {
    final y = year.trim();
    if (y.isEmpty) return '';
    // Replace "Years" and "Year" with capital "Y" so no stray "s" appears
    String toY(String s) =>
        s.replaceAll('Years', 'Y').replaceAll('Year', 'Y').replaceAll(RegExp(r'\s+'), ' ').trim();
    final lower = y.toLowerCase();
    if (lower.contains('internship')) {
      final parts = y.split('(');
      final firstPart = toY(parts.first);
      final intern = parts.length > 1 ? parts[1].replaceAll(')', '').trim() : '';
      final i = toY(intern)
          .replaceAll('Internship', ' Int.')
          .replaceAll('months', 'mo')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      // First part e.g. "Year 5.5 Y" -> "Y 5.5 Y"; drop leading Y, get "5.5Y"
      final f = firstPart.replaceAll(' ', '');
      final fClean = f.replaceFirst(RegExp(r'^Y+'), '');
      // Internship part e.g. "1 Y Int." -> "1Y Int." (capital Y for year)
      final iClean = i.replaceAll(' Y ', 'Y ').replaceAll(RegExp(r'\s+'), ' ').trim();
      return iClean.isEmpty ? fClean : '$fClean +$iClean';
    }
    return toY(y).replaceAll(' ', '');
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;

    final innerRingRadius = radius * 0.55;
    final innerStroke = radius * 0.22;
    final outerRingRadius = innerRingRadius + innerStroke;
    final outerStroke = radius * 0.38;

    final totalParent = nodes.fold<int>(0, (sum, n) => sum + n.value);
    if (totalParent == 0) return;

    double startAngle = -90.0;

    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      if (node.value <= 0) continue;
      final parentSweep = (node.value / totalParent) * 360.0;

      final parentColor = colors[i % colors.length];
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = innerStroke
        ..color = parentColor;

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
            ..color = parentColor.withValues(alpha: 0.5);

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

          final dividerPaint = Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = Colors.white.withValues(alpha: 0.9);
          final startRad = _degToRad(childStart);
          final from = center +
              Offset(
                (innerRingRadius + innerStroke) * math.cos(startRad),
                (innerRingRadius + innerStroke) * math.sin(startRad),
              );
          final to = center +
              Offset(
                (outerRingRadius + outerStroke) * math.cos(startRad),
                (outerRingRadius + outerStroke) * math.sin(startRad),
              );
          canvas.drawLine(from, to, dividerPaint);

          final childMidDeg = childStart + childSweep / 2;
          final childMidRad = _degToRad(childMidDeg);
          final childLabelRadius = outerRingRadius + outerStroke * 0.5;
          final childLabelOffset = center +
              Offset(
                childLabelRadius * math.cos(childMidRad),
                childLabelRadius * math.sin(childMidRad),
              );

          final shortLabel = _shorten(child.name);
          final childLabelSpan = TextSpan(
            text: shortLabel.isEmpty ? child.name : shortLabel,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          );
          final childLabelPainter = TextPainter(
            text: childLabelSpan,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            maxLines: 2,
          )..layout(maxWidth: radius * 0.4);

          final childLabelTopLeft = childLabelOffset -
              Offset(childLabelPainter.width / 2, childLabelPainter.height / 2);
          childLabelPainter.paint(canvas, childLabelTopLeft);

          childStart += childSweep;
        }
      }

      startAngle += parentSweep;
    }

    final innerHoleRadius = innerRingRadius * 0.65;
    final holePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    canvas.drawCircle(center, innerHoleRadius, holePaint);

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
      maxLines: 2,
    )..layout(maxWidth: innerHoleRadius * 1.6);

    final textOffset = center - Offset(textPainter.width / 2, textPainter.height / 2);
    textPainter.paint(canvas, textOffset);

    startAngle = -90.0;
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      if (node.value <= 0) continue;
      final parentSweep = (node.value / totalParent) * 360.0;
      final midAngleDeg = startAngle + parentSweep / 2;
      final midRad = _degToRad(midAngleDeg);

      final labelRadius = innerRingRadius + innerStroke * 0.35;
      final labelOffset = center +
          Offset(
            labelRadius * math.cos(midRad),
            labelRadius * math.sin(midRad),
          );

      final labelSpan = TextSpan(
        text: node.name,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 9,
          fontWeight: FontWeight.w500,
        ),
      );
      final labelPainter = TextPainter(
        text: labelSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: 2,
      )..layout(maxWidth: radius * 0.32);

      final labelTopLeft = labelOffset -
          Offset(labelPainter.width / 2, labelPainter.height / 2);
      labelPainter.paint(canvas, labelTopLeft);

      startAngle += parentSweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
