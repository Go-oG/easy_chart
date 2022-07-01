import 'dart:ui';

import 'package:easy_chart/chart/canvas/area_canvas.dart';
import 'package:easy_chart/chart/canvas/chart_canvas.dart';
import 'package:flutter/material.dart';

class RectCanvas extends ChartCanvas {
  final List<Rect> rectList;
  final Color? color;
  final Shader? shader;
  final bool fill;
  final bool vertical;
  late Paint _paint;

  RectCanvas(this.rectList, {this.color, this.shader, this.fill = true, this.vertical = true}) {
    _paint = Paint();
    _paint.style = fill ? PaintingStyle.fill : PaintingStyle.stroke;
    _paint.strokeWidth = 2;
    if (color != null) {
      _paint.color = color!;
    }
    if (shader != null) {
      _paint.shader = shader!;
    }
  }

  @override
  void onDraw(Canvas canvas, double animationPercent) {
    for (var element in rectList) {
      Rect rect;
      if (animationPercent < 0) {
        animationPercent = 0;
      }
      if (animationPercent >= 1) {
        rect = element;
      } else {
        if (vertical) {
          rect = Rect.fromLTRB(
            element.left,
            element.bottom - element.height * animationPercent,
            element.right,
            element.bottom,
          );
        } else {
          rect = Rect.fromLTRB(element.left, element.top, element.left + element.width * animationPercent, element.bottom);
        }
      }
      canvas.drawRect(rect, _paint);
    }
  }
}
