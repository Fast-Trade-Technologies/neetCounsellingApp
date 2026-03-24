import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/map_choropleth_util.dart';
import '../../../core/widgets/detail_app_bar.dart';
import '../../../core/widgets/detail_dropdown.dart';
import '../../../core/widgets/filter_bottom_sheet.dart';
import 'college_seats_controller.dart';

class CollegeSeatsView extends GetView<CollegeSeatsController> {
  const CollegeSeatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DetailAppBar(
        title: 'Analysis College & Seats',
        subtitle: 'College & Seats',
        onBack: () => Get.back(),
        hideFilter: true,
        // onFilter: () => _openFilterSheet(context),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refresh(),
        color: AppColors.primaryBlue,
        child: Obx(() {
          if (controller.mapDataLoading.value) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.5,
                child: Center(child: const CircularProgressIndicator()),
              ),
            );
          }
          if (controller.mapDataError.value.isNotEmpty) {
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 48.h),
                child: Center(
                  child: Text(
                    controller.mapDataError.value,
                    style: AppTextStyles.bodyS.copyWith(color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              children: [
                _buildHeader(),
                SizedBox(height: 14.h),
                _buildLayout(context),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFFE6EDF5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.textDark.withValues(alpha: 0.06),
                blurRadius: 30,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 14.h),
              _buildCounsellingTypeDropdown(),
              SizedBox(height: 14.h),
              _buildStateDropdown(),
              SizedBox(height: 14.h),
              Container(
                height: 1,
                color: const Color(0xFFE8EEF6),
              ),
              SizedBox(height: 14.h),
              // _buildStateChip(),
              SizedBox(height: 16.h),
              // Interactive India map showing state-wise colleges/seats.
              _buildMapPanel(),
              SizedBox(height: 16.h),
              _buildSummaryCard(),
              SizedBox(height: 14.h),
              _buildCollegeListSection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCounsellingTypeDropdown() {
    return Obx(() {
      if (controller.filtersLoading.value) {
        return Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            height: 32.h,
            width: 120.w,
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
        );
      }
      final types = controller.counsellingTypes;
      if (types.isEmpty) {
        return Text(
          'Counselling Type',
          style: AppTextStyles.bodyM.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF142A52),
          ),
        );
      }

      String value = controller.selectedCounsellingTypeName.value;
      if (value.isEmpty) {
        value = types.first.name;
        controller.setCounsellingType(value);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Counselling Type',
            style: AppTextStyles.detailScreenSubtitle.copyWith(
              fontSize: 11.sp,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: const Color(0xFFD8E2EE)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isDense: true,
                value: value,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
                style: AppTextStyles.bodyM.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF142A52),
                ),
                items: types
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e.name,
                        child: Text(e.name),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  if (v == null) return;
                  controller.setCounsellingType(v);
                },
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildHeader() {
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
              'College & Seats',
              style: AppTextStyles.welcomeHeading.copyWith(fontSize: 14.sp),
            ),
            SizedBox(height: 4.h),
            Text(
              'Navigate across different medical college seat distributions',
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

  Widget _buildStateDropdown() {
    return Obx(() {
      final states = controller.stateNames;

      // If no data yet, show simple label (non-interactive)
      if (states.isEmpty) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: const Color(0xFFD8E2EE)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'State',
                style: AppTextStyles.bodyM.copyWith(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF142A52),
                ),
              ),
              SizedBox(width: 8.w),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
            ],
          ),
        );
      }

      String? value = controller.selectedStateName;
      if (value == null || value.isEmpty || !states.contains(value)) {
        value = states.first;
        controller.setSelectedState(value);
      }

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: const Color(0xFFD8E2EE)),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            isDense: true,
            value: value,
            hint: Text(
              'State',
              style: AppTextStyles.bodyM.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF142A52),
              ),
            ),
            icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
            style: AppTextStyles.bodyM.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF142A52),
            ),
            items: states
                .map(
                  (e) => DropdownMenuItem<String>(
                    value: e,
                    child: Text(e),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              controller.setSelectedState(v);
            },
          ),
        ),
      );
    });
  }

  Widget _buildStateChip() {
    return Obx(() {
      final stateName = controller.selectedStateName;
      final seats = controller.selectedStateSeats;
      if (stateName.isEmpty) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.chipBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.textDark.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.chipBg,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 16.sp,
                    color: AppColors.primaryBlue,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    stateName,
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Align(
                alignment: Alignment.topRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Total Seats',
                      style: AppTextStyles.bodyS.copyWith(
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Text(
                        seats.toString(),
                        style: AppTextStyles.bodyM.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMapPanel() {
    return Container(
      height: 250.h,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 18.h),
                child: Obx(() {
                  final selectedCode = controller.selectedStateCode;
                  return FutureBuilder<String>(
                    future: rootBundle.loadString('assets/maps/india_states.svg'),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const SizedBox.shrink();
                      }
                      String svgData = snapshot.data!;

                      // Replace SVG placeholders like {{INUP}} with actual seat counts
                      // coming from the map_data API (only states present in API).
                      final stateSeatsMap = controller.stateSeatsBySvgId;
                      stateSeatsMap.forEach((svgId, count) {
                        svgData = svgData.replaceAll('{{$svgId}}', count.toString());
                      });

                      // Remove any unreplaced placeholders (states not present in API)
                      // so that they are not shown on the map.
                      svgData = svgData.replaceAll(RegExp(r'\{\{[A-Z0-9]+\}\}'), '');

                      svgData = applyChoroplethFill(
                        svgData,
                        stateSeatsMap,
                      );

                      // Highlight only the selected state's path.
                      if (selectedCode != null && selectedCode.isNotEmpty) {
                        final codeUpper = selectedCode.toUpperCase();
                        final stateCode = codeUpper.replaceAll('-', '');
                        // Ensure we match regardless of case in the SVG id attribute.
                        svgData = svgData.replaceFirstMapped(
                          RegExp('id=["\']$stateCode["\']', caseSensitive: false),
                          (match) => '${match.group(0)} stroke-width="1"',
                        );
                      }

                      return InteractiveViewer(
                        transformationController: controller.mapTransformController,
                        minScale: 0.8,
                        maxScale: 4.0,
                        panEnabled: true,
                        child: SvgPicture.string(
                          svgData,
                          fit: BoxFit.contain,
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ),
          Positioned(
            left: 10.w,
            top: 14.h,
            child: Column(
              children: [
                _buildMapAction(Icons.home_outlined, onTap: controller.resetMapView),
                SizedBox(height: 10.h),
                _buildMapAction(Icons.add, onTap: controller.zoomIn),
                SizedBox(height: 10.h),
                _buildMapAction(Icons.remove, onTap: controller.zoomOut),
              ],
            ),
          ),
          // State-wise seats overlay in the map, driven by the top dropdown.
          Positioned(
            top: 0.h,
            right: 0.w,
            child: Obx(() {
              final name = controller.selectedStateName;
              final seats = controller.selectedStateSeats;
              if (name.isEmpty || seats <= 0) return const SizedBox.shrink();

              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFFD1DEEE)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textDark.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: AppTextStyles.bodyM.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0B2350),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total Seats:',
                          style: AppTextStyles.bodyS.copyWith(
                            color: AppColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          seats.toString(),
                          style: AppTextStyles.bodyM.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMapAction(IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFDCE5EF)),
          boxShadow: [
            BoxShadow(
              color: AppColors.textDark.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF243A60)),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primaryBlue),
      ),
      child: Column(
        children: [
          Obx(
            () => Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: const Color(0xFFE6EBF2),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _SegmentTab(
                      label: 'Seat Wise',
                      isActive: controller.selectedTab.value == 0,
                      onTap: () => controller.setTab(0),
                    ),
                  ),
                  Expanded(
                    child: _SegmentTab(
                      label: 'College Wise',
                      isActive: controller.selectedTab.value == 1,
                      onTap: () => controller.setTab(1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Obx(() {
            final seats = controller.totalSeats.value;
            final colleges = controller.totalColleges.value;
            return Row(
              children: [
                Expanded(
                  child: _buildMetricTile(value:controller.selectedTab.value == 1 ? colleges.toString() : seats.toString(), label:controller.selectedTab.value == 1? 'Colleges' : 'Seats'),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: _buildMetricTile(value:controller.selectedTab.value == 1 ? seats.toString() : colleges.toString(), label:controller.selectedTab.value == 1? 'Seats' : 'Colleges'),
                ),
              ],
            );
          }),
          SizedBox(height: 12.h),
          Obx(() {
            final institutes = controller.instituteData;
            if (institutes.isEmpty) return const SizedBox.shrink();
            final totalSeats = controller.totalSeats.value == 0
                ? institutes.fold<int>(0, (sum, e) => sum + e.seats)
                : controller.totalSeats.value;

            double ratioFor(InstituteSummary s) =>
                totalSeats == 0 ? 0 : s.seats / totalSeats;

            final first = institutes.isNotEmpty ? institutes.first : null;
            final second = institutes.length > 1 ? institutes[1] : null;
            debugPrint("institutes --- ${institutes.first.instituteName}");
            debugPrint("institutes --- ${institutes.first.colleges}");
            debugPrint("institutes --- ${institutes.first.seats}");
            debugPrint("institutes --- ${institutes[1].instituteName}");
            debugPrint("institutes --- ${institutes[1].colleges}");
            debugPrint("institutes --- ${institutes[1].seats}");
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (first != null) ...[
                  _buildStatLine(
                    title: '${first.instituteName} (${first.colleges})',
                    value: first.seats.toString(),
                  ),
                  SizedBox(height: 6.h),
                  _buildProgress(ratioFor(first).clamp(0.0, 1.0), const Color(0xFF0284C7)),
                  SizedBox(height: 14.h),
                ],
                if (second != null) ...[
                  _buildStatLine(
                    title: '${second.instituteName} (${second.colleges})',
                    value: second.seats.toString(),
                  ),
                  SizedBox(height: 6.h),
                  _buildProgress(ratioFor(second).clamp(0.0, 1.0), const Color(0xFF5DAD33)),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMetricTile({required String value, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDF4),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTextStyles.titleM.copyWith(
              fontSize: 28.sp,
              color: const Color(0xFF0D2345),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: AppTextStyles.bodyM.copyWith(
              color: const Color(0xFF4A5D73),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatLine({required String title, required String value}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.bodyM.copyWith(
              color: const Color(0xFF50627A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyM.copyWith(
            color: const Color(0xFF2C4567),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildProgress(double value, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6.r),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 8.h,
        backgroundColor: const Color(0xFFDCE5EE),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  Widget _buildCollegeCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F8),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: const Color(0xFFE8EDF4),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9.r),
              ),
              child: const Icon(Icons.account_balance_outlined, size: 20),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'ACSR GOVERNMENT MEDICAL\nCOLLEGE NELLORE',
                          style: AppTextStyles.detailScreenTitle.copyWith(
                            color: const Color(0xFF0B2350),
                            fontWeight: FontWeight.w800,
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF3FA),
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(color: const Color(0xFFD1DEEE)),
                        ),
                        child: Text(
                          'Government',
                          style: AppTextStyles.bodyS.copyWith(
                            color: const Color(0xFF193A64),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Seats : 149',
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF3C526D),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F8FC),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFD5DFEC)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.language_rounded, size: 14, color: Color(0xFF5C6D81)),
                        SizedBox(width: 6.w),
                        Text(
                          'Website',
                          style: AppTextStyles.bodyS.copyWith(
                            color: const Color(0xFF465A74),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollegeListSection() {
    return Obx(() {
      final list = controller.filteredColleges;
      if (list.isEmpty) return const SizedBox.shrink();

      final total = controller.collegeList.length;
      final hasSearch = controller.collegeSearchQuery.value.trim().isNotEmpty;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Colleges',
            style: AppTextStyles.welcomeHeading.copyWith(fontSize: 13.sp),
          ),
          SizedBox(height: 10.h),
          TextField(
            onChanged: controller.setCollegeSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search colleges by name',
              hintStyle: AppTextStyles.fieldHint,
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(Icons.search, size: 18),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              isDense: true,
            ),
            style: AppTextStyles.bodyS.copyWith(color: AppColors.textDark),
          ),
          SizedBox(height: 10.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            separatorBuilder: (_, __) => SizedBox(height: 8.h),
            itemBuilder: (context, index) {
              final college = list[index];
              return _CollegeListTile(college: college);
            },
          ),
          if (!hasSearch && list.length < total) ...[
            SizedBox(height: 10.h),
            Center(
              child: TextButton(
                onPressed: controller.loadMoreColleges,
                child: Text(
                  'Load more colleges',
                  style: AppTextStyles.bodyM.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      );
    });
  }

  void _openFilterSheet(BuildContext context) {
    showFilterSheet(
      context: context,
      onSubmit: () {},
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
}

class _SegmentTab extends StatelessWidget {
  const _SegmentTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFCFE1F3) : null,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyM.copyWith(
            color: const Color(0xFF183760),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _CollegeListTile extends StatelessWidget {
  const _CollegeListTile({required this.college});

  final CollegeInfo college;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F8),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: const Icon(Icons.account_balance_outlined, size: 20),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        college.name,
                        style: AppTextStyles.detailScreenTitle.copyWith(
                          color: const Color(0xFF0B2350),
                          fontWeight: FontWeight.w700,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    if (college.type.isNotEmpty)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF3FA),
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(color: const Color(0xFFD1DEEE)),
                        ),
                        child: Text(
                          college.type,
                          style: AppTextStyles.bodyS.copyWith(
                            color: const Color(0xFF193A64),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  'Seats : ${college.totalSeats}',
                  style: AppTextStyles.bodyM.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF3C526D),
                  ),
                ),
                if (college.website.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F8FC),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFD5DFEC)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.language_rounded, size: 14, color: Color(0xFF5C6D81)),
                        SizedBox(width: 6.w),
                        Text(
                          college.website,
                          style: AppTextStyles.bodyS.copyWith(
                            color: const Color(0xFF465A74),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
