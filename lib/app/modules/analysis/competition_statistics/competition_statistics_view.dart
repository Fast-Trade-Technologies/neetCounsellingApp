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
              _buildNationalityCard(context),
              SizedBox(height: 16.h),
              _buildCategoryCard(context),
              SizedBox(height: 16.h),
              _buildGenderCard(context),
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
          SingleChildScrollView(
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
                      ' ',
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
              rows: CompetitionStatisticsController.breakdownRows
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
          ),
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
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(0)}K';
    return '$n';
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
          SizedBox(
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
                    children: CompetitionStatisticsController.yearlyInsights
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
          ),
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
                    Text(
                      'Nationality-Wise Participation Trends – 2025',
                      style: AppTextStyles.welcomeHeading.copyWith(fontSize: 14.sp),
                    ),
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
          _NationalityChart(data: CompetitionStatisticsController.nationalityData),
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
          _CategoryChart(data: CompetitionStatisticsController.categoryData),
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
          _GenderChart(data: CompetitionStatisticsController.genderData),
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
          Text(
            'State-Wise Competition – 2025',
            style: AppTextStyles.welcomeHeading.copyWith(fontSize: 14.sp),
          ),
          SizedBox(height: 4.h),
          Text(
            'Explore state wise performance in NEET UG.',
            style: AppTextStyles.detailScreenSubtitle.copyWith(color: AppColors.textDark),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _YearDropdown(
                label: 'State',
                value: controller.selectedState.value,
                items: controller.statesList,
                onChanged: controller.setState,
              ),
              SizedBox(width: 12.w),
              _YearDropdown(
                label: 'Year',
                value: controller.selectedYearState.value,
                items: controller.yearsList,
                onChanged: controller.setYearState,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _StateWiseChart(data: CompetitionStatisticsController.stateWiseData),
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
    return Column(
      children: data.where((row) => (row['registered'] as num).toDouble() > 0).map((row) {
        final label = row['label'] as String;
        final reg = (row['registered'] as num).toDouble();
        final app = (row['appeared'] as num).toDouble();
        final qual = (row['qualified'] as num).toDouble();
        final fAbsent = (reg - app) / reg;
        final fAppearedNotQual = (app - qual) / reg;
        final fQual = qual / reg;
        return Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.bodyS.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                  fontSize: 11.sp,
                ),
              ),
              SizedBox(height: 4.h),
              SizedBox(
                height: 24.h,
                child: Row(
                  children: [
                    Expanded(flex: (fAbsent * 1000).round().clamp(1, 999), child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.progressGreen,
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(4.r)),
                      ),
                    )),
                    Expanded(flex: (fAppearedNotQual * 1000).round().clamp(1, 999), child: Container(color: AppColors.primaryBlue)),
                    Expanded(flex: (fQual * 1000).round().clamp(1, 999), child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.accentOrange,
                        borderRadius: BorderRadius.horizontal(right: Radius.circular(4.r)),
                      ),
                    )),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Reg: ${reg.toStringAsFixed(1)}L | App: ${app.toStringAsFixed(1)}L | Qual: ${qual.toStringAsFixed(1)}L',
                style: AppTextStyles.bodyS.copyWith(fontSize: 9.sp, color: AppColors.textMuted),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _CategoryChart extends StatelessWidget {
  const _CategoryChart({required this.data});

  final List<Map<String, dynamic>> data;

  @override
  Widget build(BuildContext context) {
    final maxReg = data.fold<double>(0, (m, e) => (e['registered'] as num).toDouble() > m ? (e['registered'] as num).toDouble() : m);
    return SizedBox(
      height: 180.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: data.map((row) {
          final label = row['label'] as String;
          final reg = (row['registered'] as num).toDouble();
          final qual = (row['qualified'] as num).toDouble();
          final regH = maxReg > 0 ? (reg / maxReg) * 120.h : 0.0;
          final qualH = maxReg > 0 ? (qual / maxReg) * 120.h : 0.0;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.bodyS.copyWith(fontSize: 9.sp, color: AppColors.textDark, fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: qualH.clamp(4.0, double.infinity),
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
                        ),
                      ),
                      Container(
                        height: (regH - qualH).clamp(2.0, double.infinity),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue,
                          borderRadius: BorderRadius.vertical(bottom: Radius.circular(4.r)),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text('${reg.toStringAsFixed(1)}L', style: AppTextStyles.bodyS.copyWith(fontSize: 8.sp, color: AppColors.textMuted)),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _GenderChart extends StatelessWidget {
  const _GenderChart({required this.data});

  final List<Map<String, dynamic>> data;

  @override
  Widget build(BuildContext context) {
    final total = data.fold<double>(0, (s, e) => s + (e['value'] as num).toDouble());
    if (total <= 0) return SizedBox(height: 140.h);
    return SizedBox(
      height: 160.h,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: CustomPaint(
              size: Size(140.w, 140.w),
              painter: _PieChartPainter(
                segments: data
                    .map((e) => (
                          value: (e['value'] as num).toDouble() / total,
                          color: e['label'] == 'Female' ? AppColors.primaryBlue : AppColors.accentOrange,
                        ))
                    .toList(),
              ),
            ),
          ),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: data.map((e) {
                final label = e['label'] as String;
                final val = (e['value'] as num).toDouble();
                final color = label == 'Female' ? AppColors.primaryBlue : AppColors.accentOrange;
                return Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: Row(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '$label: ${val.toStringAsFixed(1)}L',
                        style: AppTextStyles.bodyS.copyWith(fontSize: 11.sp, color: AppColors.textDark),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
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

class _StateWiseChart extends StatelessWidget {
  const _StateWiseChart({required this.data});

  final List<Map<String, dynamic>> data;

  @override
  Widget build(BuildContext context) {
    final maxVal = data.fold<double>(0, (m, e) {
      final v = (e['registered'] as num).toDouble();
      return v > m ? v : m;
    });
    return Column(
      children: data.where((row) => (row['registered'] as num).toDouble() > 0).map((row) {
        final label = row['label'] as String;
        final reg = (row['registered'] as num).toDouble();
        final app = (row['appeared'] as num).toDouble();
        final qual = (row['qualified'] as num).toDouble();
        final fAbsent = (reg - app) / reg;
        final fAppNotQual = (app - qual) / reg;
        final fQual = qual / reg;
        final barFlex = maxVal > 0 ? (reg / maxVal * 500).round().clamp(1, 500) : 100;
        return Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: Row(
            children: [
              SizedBox(
                width: 72.w,
                child: Text(
                  label,
                  style: AppTextStyles.bodyS.copyWith(fontSize: 10.sp, color: AppColors.textDark, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: barFlex,
                      child: SizedBox(
                        height: 28.h,
                        child: Row(
                          children: [
                            Expanded(flex: (fAbsent * 1000).round().clamp(1, 999), child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.progressGreen,
                                borderRadius: BorderRadius.horizontal(left: Radius.circular(4.r)),
                              ),
                            )),
                            Expanded(flex: (fAppNotQual * 1000).round().clamp(1, 999), child: Container(color: AppColors.primaryBlue)),
                            Expanded(flex: (fQual * 1000).round().clamp(1, 999), child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.accentOrange,
                                borderRadius: BorderRadius.horizontal(right: Radius.circular(4.r)),
                              ),
                            )),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${reg.toStringAsFixed(1)}L',
                      style: AppTextStyles.bodyS.copyWith(fontSize: 10.sp, color: AppColors.textDark),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primaryBlue : AppColors.chipBg,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          child: Text(
            label,
            style: AppTextStyles.bodyS.copyWith(
              color: isSelected ? Colors.white : AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
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
