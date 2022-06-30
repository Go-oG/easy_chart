import 'dart:math';
import 'dart:ui';

import 'package:easy_chart/chart/canvas/chart_canvas.dart';
import 'package:easy_chart/chart/utils/monotonex.dart';
import 'package:flutter/material.dart';

class LineCanvas extends ChartCanvas {
  final List<Point> pointList;
  final double lineWidth;
  final Color? color;
  final Shadow? shadow;
  final Shader? gradient;
  final bool smooth;
  late Paint mPaint;
  late Path _path;

  LineCanvas(this.pointList, {this.lineWidth = 2, this.color, this.shadow, this.gradient, this.smooth = false}) {
    mPaint = Paint();
    mPaint.strokeWidth = lineWidth;
    if (color != null) {
      mPaint.color = color!;
    }
    if (shadow != null) {
      mPaint.color = shadow!.color;
      mPaint.maskFilter = MaskFilter.blur(BlurStyle.normal, shadow!.blurSigma);
    }
    if (gradient != null) {
      mPaint.shader = gradient!;
    }
    mPaint.style = PaintingStyle.stroke;
    if (pointList.length > 1) {
      if (smooth) {
        _path = MonotoneX.addCurve(null, pointList);
      } else {
        _path = Path();
        _path.moveTo(pointList.first.x.toDouble(), pointList.first.y.toDouble());
        for (int i = 1; i < pointList.length; i++) {
          Point p = pointList[i];
          _path.lineTo(p.x.toDouble(), p.y.toDouble());
        }
      }
    }
  }

  @override
  void onDraw(Canvas canvas, double animationPercent) {
    if (pointList.isEmpty) {
      return;
    }

    if (pointList.length == 1) {
      canvas.drawPoints(PointMode.points, [Offset(pointList.first.x.toDouble(), pointList.first.y.toDouble())], mPaint);
      return;
    }

    canvas.drawPath(_path, mPaint);
  }
}
