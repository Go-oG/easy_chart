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
  Color color = Colors.black;
  double width = 2;
  AxisLineType type = AxisLineType.solid;
  StrokeCap cap = StrokeCap.round;
  StrokeJoin join = StrokeJoin.bevel;
  List<double> dash = [];
  BoxShadow? shadow;

  void fillPaint(Paint paint) {
    paint.style = PaintingStyle.fill;
    paint.color = color;
    paint.strokeWidth = width.toDouble();
    paint.strokeCap = cap;
    paint.strokeJoin = join;
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
  List<Color> color = [Colors.blue];
  BoxShadow shadow = const BoxShadow();

  void fillPaint(Paint paint) {}
}

//描述项目自身相关的数据
class ItemStyle{
  Color color = Colors.black;
  BoxDecoration? decoration;
  Gradient? gradient;
  BoxShadow? shadow;
}

class ChartSymbol {
  final String type;
  final Size size;
  final double rotate;
  final bool keepAspect = false;
  final Offset offset;

  static const ChartSymbol circle = ChartSymbol('circle');
  static const ChartSymbol rect = ChartSymbol('rect');
  static const ChartSymbol roundRect = ChartSymbol('roundRect');
  static const ChartSymbol triangle = ChartSymbol('triangle');
  static const ChartSymbol diamond = ChartSymbol('diamond');
  static const ChartSymbol pin = ChartSymbol('pin');
  static const ChartSymbol arrow = ChartSymbol('arrow');
  static const ChartSymbol none = ChartSymbol('none');

  const ChartSymbol(this.type, {this.size = const Size(12, 12), this.rotate = 0, this.offset = Offset.zero});

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