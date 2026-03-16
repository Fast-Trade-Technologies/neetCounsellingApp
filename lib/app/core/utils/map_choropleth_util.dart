import 'package:flutter/material.dart';

// Blue palette (e.g. for college seats map)
const _defaultNoDataFillBlue = '#b3d1ff';
const _lightBlue = Color.fromARGB(255, 227, 242, 253);
const _darkBlue = Color.fromARGB(255, 68, 143, 230);

// Green palette (e.g. for competition statistics map like reference image)
const _defaultNoDataFillGreen = '#A5D6A7';
const _lightGreen = Color(0xFFC8E6C9);
const _darkGreen = Color(0xFF2E7D32);

const _minRatio = 0.25;
const _rangeRatio = 0.75;

/// Applies a choropleth to India map SVG.
/// - If [isCollegeSeatsPage] is true → blue shades.
/// - Otherwise → green shades (like the provided reference image).
/// Every state path gets a fill: with data → choropleth; without data → default fill.
String applyChoroplethFill(
  String svgData,
  Map<String, int> valuesBySvgId, {
  bool isCollegeSeatsPage = false,
}) {
  // Pick palette based on page
  final defaultNoDataFill =
      isCollegeSeatsPage ? _defaultNoDataFillBlue : _defaultNoDataFillGreen;
  final lightColor = isCollegeSeatsPage ? _lightBlue : _lightGreen;
  final darkColor = isCollegeSeatsPage ? _darkBlue : _darkGreen;

  // Replace root fill (background land color) with palette's default,
  // handling both possible original colors used in different SVGs.
  svgData = svgData
      .replaceFirst(RegExp(r'fill="#6f9c76"'), 'fill="$defaultNoDataFill"')
      .replaceFirst(RegExp(r'fill="#80ff80"'), 'fill="$defaultNoDataFill"');
  // Collect all state path ids (e.g. INUP, INMH, INBR...)
  final pathIdRegex = RegExp(r'id="(IN[A-Z0-9]+)"');
  final allIds = <String>{};
  for (final m in pathIdRegex.allMatches(svgData)) {
    allIds.add(m.group(1)!);
  }

  // Compute min/max for scaling
  double minVal = 0, maxVal = 0;
  if (valuesBySvgId.isNotEmpty) {
    final values = valuesBySvgId.values.toList();
    minVal = values.reduce((a, b) => a < b ? a : b).toDouble();
    maxVal = values.reduce((a, b) => a > b ? a : b).toDouble();
  }
  final range = (maxVal - minVal).toDouble();

  // Apply fill to every state path
  for (final svgId in allIds) {
    final value = valuesBySvgId[svgId];
    final String hex;
    if (value == null) {
      hex = defaultNoDataFill;
    } else {
      final ratio = range > 0 ? (value - minVal) / range : 0.0;
      final t = _minRatio + ratio * _rangeRatio;
      final color = Color.lerp(lightColor, darkColor, t.clamp(0.0, 1.0)) ?? lightColor;
      hex = '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
    }

    final tagPattern =
        RegExp('(<path)([^>]*id=["\']${RegExp.escape(svgId)}["\'][^>]*)(>)');
    svgData = svgData.replaceFirstMapped(tagPattern, (m) {
      var middle = m.group(2)!;
      middle = middle.replaceAll(RegExp(r'\s*fill="[^"]*"'), '');
      return '${m.group(1)}$middle fill="$hex"${m.group(3)}';
    });
  }

  // Force all text labels in the SVG to black so numbers are clearly visible.
  final textTagPattern = RegExp(r'(<text[^>]*)(>)');
  svgData = svgData.replaceAllMapped(textTagPattern, (m) {
    var middle = m.group(1)!;
    middle = middle.replaceAll(RegExp(r'\s*fill="[^"]*"'), '');
    return '$middle fill="#000000"${m.group(2)}';
  });

  return svgData;
}
