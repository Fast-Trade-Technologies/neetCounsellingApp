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
              Text(
                'Courses',
                style: AppTextStyles.titleM.copyWith(color: AppColors.textDark),
              ),
              SizedBox(height: 4.h),
              Text(
                'Browse all courses offered through NEET counselling to find the right fit for your career.',
                style: AppTextStyles.detailScreenSubtitle.copyWith(color: AppColors.textDark),
              ),
              SizedBox(height: 16.h),
              _buildFilterCard(context),
              SizedBox(height: 16.h),
              _buildResultsCard(context),
              SizedBox(height: 24.h),
          ],
        ),
        ),
      ),
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

  Widget _buildFilterCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(),
      child: Obx(() {
        if (controller.filtersLoading.value) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Courses', style: AppTextStyles.welcomeHeading),
            SizedBox(height: 14.h),
            Row(
              children: [
                Expanded(
                  child: _LabelDropdown(
                    label: 'Degree Type',
                    value: controller.selectedDegreeTypeName.value,
                    items: controller.degreeTypeNames,
                    onChanged: controller.setDegreeType,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _LabelDropdown(
                    label: 'Course',
                    value: controller.selectedCourseName.value,
                    items: controller.courseNames,
                    onChanged: controller.setCourse,
                  ),
                ),
              ],
            ),
          ],
        );
      }),
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
    final treeData = controller.treeDataForChart;
    final courses = controller.filteredCourses;
    final hasTree = treeData.isNotEmpty;
    final chartItems = hasTree
        ? treeData
            .asMap()
            .entries
            .map((e) => (
                  label: e.value.displayName,
                  duration: e.value.value?.toString() ?? '',
                  color: _chartColors[e.key % _chartColors.length],
                ))
            .toList()
        : courses
            .asMap()
            .entries
            .map((e) => (
                  label: e.value.degreeTerms,
                  duration: e.value.durationShort,
                  color: _chartColors[e.key % _chartColors.length],
                ))
            .toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 200.w,
          width: 200.w,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: Size(200.w, 200.w),
                painter: _DonutChartPainter(items: chartItems),
              ),
              SizedBox(
                width: 84.w,
                height: 84.w,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textDark.withValues(alpha: 0.08),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'Medical\nUG',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyS.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 4.h,
          children: (chartItems).asMap().entries.map((e) {
            final label = e.value.label;
            final color = e.value.color;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                SizedBox(width: 4.w),
                Text(
                  label,
                  style: AppTextStyles.bodyS.copyWith(fontSize: 9.sp, color: AppColors.textDark),
                ),
              ],
            );
          }).toList(),
        ),
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
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
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
              items: items.map((e) => DropdownMenuItem<String>(value: e, child: Text(e, maxLines: 1, overflow: TextOverflow.ellipsis))).toList(),
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

class _DonutChartPainter extends CustomPainter {
  _DonutChartPainter({required this.items});

  final List<({String label, String duration, Color color})> items;

  @override
  void paint(Canvas canvas, Size size) {
    if (items.isEmpty) return;
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.shortestSide / 2 - 4;
    final innerRadius = outerRadius * 0.42;
    final strokeWidth = outerRadius - innerRadius;
    final arcRadius = innerRadius + strokeWidth / 2;
    final sweepPerItem = (2 * 3.14159265359) / items.length;
    var start = -3.14159265359 / 2;
    for (final item in items) {
      final paint = Paint()
        ..color = item.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: arcRadius),
        start,
        sweepPerItem - 0.02,
        false,
        paint,
      );
      start += sweepPerItem;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
