import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xml/xml.dart';
import 'package:path_drawing/path_drawing.dart';

class IndiaMapScreen extends StatefulWidget {
  const IndiaMapScreen({super.key});

  @override
  State<IndiaMapScreen> createState() => _IndiaMapScreenState();
}

class _IndiaMapScreenState extends State<IndiaMapScreen> {
  Map<String, Path> statePaths = {};
  Map<String, List<Offset>> stateDots = {};
  String? selectedState;

  /// Raw API-style map data: keys like "in-ap", "in-rj", etc.
  /// In your real app, fill this from the backend instead of hardcoding.
  final Map<String, int> _apiMapData = const {
    "in-ap": 20,
    "in-ar": 1,
    "in-as": 15,
    "in-br": 13,
    "in-cg": 11,
    "in-ga": 1,
    "in-gj": 14,
    "in-hr": 10,
    "in-hp": 7,
    "in-jh": 8,
    "in-ka": 37,
    "in-kl": 15,
    "in-mp": 21,
    "in-mh": 59,
    "in-mn": 3,
    "in-ml": 2,
    "in-mz": 1,
    "in-nl": 1,
    "in-or": 18,
    "in-pb": 6,
    "in-rj": 34,
    "in-tn": 51,
    "in-tg": 39,
    "in-tr": 1,
    "in-up": 52,
    "in-ut": 7,
    "in-wb": 26,
    "in-an": 1,
    "in-ch": 1,
    "in-dnhdd": 1,
    "in-dl": 10,
    "in-py": 7,
    "in-jk": 11,
  };

  /// Same data keyed by SVG ids like "INAP", "INRJ" used in india_states.svg.
  Map<String, int> _svgMapData = {};

  final TransformationController _controller = TransformationController();
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    loadSvg();

    _controller.value = Matrix4.identity()..scale(0.7);
  }

  Future<void> loadSvg() async {
    final rawSvg =
        await rootBundle.loadString('assets/maps/india_states.svg');

    final document = XmlDocument.parse(rawSvg);
    final paths = document.findAllElements('path');

    Map<String, Path> temp = {};

    for (var p in paths) {
      final id = p.getAttribute('id');
      final d = p.getAttribute('d');

      if (id != null && d != null) {
        temp[id] = parseSvgPathData(d);
      }
    }

    /// 🔥 generate dots for each state (first dot is center)
    Map<String, List<Offset>> dots = {};
    for (final e in temp.entries) {
      dots[e.key] = _generateDots(e.value.getBounds().center);
    }

    /// 🔥 convert API keys "in-ap" -> SVG ids "INAP"
    Map<String, int> svgData = {};
    _apiMapData.forEach((apiKey, value) {
      final svgId = _toSvgId(apiKey);
      svgData[svgId] = value;
    });

    setState(() {
      statePaths = temp;
      stateDots = dots;
      _svgMapData = svgData;
    });
  }

  List<Offset> _generateDots(Offset center) {
    return [
      center,
      center + const Offset(10, 10),
      center + const Offset(-10, -10),
      center + const Offset(15, -10),
      center + const Offset(-15, 10),
    ];
  }

  /// 🔥 reverse InteractiveViewer transform
  Offset _transformToCanvas(Offset point) {
    final matrix = _controller.value;
    final inverseMatrix = Matrix4.inverted(matrix);
    return MatrixUtils.transformPoint(inverseMatrix, point);
  }

  /// 🔥 reverse painter transform
  Offset _toSvgSpace(Offset canvasPoint, Size size) {
    final fullBounds = MapPainter.computeFullBounds(statePaths);

    final scaleX = size.width / fullBounds.width;
    final scaleY = size.height / fullBounds.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    final dx = (size.width - fullBounds.width * scale) / 2;
    final dy = (size.height - fullBounds.height * scale) / 2;

    return Offset(
      (canvasPoint.dx - dx) / scale,
      (canvasPoint.dy - dy) / scale,
    );
  }

  String? getTappedState(Offset pos) {
    for (var entry in statePaths.entries) {
      if (entry.value.contains(pos)) {
        return entry.key;
      }
    }
    return null;
  }

  String? getTappedDot(Offset pos) {
    if (selectedState == null) return null;

    const radius = 50.0;
    final dots = stateDots[selectedState!] ?? [];

    for (final dot in dots) {
      if ((dot - pos).distance <= radius) {
        return selectedState;
      }
    }
    return null;
  }

  static const Map<String, List<String>> _stateColleges = {
    'INUP': ['KGMU', 'GSVM'],
    'INMH': ['Grant Medical', 'KEM Hospital'],
    'INRJ': ['SMS Medical', 'SN Medical'],
  };

  /// Helper: "in-ap" -> "INAP", "in-dnhdd" -> "INDNHDD"
  String _toSvgId(String apiKey) {
    return apiKey.toUpperCase().replaceAll('-', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(selectedState ?? "India Map"),
        leading: selectedState != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => selectedState = null),
              )
            : null,
      ),
      body: statePaths.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final size =
                    Size(constraints.maxWidth, constraints.maxHeight);

                return GestureDetector(
                  onTapUp: (details) {
                    if(selectedState != null) return;
                    final canvasPoint =
                        _transformToCanvas(details.localPosition);

                    final svgPoint = _toSvgSpace(canvasPoint, size);

                    /// 🔥 DOT CLICK
                    final dotState = getTappedDot(svgPoint);
                    if (dotState != null) {
                      final list =
                          _stateColleges[dotState] ?? ['Medical College'];
                      final name = list[_random.nextInt(list.length)];

                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(dotState),
                          content: Text(name),
                        ),
                      );
                      return;
                    }

                    /// 🔥 STATE CLICK
                    final tapped = getTappedState(svgPoint);
                    if (tapped != null) {
                      setState(() => selectedState = tapped);
                    }
                  },
                  child: InteractiveViewer(
                    transformationController: _controller,
                    minScale: 0.5,
                    maxScale: 5,
                    child: CustomPaint(
                      size: size,
                      painter: MapPainter(
                        statePaths,
                        stateDots,
                        selectedState,
                        mapData: _svgMapData,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class MapPainter extends CustomPainter {
  final Map<String, Path> paths;
  final Map<String, List<Offset>> dots;
  final String? selected;
  final Map<String, int> mapData;

  MapPainter(this.paths, this.dots, this.selected, {required this.mapData});

  static Rect computeFullBounds(Map<String, Path> paths) {
    Rect? bounds;
    for (final path in paths.values) {
      bounds = bounds == null
          ? path.getBounds()
          : bounds.expandToInclude(path.getBounds());
    }
    return bounds ?? Rect.zero;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final fill = Paint()..style = PaintingStyle.fill;
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.white
      ..strokeWidth = 1;

    final fullBounds = computeFullBounds(paths);

    final scale = min(
      size.width / fullBounds.width,
      size.height / fullBounds.height,
    );

    final dx = (size.width - fullBounds.width * scale) / 2;
    final dy = (size.height - fullBounds.height * scale) / 2;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);

    // Precompute data range for simple choropleth
    final dataValues = mapData.values.toList();
    final intMin =
        dataValues.isEmpty ? 0 : dataValues.reduce((a, b) => a < b ? a : b);
    final intMax =
        dataValues.isEmpty ? 0 : dataValues.reduce((a, b) => a > b ? a : b);
    final range = (intMax - intMin).clamp(1, 1 << 30);

    if (selected == null) {
      // Full India view with data-driven colors
      paths.forEach((id, path) {
        final v = mapData[id];
        if (v == null) {
          fill.color = Colors.grey.shade300;
        } else {
          final t = ((v - intMin) / range).clamp(0.0, 1.0);
          fill.color = Color.lerp(
                Colors.lightBlue.shade100,
                Colors.blue.shade800,
                t,
              ) ??
              Colors.blue;
        }
        canvas.drawPath(path, fill);
        canvas.drawPath(path, border);
      });
    } else {
      /// background
      paths.forEach((_, path) {
        fill.color = Colors.grey.shade300;
        canvas.drawPath(path, fill);
      });

      /// selected zoom
      final path = paths[selected]!;
      final bounds = path.getBounds();

      final zoomScale = (fullBounds.width * 0.45) / bounds.width;

      canvas.save();
      canvas.translate(
        fullBounds.center.dx - bounds.center.dx * zoomScale,
        fullBounds.center.dy - bounds.center.dy * zoomScale,
      );
      canvas.scale(zoomScale);

      fill.color = Colors.orange;
      canvas.drawPath(path, fill);
      canvas.drawPath(path, border);
      canvas.restore();

      // 🔥 draw dots ONLY for selected state inside zoom transform
      canvas.save();
      canvas.translate(
        fullBounds.center.dx - bounds.center.dx * zoomScale,
        fullBounds.center.dy - bounds.center.dy * zoomScale,
      );
      canvas.scale(zoomScale);

      final dotPaint = Paint()..color = Colors.redAccent;
      for (final dot in dots[selected] ?? []) {
        canvas.drawCircle(dot, 5, dotPaint);
      }
      canvas.restore();
    }

    // Draw numeric values for all states at their first dot position (center)
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    dots.forEach((id, dotList) {
      final v = mapData[id];
      if (v == null || dotList.isEmpty) return;
      final center = dotList.first;

      textPainter.text = TextSpan(
        text: v.toString(),
        style: TextStyle(
          color: id == selected ? Colors.black : Colors.black87,
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      );
      textPainter.layout(minWidth: 0, maxWidth: 40);
      final offset =
          center - Offset(textPainter.width / 2, textPainter.height / 2);
      textPainter.paint(canvas, offset);
    });

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}