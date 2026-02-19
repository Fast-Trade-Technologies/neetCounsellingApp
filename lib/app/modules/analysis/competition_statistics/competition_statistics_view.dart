import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/detail_app_bar.dart';
import 'competition_statistics_controller.dart';

class CompetitionStatisticsView extends GetView<CompetitionStatisticsController> {
  const CompetitionStatisticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DetailAppBar(
        title: 'NEET UG Competition Statistics',
        subtitle: 'NEET Counselling / Analysis / NEET UG Competition Statistics',
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
              _buildBreakdownCard(context),
              SizedBox(height: 16.h),
              _buildYearlyInsightsCard(),
              SizedBox(height: 16.h),
              Obx(() {
                final tabIndex = controller.breakdownTabIndex.value;
                if (tabIndex == 1) {
                  // Nationality tab
                  return _buildNationalityCard(context);
                } else if (tabIndex == 2) {
                  // Gender tab
                  return _buildGenderCard(context);
                } else if (tabIndex == 3) {
                  // Category tab
                  return _buildCategoryCard(context);
                } else if (tabIndex == 4) {
                  // Exam tab - show exam data
                  return _buildExamCard(context);
                } else {
                  // Candidates tab (default) - show nationality as default
                  return _buildNationalityCard(context);
                }
              }),
              SizedBox(height: 16.h),
              _buildStateWiseCard(context),
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

  Widget _buildBreakdownCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NEET UG Exam & Competition Breakdown',
            style: AppTextStyles.welcomeHeading,
          ),
          SizedBox(height: 12.h),
          Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: CompetitionStatisticsController.breakdownTabs
                  .asMap()
                  .entries
                  .map((e) => Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: _TabChip(
                          label: e.value,
                          isSelected: controller.breakdownTabIndex.value == e.key,
                          onTap: () => controller.setBreakdownTab(e.key),
                        ),
                      ))
                  .toList(),
            ),
          )),
          SizedBox(height: 14.h),
          Obx(() {
            controller.breakdownTabIndex.value;
            final label = controller.breakdownTableLabel;
            final rows = controller.breakdownRows;
            return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(AppColors.chipBg),
              columnSpacing: 16.w,
              horizontalMargin: 4.w,
              columns: [
                DataColumn(
                  label: SizedBox(
                    width: 180.w,
                    child: Text(
                      label,
                      style: AppTextStyles.bodyS.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ),
                ...CompetitionStatisticsController.breakdownYears
                    .map((y) => DataColumn(
                          label: SizedBox(
                            width: 72.w,
                            child: Text(
                              y,
                              style: AppTextStyles.bodyS.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        )),
              ],
              rows: rows
                  .map((row) => DataRow(
                        cells: [
                          DataCell(SizedBox(
                            width: 180.w,
                            child: Text(
                              row['label'] as String,
                              style: AppTextStyles.bodyS.copyWith(
                                color: AppColors.textDark,
                                fontSize: 11.sp,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )),
                          ...CompetitionStatisticsController.breakdownYears
                              .map((y) {
                            final v = row[y] as int? ?? 0;
                            final prevYear = _prevYear(y);
                            final prev = prevYear != null ? (row[prevYear] as int? ?? 0) : null;
                            final isUp = prev != null && v > prev;
                            return DataCell(
                              SizedBox(
                                width: 72.w,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        _formatNum(v),
                                        style: AppTextStyles.bodyS.copyWith(
                                          color: AppColors.textDark,
                                          fontSize: 10.sp,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (prev != null) ...[
                                      SizedBox(width: 2.w),
                                      Icon(
                                        isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                                        size: 18.sp,
                                        color: isUp ? AppColors.progressGreen : Colors.red,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ))
                  .toList(),
            ),
          );
          }),
        ],
      ),
    );
  }

  String? _prevYear(String y) {
    final i = CompetitionStatisticsController.breakdownYears.indexOf(y);
    if (i <= 0) return null;
    return CompetitionStatisticsController.breakdownYears[i - 1];
  }

  String _formatNum(int n) {
    // Format with commas for full number display
    final str = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  Widget _buildYearlyInsightsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yearly Competitive Insights',
            style: AppTextStyles.welcomeHeading,
          ),
          SizedBox(height: 6.h),
          Text(
            'Analyze yearly NEET Exam trends to understand shifts in exam participation and success rates.',
            style: AppTextStyles.detailScreenSubtitle.copyWith(color: AppColors.textDark),
          ),
          SizedBox(height: 16.h),
          Obx(() {
            final insights = controller.yearlyInsights;
            if (insights.isEmpty) {
              return SizedBox(
                height: 220.h,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(
                      width: 28.w,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: ['25', '20', '15', '10', '5', '0']
                            .map((t) => Text(
                                  t == '0' ? '0' : '$t L',
                                  style: AppTextStyles.bodyS.copyWith(
                                    fontSize: 9.sp,
                                    color: AppColors.textMuted,
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: controller.yearlyInsights
                            .map((e) => _StackedBar(
                                  year: e['year'] as String,
                                  registered: (e['registered'] as num).toDouble(),
                                  appeared: (e['appeared'] as num).toDouble(),
                                  qualified: (e['qualified'] as num).toDouble(),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ),
              );
            }
            
            // Find max value for scaling
            double maxValue = 0;
            for (final e in insights) {
              final reg = (e['registered'] as num).toDouble();
              if (reg > maxValue) maxValue = reg;
            }
            maxValue = (maxValue * 1.1).ceilToDouble(); // Add 10% padding
            
            return SizedBox(
              height: 240.h,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    width: 35.w,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(6, (i) {
                        final value = (maxValue - (i * (maxValue / 5))).clamp(0, maxValue);
                        return Text(
                          value == 0 ? '0' : '${value.toStringAsFixed(0)}L',
                          style: AppTextStyles.bodyS.copyWith(
                            fontSize: 9.sp,
                            color: AppColors.textMuted,
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: insights.map((e) => SizedBox(
                              width: 50.w,
                              height: 240.h,
                              child: _VerticalBarGroup(
                                year: e['year'] as String,
                                registered: (e['registered'] as num).toDouble(),
                                appeared: (e['appeared'] as num).toDouble(),
                                qualified: (e['qualified'] as num).toDouble(),
                                maxValue: maxValue,
                              ),
                            )).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: AppColors.progressGreen, label: 'Registered'),
              SizedBox(width: 16.w),
              _LegendDot(color: AppColors.primaryBlue, label: 'Appeared'),
              SizedBox(width: 16.w),
              _LegendDot(color: AppColors.accentOrange, label: 'Qualified'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNationalityCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                      'Nationality-Wise Participation Trends – ${controller.selectedYearNationality.value}',
                      style: AppTextStyles.welcomeHeading.copyWith(fontSize: 14.sp),
                    )),
                    SizedBox(height: 4.h),
                    Text(
                      'Registered, Appeared & Qualified by nationality. Select year to compare.',
                      style: AppTextStyles.detailScreenSubtitle.copyWith(color: AppColors.textDark),
                    ),
                  ],
                ),
              ),
              _YearDropdown(
                label: 'Year',
                value: controller.selectedYearNationality.value,
                items: controller.yearsList,
                onChanged: controller.setYearNationality,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Obx(() => _NationalityChart(
                data: controller.getNationalityData(controller.selectedYearNationality.value),
              )),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Category-Wise Exam Performance Breakdown – 2025',
                      style: AppTextStyles.welcomeHeading.copyWith(fontSize: 14.sp),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Know the performance across General, OBC, EWS, SC, and ST categories.',
                      style: AppTextStyles.detailScreenSubtitle.copyWith(color: AppColors.textDark),
                    ),
                  ],
                ),
              ),
              _YearDropdown(
                label: 'Year',
                value: controller.selectedYearCategory.value,
                items: controller.yearsList,
                onChanged: controller.setYearCategory,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Obx(() => _CategoryChart(
                data: controller.getCategoryData(controller.selectedYearCategory.value),
              )),
        ],
      ),
    );
  }

  Widget _buildGenderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gender-Wise Candidate Distribution – 2025',
                      style: AppTextStyles.welcomeHeading.copyWith(fontSize: 14.sp),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Explore gender participation and success rates.',
                      style: AppTextStyles.detailScreenSubtitle.copyWith(color: AppColors.textDark),
                    ),
                  ],
                ),
              ),
              _YearDropdown(
                label: 'Year',
                value: controller.selectedYearGender.value,
                items: controller.yearsList,
                onChanged: controller.setYearGender,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Obx(() => _GenderChart(
                data: controller.getGenderData(controller.selectedYearGender.value),
              )),
        ],
      ),
    );
  }

  Widget _buildExamCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                      'Exam Details – ${controller.selectedYearState.value}',
                      style: AppTextStyles.welcomeHeading.copyWith(fontSize: 14.sp),
                    )),
                    SizedBox(height: 4.h),
                    Text(
                      'Examination infrastructure and logistics details.',
                      style: AppTextStyles.detailScreenSubtitle.copyWith(color: AppColors.textDark),
                    ),
                  ],
                ),
              ),
              _YearDropdown(
                label: 'Year',
                value: controller.selectedYearState.value,
                items: controller.yearsList,
                onChanged: controller.setYearState,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Obx(() => _ExamChart(
                year: controller.selectedYearState.value,
              )),
        ],
      ),
    );
  }

  Widget _buildStateWiseCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                      'State-Wise Competition - ${controller.selectedYearState.value}',
                      style: AppTextStyles.welcomeHeading.copyWith(fontSize: 14.sp),
                    )),
                    SizedBox(height: 4.h),
                    Text(
                      'Explore state wise performance in NEET UG.',
                      style: AppTextStyles.detailScreenSubtitle.copyWith(color: AppColors.textDark),
                    ),
                  ],
                ),
              ),
             Obx(()=>_YearDropdown(
                label: 'Year',
                value: controller.selectedYearState.value,
                items: controller.yearsList,
                onChanged: controller.setYearState,
              )),
            ],
          ),
          SizedBox(height: 16.h),
          Obx(() {
            return _StateWiseMapChart(
              year: controller.selectedYearState.value,
            );
          }),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: AppColors.progressGreen, label: 'Registered'),
              SizedBox(width: 12.w),
              _LegendDot(color: AppColors.primaryBlue, label: 'Appeared'),
              SizedBox(width: 12.w),
              _LegendDot(color: AppColors.accentOrange, label: 'Qualified'),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Chart widgets ---

class _NationalityChart extends StatelessWidget {
  const _NationalityChart({required this.data});

  final List<Map<String, dynamic>> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox(height: 100.h);

    return Column(
      children: data.map((row) {
        final label = row['label'] as String;
        final reg = (row['registered'] as num).toDouble();
        final app = (row['appeared'] as num).toDouble();
        final qual = (row['qualified'] as num).toDouble();
        // Per-row scale so Indian (lakhs) and NRI/OCI/Foreigners (hundreds) all show visible bars
        final maxRow = [reg, app, qual].reduce((a, b) => a > b ? a : b);
        final rowMax = maxRow > 0 ? maxRow : 1.0;

        return Padding(
          padding: EdgeInsets.only(bottom: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyS.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 8.h),
              // Registered bar
              _HorizontalBar(
                label: 'Registered',
                value: reg,
                maxValue: rowMax,
                color: AppColors.progressGreen,
                showValue: true,
              ),
              SizedBox(height: 6.h),
              // Appeared bar
              _HorizontalBar(
                label: 'Appeared',
                value: app,
                maxValue: rowMax,
                color: AppColors.primaryBlue,
                showValue: true,
              ),
              SizedBox(height: 6.h),
              // Qualified bar
              _HorizontalBar(
                label: 'Qualified',
                value: qual,
                maxValue: rowMax,
                color: AppColors.accentOrange,
                showValue: true,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _HorizontalBar extends StatelessWidget {
  const _HorizontalBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
    this.showValue = false,
  });

  final String label;
  final double value;
  final double maxValue;
  final Color color;
  final bool showValue;

  /// Format value (in lakhs): show as "X.X L" for >= 1, else show count for small numbers.
  static String _formatValue(double valueInLakhs) {
    if (valueInLakhs >= 1) return '${valueInLakhs.toStringAsFixed(1)} L';
    if (valueInLakhs >= 0.01) return '${valueInLakhs.toStringAsFixed(2)} L';
    final count = (valueInLakhs * 100000).round();
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final percentage = maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;

    return Row(
      children: [
        SizedBox(
          width: 80.w,
          child: Text(
            label,
            style: AppTextStyles.bodyS.copyWith(
              fontSize: 11.sp,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Flexible(
          child: Stack(
            children: [
              Container(
                height: 20.h,
                decoration: BoxDecoration(
                  color: AppColors.chipBg,
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showValue) ...[
          SizedBox(width: 8.w),
          ConstrainedBox(
            constraints: BoxConstraints(minWidth: 56.w),
            child: Text(
              _formatValue(value),
              style: AppTextStyles.bodyS.copyWith(
                fontSize: 11.sp,
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.right,
              overflow: TextOverflow.visible,
            ),
          ),
        ],
      ],
    );
  }
}

class _CategoryChart extends StatelessWidget {
  const _CategoryChart({required this.data});

  final List<Map<String, dynamic>> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox(height: 180.h);
    
    // Find max value for scaling - use registered, appeared, or qualified whichever is highest
    double maxValue = 0;
    for (final row in data) {
      final reg = (row['registered'] as num).toDouble();
      final app = (row['appeared'] as num).toDouble();
      final qual = (row['qualified'] as num).toDouble();
      final maxRow = [reg, app, qual].reduce((a, b) => a > b ? a : b);
      if (maxRow > maxValue) maxValue = maxRow;
    }
    if (maxValue <= 0) return SizedBox(height: 180.h);
    
    return Column(
      children: data.map((row) {
        final label = row['label'] as String;
        final reg = (row['registered'] as num).toDouble();
        final app = (row['appeared'] as num).toDouble();
        final qual = (row['qualified'] as num).toDouble();
        
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyS.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 8.h),
              // Registered bar
              _HorizontalBar(
                label: 'Registered',
                value: reg,
                maxValue: maxValue,
                color: AppColors.progressGreen,
                showValue: true,
              ),
              SizedBox(height: 6.h),
              // Appeared bar
              _HorizontalBar(
                label: 'Appeared',
                value: app,
                maxValue: maxValue,
                color: AppColors.primaryBlue,
                showValue: true,
              ),
              SizedBox(height: 6.h),
              // Qualified bar
              _HorizontalBar(
                label: 'Qualified',
                value: qual,
                maxValue: maxValue,
                color: AppColors.accentOrange,
                showValue: true,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _GenderChart extends StatelessWidget {
  const _GenderChart({required this.data});

  final List<Map<String, dynamic>> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox(height: 180.h);
    
    // Find max value for scaling - use registered, appeared, or qualified whichever is highest
    double maxValue = 0;
    for (final row in data) {
      final reg = (row['registered'] as num).toDouble();
      final app = (row['appeared'] as num).toDouble();
      final qual = (row['qualified'] as num).toDouble();
      final maxRow = [reg, app, qual].reduce((a, b) => a > b ? a : b);
      if (maxRow > maxValue) maxValue = maxRow;
    }
    if (maxValue <= 0) return SizedBox(height: 180.h);
    
    return Column(
      children: data.map((row) {
        final label = row['label'] as String;
        final reg = (row['registered'] as num).toDouble();
        final app = (row['appeared'] as num).toDouble();
        final qual = (row['qualified'] as num).toDouble();
        
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyS.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                  fontSize: 12.sp,
                ),
              ),
              SizedBox(height: 8.h),
              // Registered bar
              _HorizontalBar(
                label: 'Registered',
                value: reg,
                maxValue: maxValue,
                color: AppColors.progressGreen,
                showValue: true,
              ),
              SizedBox(height: 6.h),
              // Appeared bar
              _HorizontalBar(
                label: 'Appeared',
                value: app,
                maxValue: maxValue,
                color: AppColors.primaryBlue,
                showValue: true,
              ),
              SizedBox(height: 6.h),
              // Qualified bar
              _HorizontalBar(
                label: 'Qualified',
                value: qual,
                maxValue: maxValue,
                color: AppColors.accentOrange,
                showValue: true,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  _PieChartPainter({required this.segments});

  final List<({double value, Color color})> segments;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 4;
    var start = -3.14159 / 2;
    for (final s in segments) {
      final sweep = 2 * 3.14159 * s.value;
      final rect = Rect.fromCircle(center: center, radius: radius);
      final paint = Paint()..color = s.color;
      canvas.drawArc(rect, start, sweep, true, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ExamChart extends StatelessWidget {
  const _ExamChart({required this.year});

  final String year;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CompetitionStatisticsController>();
    final yearData = controller.dataByYear[year];
    
    if (yearData == null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.h),
          child: Text(
            'No exam data available for $year',
            style: AppTextStyles.bodyS.copyWith(color: AppColors.textMuted),
          ),
        ),
      );
    }
    
    final examTypes = controller.examTypes;
    final examData = <Map<String, dynamic>>[];
    
    examTypes.forEach((key, label) {
      final value = yearData[key];
      if (value != null && value != 0) {
        examData.add({
          'label': label,
          'value': value is int ? value : int.tryParse(value.toString()) ?? 0,
        });
      }
    });
    
    if (examData.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.h),
          child: Text(
            'No exam data available',
            style: AppTextStyles.bodyS.copyWith(color: AppColors.textMuted),
          ),
        ),
      );
    }
    
    return Column(
      children: examData.map((row) {
        final label = row['label'] as String;
        final value = row['value'] as int;
        
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyS.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                _formatNumber(value),
                style: AppTextStyles.bodyS.copyWith(
                  fontSize: 12.sp,
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  
  String _formatNumber(int n) {
    final str = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

class _StateWiseMapChart extends StatelessWidget {
  const _StateWiseMapChart({required this.year});

  final String year;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CompetitionStatisticsController>();
    
    // Use Obx to reactively get the state map data and year
    return Obx(() {
      final currentYear = controller.selectedYearState.value;
      final stateMapData = controller.apiData['state_map_data'];
      
      if (stateMapData == null || stateMapData[currentYear] == null) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(24.h),
            child: Text(
              'State-wise data not available for $currentYear',
              style: AppTextStyles.bodyS.copyWith(color: AppColors.textMuted),
            ),
          ),
        );
      }
      
      final yearData = stateMapData[currentYear] as Map<String, dynamic>?;
    final registeredData = yearData?['registered'] as Map<String, dynamic>? ?? {};
    final appearedData = yearData?['appeared'] as Map<String, dynamic>? ?? {};
    final qualifiedData = yearData?['qualified'] as Map<String, dynamic>? ?? {};
    
    // Get state codes and values
    final stateCodes = <String>[];
    final stateValues = <String, Map<String, int>>{};
    
    registeredData.forEach((code, value) {
      if (!stateCodes.contains(code)) stateCodes.add(code);
      if (!stateValues.containsKey(code)) {
        stateValues[code] = {'registered': 0, 'appeared': 0, 'qualified': 0};
      }
      stateValues[code]!['registered'] = value is int ? value : int.tryParse(value.toString()) ?? 0;
    });
    
    appearedData.forEach((code, value) {
      if (!stateCodes.contains(code)) stateCodes.add(code);
      if (!stateValues.containsKey(code)) {
        stateValues[code] = {'registered': 0, 'appeared': 0, 'qualified': 0};
      }
      stateValues[code]!['appeared'] = value is int ? value : int.tryParse(value.toString()) ?? 0;
    });
    
    qualifiedData.forEach((code, value) {
      if (!stateCodes.contains(code)) stateCodes.add(code);
      if (!stateValues.containsKey(code)) {
        stateValues[code] = {'registered': 0, 'appeared': 0, 'qualified': 0};
      }
      stateValues[code]!['qualified'] = value is int ? value : int.tryParse(value.toString()) ?? 0;
    });
    
    // Sort by registered count (descending)
    stateCodes.sort((a, b) {
      final aVal = stateValues[a]?['registered'] ?? 0;
      final bVal = stateValues[b]?['registered'] ?? 0;
      return bVal.compareTo(aVal);
    });
    
    // Show top states in a list format (since we don't have map visualization library)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top States by Registered Candidates',
          style: AppTextStyles.bodyS.copyWith(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        SizedBox(height: 12.h),
        ...stateCodes.take(10).map((code) {
          final values = stateValues[code]!;
          final reg = values['registered'] ?? 0;
          final app = values['appeared'] ?? 0;
          final qual = values['qualified'] ?? 0;
          
          // Convert state code to readable name
          final stateName = _getStateName(code);
          
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(
              children: [
                SizedBox(
                  width: 100.w,
                  child: Text(
                    stateName,
                    style: AppTextStyles.bodyS.copyWith(
                      fontSize: 11.sp,
                      color: AppColors.textDark,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reg: ${_formatNumber(reg)} | App: ${_formatNumber(app)} | Qual: ${_formatNumber(qual)}',
                        style: AppTextStyles.bodyS.copyWith(
                          fontSize: 10.sp,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
    });
  }
  
  String _getStateName(String code) {
    // Convert state code to readable name
    final stateMap = {
      'in-up': 'Uttar Pradesh',
      'in-mh': 'Maharashtra',
      'in-rj': 'Rajasthan',
      'in-ka': 'Karnataka',
      'in-tn': 'Tamil Nadu',
      'in-gj': 'Gujarat',
      'in-wb': 'West Bengal',
      'in-mp': 'Madhya Pradesh',
      'in-br': 'Bihar',
      'in-ap': 'Andhra Pradesh',
      'in-tg': 'Telangana',
      'in-kl': 'Kerala',
      'in-or': 'Odisha',
      'in-pb': 'Punjab',
      'in-hr': 'Haryana',
      'in-jh': 'Jharkhand',
      'in-ch': 'Chandigarh',
      'in-dl': 'Delhi',
      'in-hp': 'Himachal Pradesh',
      'in-ut': 'Uttarakhand',
      'in-jk': 'Jammu & Kashmir',
      'in-as': 'Assam',
      'in-an': 'Andaman & Nicobar',
      'in-ar': 'Arunachal Pradesh',
      'in-mn': 'Manipur',
      'in-ml': 'Meghalaya',
      'in-mz': 'Mizoram',
      'in-nl': 'Nagaland',
      'in-sk': 'Sikkim',
      'in-tr': 'Tripura',
      'in-ga': 'Goa',
      'in-py': 'Puducherry',
      'in-ladakh': 'Ladakh',
      'in-dnhdd': 'Dadra & Nagar Haveli',
      'in-ld': 'Lakshadweep',
      'in-cg': 'Chhattisgarh',
    };
    return stateMap[code.toLowerCase()] ?? code.toUpperCase();
  }
  
  String _formatNumber(int n) {
    final str = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primaryBlue : Colors.transparent,
              width: 2.5,
            ),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.bodyS.copyWith(
            color: isSelected ? AppColors.primaryBlue : AppColors.textMuted,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _VerticalBarGroup extends StatelessWidget {
  const _VerticalBarGroup({
    required this.year,
    required this.registered,
    required this.appeared,
    required this.qualified,
    required this.maxValue,
  });

  final String year;
  final double registered;
  final double appeared;
  final double qualified;
  final double maxValue;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Value labels on top
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${registered.toStringAsFixed(1)}L',
              style: AppTextStyles.bodyS.copyWith(
                fontSize: 7.sp,
                color: AppColors.progressGreen,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h),
            Text(
              '${appeared.toStringAsFixed(1)}L',
              style: AppTextStyles.bodyS.copyWith(
                fontSize: 7.sp,
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h),
            Text(
              '${qualified.toStringAsFixed(1)}L',
              style: AppTextStyles.bodyS.copyWith(
                fontSize: 7.sp,
                color: AppColors.accentOrange,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final h = constraints.maxHeight;
              final scale = maxValue > 0 ? h / maxValue : 0.0;
              final barWidth = 13.w;
              final spacing = 3.w;

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: barWidth,
                    height: (registered * scale).clamp(4.0, h),
                    decoration: BoxDecoration(
                      color: AppColors.progressGreen,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
                    ),
                  ),
                  SizedBox(width: spacing),
                  Container(
                    width: barWidth,
                    height: (appeared * scale).clamp(4.0, h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
                    ),
                  ),
                  SizedBox(width: spacing),
                  Container(
                    width: barWidth,
                    height: (qualified * scale).clamp(4.0, h),
                    decoration: BoxDecoration(
                      color: AppColors.accentOrange,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          year,
          style: AppTextStyles.bodyS.copyWith(
            fontSize: 9.sp,
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _StackedBar extends StatelessWidget {
  const _StackedBar({
    required this.year,
    required this.registered,
    required this.appeared,
    required this.qualified,
  });

  final String year;
  final double registered;
  final double appeared;
  final double qualified;

  static const double _maxL = 25;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            year,
            style: AppTextStyles.bodyS.copyWith(
              fontSize: 10.sp,
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final h = constraints.maxHeight;
                final scale = h / _maxL;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: (qualified * scale).clamp(4.0, h),
                      decoration: BoxDecoration(
                        color: AppColors.accentOrange,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
                      ),
                    ),
                    Container(
                      height: ((appeared - qualified) * scale).clamp(2.0, h),
                      decoration: const BoxDecoration(color: AppColors.primaryBlue),
                    ),
                    Container(
                      height: ((registered - appeared) * scale).clamp(2.0, h),
                      decoration: BoxDecoration(
                        color: AppColors.progressGreen,
                        borderRadius: BorderRadius.vertical(bottom: Radius.circular(4.r)),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4.w),
        Text(label, style: AppTextStyles.bodyS.copyWith(fontSize: 10.sp, color: AppColors.textDark)),
      ],
    );
  }
}

class _LineChartWidget extends StatelessWidget {
  const _LineChartWidget({
    required this.years,
    required this.registered,
    required this.appeared,
    required this.qualified,
  });

  final List<String> years;
  final List<int> registered;
  final List<int> appeared;
  final List<int> qualified;

  @override
  Widget build(BuildContext context) {
    if (years.isEmpty || registered.isEmpty || appeared.isEmpty || qualified.isEmpty) {
      return SizedBox(height: 220.h);
    }

    // Find max value for scaling
    final maxValue = [
      ...registered,
      ...appeared,
      ...qualified,
    ].reduce((a, b) => a > b ? a : b);

    // Convert to lakhs for display
    final maxLakhs = (maxValue / 100000).ceil().toDouble();
    final stepLakhs = maxLakhs > 0 ? (maxLakhs / 5).ceil().toDouble() : 5.0;

    return SizedBox(
      height: 260.h,
      child: Column(
        children: [
          // Chart area with Y-axis
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Y-axis labels
                SizedBox(
                  width: 40.w,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(6, (i) {
                      final value = (maxLakhs - (i * stepLakhs)).clamp(0, maxLakhs);
                      return Text(
                        value == 0 ? '0' : '${value.toInt()}L',
                        style: AppTextStyles.bodyS.copyWith(
                          fontSize: 10.sp,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(width: 8.w),
                // Chart area
                Expanded(
                  child: SizedBox(
                    height: 220.h,
                    child: CustomPaint(
                      painter: _LineChartPainter(
                        years: years,
                        registered: registered,
                        appeared: appeared,
                        qualified: qualified,
                        maxValue: maxValue.toDouble(),
                      ),
                      child: Container(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          // X-axis labels
          Padding(
            padding: EdgeInsets.only(left: 48.w),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final chartWidth = constraints.maxWidth;
                final pointSpacing = years.length > 1 ? chartWidth / (years.length - 1) : 0;
                return Stack(
                  children: years.asMap().entries.map((entry) {
                    final index = entry.key;
                    final year = entry.value;
                    return Positioned(
                      left: pointSpacing * index - 12.w,
                      child: Text(
                        year.length > 4 ? year.substring(2) : year,
                        style: AppTextStyles.bodyS.copyWith(
                          fontSize: 10.sp,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.years,
    required this.registered,
    required this.appeared,
    required this.qualified,
    required this.maxValue,
  });

  final List<String> years;
  final List<int> registered;
  final List<int> appeared;
  final List<int> qualified;
  final double maxValue;

  @override
  void paint(Canvas canvas, Size size) {
    if (years.isEmpty || maxValue <= 0) return;

    final padding = 8.0;
    final chartWidth = size.width - (padding * 2);
    final chartHeight = size.height - (padding * 2);
    final startX = padding;
    final startY = padding;
    final endX = size.width - padding;
    final endY = size.height - padding;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 0.5;
    
    for (int i = 0; i <= 5; i++) {
      final y = startY + (chartHeight / 5) * i;
      canvas.drawLine(
        Offset(startX, y),
        Offset(endX, y),
        gridPaint,
      );
    }

    // Convert data points to coordinates
    final pointSpacing = years.length > 1 ? chartWidth / (years.length - 1) : 0;
    
    List<Offset> registeredPoints = [];
    List<Offset> appearedPoints = [];
    List<Offset> qualifiedPoints = [];

    for (int i = 0; i < years.length; i++) {
      final x = startX + (pointSpacing * i);
      
      if (i < registered.length && registered[i] > 0) {
        final y = endY - ((registered[i] / maxValue) * chartHeight);
        registeredPoints.add(Offset(x, y));
      }
      
      if (i < appeared.length && appeared[i] > 0) {
        final y = endY - ((appeared[i] / maxValue) * chartHeight);
        appearedPoints.add(Offset(x, y));
      }
      
      if (i < qualified.length && qualified[i] > 0) {
        final y = endY - ((qualified[i] / maxValue) * chartHeight);
        qualifiedPoints.add(Offset(x, y));
      }
    }

    // Draw lines
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    // Registered line (green)
    if (registeredPoints.length > 1) {
      linePaint.color = AppColors.progressGreen;
      _drawLine(canvas, registeredPoints, linePaint);
      _drawPoints(canvas, registeredPoints, AppColors.progressGreen);
    }

    // Appeared line (blue)
    if (appearedPoints.length > 1) {
      linePaint.color = AppColors.primaryBlue;
      _drawLine(canvas, appearedPoints, linePaint);
      _drawPoints(canvas, appearedPoints, AppColors.primaryBlue);
    }

    // Qualified line (orange)
    if (qualifiedPoints.length > 1) {
      linePaint.color = AppColors.accentOrange;
      _drawLine(canvas, qualifiedPoints, linePaint);
      _drawPoints(canvas, qualifiedPoints, AppColors.accentOrange);
    }
  }

  void _drawLine(Canvas canvas, List<Offset> points, Paint paint) {
    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);
    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  void _drawPoints(Canvas canvas, List<Offset> points, Color color) {
    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    for (final point in points) {
      canvas.drawCircle(point, 4.0, pointPaint);
      // Draw white border
      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(point, 4.0, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _YearDropdown extends StatelessWidget {
  const _YearDropdown({
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
    return SizedBox(
      width: 90.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label:',
            style: AppTextStyles.detailScreenSubtitle.copyWith(
              fontSize: 11.sp,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                isDense: true,
                icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20.sp, color: AppColors.textMuted),
                style: AppTextStyles.bodyS.copyWith(color: AppColors.textDark, fontSize: 12.sp),
                items: items.map((e) => DropdownMenuItem<String>(value: e, child: Text(e))).toList(),
                onChanged: (v) => v != null ? onChanged(v) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
