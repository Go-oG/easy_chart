import 'dart:math';

import 'package:flutter/material.dart';

class LinePainter {

  static void draw(
      {required Canvas canvas,
      required Paint paint,
      required List<Point> points,
      Rectangle<num>? clipBounds,
      Color? fill,
      Color? stroke,
      bool? roundEndCaps,
      double? strokeWidthPx,
      List<int>? dashPattern,
      Shader? shader}) {
    if (points.isEmpty) {
      return;
    }

    if (clipBounds != null) {
      canvas
        ..save()
        ..clipRect(Rect.fromLTWH(
            clipBounds.left.toDouble(), clipBounds.top.toDouble(), clipBounds.width.toDouble(), clipBounds.height.toDouble()));
    }

    paint.color = Color.fromARGB(stroke!.alpha, stroke.red, stroke.green, stroke.blue);

    if (shader != null) {
      paint.shader = shader;
    }

    if (points.length == 1) {
      final point = points.first;
      paint.style = PaintingStyle.fill;
      canvas.drawCircle(Offset(point.x.toDouble(), point.y.toDouble()), strokeWidthPx ?? 0, paint);
    } else {
      if (strokeWidthPx != null) {
        paint.strokeWidth = strokeWidthPx;
      }
      paint.strokeJoin = StrokeJoin.round;
      paint.style = PaintingStyle.stroke;

      if (dashPattern == null || dashPattern.isEmpty) {
        if (roundEndCaps == true) {
          paint.strokeCap = StrokeCap.round;
        }
        _drawSolidLine(canvas, paint, points);
      } else {
        _drawDashedLine(canvas, paint, points, dashPattern);
      }
    }
    if (clipBounds != null) {
      canvas.restore();
    }
  }

  static void _drawSolidLine(Canvas canvas, Paint paint, List<Point> points) {
    final path = Path()..moveTo(points.first.x.toDouble(), points.first.y.toDouble());
    for (var point in points) {
      path.lineTo(point.x.toDouble(), point.y.toDouble());
    }
    canvas.drawPath(path, paint);
  }

  static void _drawDashedLine(Canvas canvas, Paint paint, List<Point> points, List<int> dashPattern) {
    final localDashPattern = List.from(dashPattern);
    if (dashPattern.length % 2 == 1) {
      localDashPattern.addAll(dashPattern);
    }

    // Stores the previous point in the series.
    var previousSeriesPoint = _getOffset(points.first);

    var remainder = 0;
    var solid = true;
    var dashPatternIndex = 0;

    var getNextDashPatternSegment = () {
      final dashSegment = localDashPattern[dashPatternIndex];
      dashPatternIndex = (dashPatternIndex + 1) % localDashPattern.length;
      return dashSegment;
    };

    var remainderPoints;
    for (var pointIndex = 1; pointIndex < points.length; pointIndex++) {
      final seriesPoint = _getOffset(points[pointIndex]);

      if (previousSeriesPoint == seriesPoint) {

      } else {
        var previousPoint = previousSeriesPoint;
        var d = _getOffsetDistance(previousSeriesPoint, seriesPoint);

        while (d > 0) {
          var dashSegment = remainder > 0 ? remainder : getNextDashPatternSegment();
          remainder = 0;

          final v = seriesPoint - previousPoint;
          final u = Offset(v.dx / v.distance, v.dy / v.distance);

          final distance = d < dashSegment ? d : dashSegment.toDouble();
          final nextPoint = previousPoint + (u * distance);

          if (solid) {
            if (remainderPoints != null) {
              remainderPoints.add(Offset(nextPoint.dx, nextPoint.dy));
              final path = Path()..moveTo(remainderPoints.first.dx, remainderPoints.first.dy);
              for (var p in remainderPoints) {
                path.lineTo(p.dx, p.dy);
              }
              canvas.drawPath(path, paint);
              remainderPoints = null;
            } else {
              if (d < dashSegment && pointIndex < points.length - 1) {
                remainderPoints = [Offset(previousPoint.dx, previousPoint.dy), Offset(nextPoint.dx, nextPoint.dy)];
              } else {
                canvas.drawLine(previousPoint, nextPoint, paint);
              }
            }
          }
          solid = !solid;
          previousPoint = nextPoint;
          d = d - dashSegment;
        }
        remainder = -d.round();
        if (remainder > 0) {
          solid = !solid;
        }
      }
      previousSeriesPoint = seriesPoint;
    }
  }

  static Offset _getOffset(Point point) => Offset(point.x.toDouble(), point.y.toDouble());

  static num _getOffsetDistance(Offset o1, Offset o2) {
    final p1 = Point(o1.dx, o1.dy);
    final p2 = Point(o2.dx, o2.dy);
    return p1.distanceTo(p2);
  }
}
