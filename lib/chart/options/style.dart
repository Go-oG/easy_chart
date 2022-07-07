import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';

enum AxisSymbol { none, single, double }

enum AxisLineType { solid }

enum OverFlow {
  cut,
  newLine;
}

enum ChartAlign {
  auto,
  topLeft,
  topCenter,
  topRight,
  rightTop,
  rightCenter,
  rightBottom,
  bottomLeft,
  bottomCenter,
  bottomRight,
  leftTop,
  leftCenter,
  leftBottom,
  center
}

enum Align2 { auto, start, center, end }

enum Position {
  top,
  bottom,
  left,
  right,
  center,
}

enum Direction { horizontal, vertical }

class LineStyle {
  final Color color;

  final double width;

  final AxisLineType type;

  final StrokeCap cap;

  final StrokeJoin join;
  final List<double> dash;

  final BoxShadow? shadow;
  final Shader? shader;
  final bool smooth;
  final bool close;

  const LineStyle(
      {this.color = Colors.black,
      this.width = 2,
      this.type = AxisLineType.solid,
      this.cap = StrokeCap.round,
      this.join = StrokeJoin.bevel,
      this.dash = const [],
      this.shadow,
      this.smooth = false,
      this.close = false,
      this.shader});

  void fillPaint(Paint paint) {
    paint.color = color;
    paint.strokeWidth = width.toDouble();
    paint.strokeCap = cap;
    paint.strokeJoin = join;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = width;
  }

  Paint toPaint() {
    Paint paint;
    if (shadow != null) {
      paint = shadow!.toPaint();
    } else {
      paint = Paint();
    }
    fillPaint(paint);
    if (shadow != null) {
      paint.color = shadow!.color;
    }
    return paint;
  }

  Path getPath(Path originalPath) {
    if (dash.isEmpty) {
      return originalPath;
    }
    double dashLength = dash[0];
    double dashGapLength = dashLength >= 2 ? dash[1] : dash[0];

    DashedPathProperties properties = DashedPathProperties(
      path: Path(),
      dashLength: dashLength,
      dashGapLength: dashGapLength,
    );
    final metricsIterator = originalPath.computeMetrics().iterator;
    while (metricsIterator.moveNext()) {
      final metric = metricsIterator.current;
      properties.extractedPathLength = 0.0;
      while (properties.extractedPathLength < metric.length) {
        if (properties.addDashNext) {
          properties.addDash(metric, dashLength);
        } else {
          properties.addDashGap(metric, dashGapLength);
        }
      }
    }
    return properties.path;
  }
}

class AreaStyle {
  Color color = Colors.blueAccent;
  Shader? shader;
  BoxShadow? shadow;

  void fillPaint(Paint paint) {
    paint.color = color;
    if (shader != null) {
      paint.shader = shader;
    }
    if (shadow != null) {
      paint.color = shadow!.color;
      paint.maskFilter = MaskFilter.blur(shadow!.blurStyle, shadow!.blurSigma);
    }
    paint.style = PaintingStyle.fill;
  }
}

//描述项目自身相关的数据
class ItemStyle {
  final BoxDecoration decoration;

  const ItemStyle(this.decoration);
}

class SymbolStyle {
  final ChartSymbol symbol;
  final bool fill;
  final Color? color;
  final Shader? shader;
  final double stockWidth;

  SymbolStyle(this.symbol, {this.color, this.shader, this.fill = true, this.stockWidth = 2}) {
    if (color == null && shader == null) {
      throw FlutterError('Color 和Shader不能同时为空');
    }
  }

  void fillPaint(Paint paint) {
    paint.style = fill ? PaintingStyle.fill : PaintingStyle.stroke;
    if (!fill) {
      paint.strokeWidth = stockWidth;
    }

    if (color != null) {
      paint.color = color!;
    }
    if (shader != null) {
      paint.shader = shader!;
    }
  }
}

class ChartSymbol {
  static const String Circle = 'circle';
  static const String EmptyCircle = 'emptyCircle';
  static const String Rect = 'rect';
  static const String RoundRect = 'roundRect';
  static const String Triangle = 'triangle';
  static const String Diamond = 'diamond';
  static const String Pin = 'pin';
  static const String Arrow = 'arrow';
  static const String None = 'none';

  final String type;
  final Size size;
  final double rotate;
  final bool keepAspect = false;
  final Offset offset;

  const ChartSymbol(this.type, {this.size = const Size(6, 6), this.rotate = 0, this.offset = Offset.zero});

  const ChartSymbol.circle({this.size = const Size(6, 6), this.rotate = 0, this.offset = Offset.zero}) : type = Circle;

  const ChartSymbol.emptyCircle({this.size = const Size(6, 6), this.rotate = 0, this.offset = Offset.zero}) : type = EmptyCircle;

  const ChartSymbol.rect({this.size = const Size(6, 6), this.rotate = 0, this.offset = Offset.zero}) : type = Rect;

  const ChartSymbol.roundRect({this.size = const Size(6, 6), this.rotate = 0, this.offset = Offset.zero}) : type = RoundRect;

  const ChartSymbol.triangle({this.size = const Size(6, 6), this.rotate = 0, this.offset = Offset.zero}) : type = Triangle;

  const ChartSymbol.diamond({this.size = const Size(6, 6), this.rotate = 0, this.offset = Offset.zero}) : type = Diamond;

  const ChartSymbol.pin({this.size = const Size(6, 6), this.rotate = 0, this.offset = Offset.zero}) : type = Pin;

  const ChartSymbol.arrow({this.size = const Size(6, 6), this.rotate = 0, this.offset = Offset.zero}) : type = Arrow;

  const ChartSymbol.none({this.size = const Size(6, 6), this.rotate = 0, this.offset = Offset.zero}) : type = None;

  @override
  String toString() {
    return type;
  }

  @override
  int get hashCode {
    return type.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (other is ChartSymbol) {
      return other.type == type;
    }
    return false;
  }
}

class DashedPathProperties {
  double extractedPathLength;
  Path path;

  final double _dashLength;
  double _remainingDashLength;
  double _remainingDashGapLength;
  bool _previousWasDash;

  DashedPathProperties({
    required this.path,
    required double dashLength,
    required double dashGapLength,
  })  : assert(dashLength > 0.0, 'dashLength must be > 0.0'),
        assert(dashGapLength > 0.0, 'dashGapLength must be > 0.0'),
        _dashLength = dashLength,
        _remainingDashLength = dashLength,
        _remainingDashGapLength = dashGapLength,
        _previousWasDash = false,
        extractedPathLength = 0.0;

  bool get addDashNext {
    if (!_previousWasDash || _remainingDashLength != _dashLength) {
      return true;
    }
    return false;
  }

  void addDash(ui.PathMetric metric, double dashLength) {
    final end = _calculateLength(metric, _remainingDashLength);
    final availableEnd = _calculateLength(metric, dashLength);
    final pathSegment = metric.extractPath(extractedPathLength, end);
    path.addPath(pathSegment, Offset.zero);
    final delta = _remainingDashLength - (end - extractedPathLength);
    _remainingDashLength = _updateRemainingLength(
      delta: delta,
      end: end,
      availableEnd: availableEnd,
      initialLength: dashLength,
    );
    extractedPathLength = end;
    _previousWasDash = true;
  }

  void addDashGap(ui.PathMetric metric, double dashGapLength) {
    final end = _calculateLength(metric, _remainingDashGapLength);
    final availableEnd = _calculateLength(metric, dashGapLength);
    ui.Tangent tangent = metric.getTangentForOffset(end)!;
    path.moveTo(tangent.position.dx, tangent.position.dy);
    final delta = end - extractedPathLength;
    _remainingDashGapLength = _updateRemainingLength(
      delta: delta,
      end: end,
      availableEnd: availableEnd,
      initialLength: dashGapLength,
    );
    extractedPathLength = end;
    _previousWasDash = false;
  }

  double _calculateLength(ui.PathMetric metric, double addedLength) {
    return math.min(extractedPathLength + addedLength, metric.length);
  }

  double _updateRemainingLength({
    required double delta,
    required double end,
    required double availableEnd,
    required double initialLength,
  }) {
    return (delta > 0 && availableEnd == end) ? delta : initialLength;
  }
}
