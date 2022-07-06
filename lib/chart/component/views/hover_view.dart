import 'dart:math';
import 'dart:ui';
import 'package:easy_chart/chart/core/chart_view.dart';
import 'package:flutter/material.dart';

class HoverView extends View {
  final Color color;

  HoverView(this.color, {super.paint});

  @override
  void onDraw(Canvas canvas, double animatorPercent) {
    if (!hoverable || !hovered) {
      return;
    }
    paint.color = color;
    paint.style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);
  }

  @override
  bool hitTest(Offset position) {
    Rectangle rectangle = Rectangle(left, top, width, height);
    return rectangle.containsPoint(Point(position.dx, position.dy));
  }


}
