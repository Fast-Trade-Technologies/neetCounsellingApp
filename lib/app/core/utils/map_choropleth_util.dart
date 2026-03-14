import 'package:flutter/material.dart';

/// Applies a blue choropleth to India map SVG: light blue (low) to dark blue (high).
/// Modifies path fill for each [valuesBySvgId] and sets root fill to light blue.
String applyChoroplethFill(String svgData, Map<String, int> valuesBySvgId) {
  const lightBlue = Color.fromARGB(255, 131, 191, 235);
  const darkBlue = Color(0xFF1565C0);

  svgData = svgData.replaceFirst(RegExp(r'fill="#6f9c76"'), 'fill="#57b3f4"');

  if (valuesBySvgId.isEmpty) return svgData;

  final values = valuesBySvgId.values.toList();
  final min = values.reduce((a, b) => a < b ? a : b);
  final max = values.reduce((a, b) => a > b ? a : b);
  final range = (max - min).toDouble();

  for (final entry in valuesBySvgId.entries) {
    final svgId = entry.key;
    final value = entry.value;
    final ratio = range > 0 ? (value - min) / range : 0.0;
    final color = Color.lerp(lightBlue, darkBlue, ratio) ?? lightBlue;
    final hex = '#${color.value.toRadixString(16).padLeft(8, '0').substring(2)}';
    final tagPattern = RegExp('(<path)([^>]*id=["\']${RegExp.escape(svgId)}["\'][^>]*)(>)');
    svgData = svgData.replaceFirstMapped(tagPattern, (m) {
      var middle = m.group(2)!;
      middle = middle.replaceAll(RegExp(r'\s*fill="[^"]*"'), '');
      return '${m.group(1)}$middle fill="$hex"${m.group(3)}';
    });
  }
  return svgData;
}
