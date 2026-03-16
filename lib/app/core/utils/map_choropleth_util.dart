import 'package:flutter/material.dart';

const _defaultNoDataFill = '#80b3ff';
const _lightBlue = Color.fromARGB(255, 227, 242, 253);
const _darkBlue = Color(0xFF1565C0);
const _minRatio = 0.25;
const _rangeRatio = 0.75;

/// Applies a blue choropleth to India map SVG: light blue (low) to dark blue (high).
/// Every state path gets a fill: with data → choropleth; without data → [_defaultNoDataFill].
/// Uses min ratio so low-value states (e.g. Ladakh) are not too light.
String applyChoroplethFill(String svgData, Map<String, int> valuesBySvgId) {
  svgData = svgData.replaceFirst(RegExp(r'fill="#6f9c76"'), 'fill="$_defaultNoDataFill"');

  final pathIdRegex = RegExp(r'id="(IN[A-Z0-9]+)"');
  final allIds = <String>{};
  for (final m in pathIdRegex.allMatches(svgData)) {
    allIds.add(m.group(1)!);
  }

  double minVal = 0, maxVal = 0;
  if (valuesBySvgId.isNotEmpty) {
    final values = valuesBySvgId.values.toList();
    minVal = values.reduce((a, b) => a < b ? a : b).toDouble();
    maxVal = values.reduce((a, b) => a > b ? a : b).toDouble();
  }
  final range = (maxVal - minVal).toDouble();

  for (final svgId in allIds) {
    final value = valuesBySvgId[svgId];
    final String hex;
    if (value == null) {
      hex = _defaultNoDataFill;
    } else {
      final ratio = range > 0 ? (value - minVal) / range : 0.0;
      final t = _minRatio + ratio * _rangeRatio;
      final color = Color.lerp(_lightBlue, _darkBlue, t.clamp(0.0, 1.0)) ?? _lightBlue;
      hex = '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
    }
    final tagPattern = RegExp('(<path)([^>]*id=["\']${RegExp.escape(svgId)}["\'][^>]*)(>)');
    svgData = svgData.replaceFirstMapped(tagPattern, (m) {
      var middle = m.group(2)!;
      middle = middle.replaceAll(RegExp(r'\s*fill="[^"]*"'), '');
      return '${m.group(1)}$middle fill="$hex"${m.group(3)}';
    });
  }
  return svgData;
}
