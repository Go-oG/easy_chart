import 'package:easy_chart/chart/core/chart_view.dart';
import 'package:flutter/material.dart';

class RectView extends View {
  final BoxDecoration decoration;
  final bool fill;
  final bool vertical;
  late final BoxPainter boxPainter;

  RectView(this.decoration, {this.fill = true, this.vertical = true, super.paint}) {
    boxPainter = decoration.createBoxPainter();
  }

  @override
  void onDraw(Canvas canvas, double animatorPercent) {
    paint.style = fill ? PaintingStyle.fill : PaintingStyle.stroke;
    paint.strokeWidth = 2;
    if (animatorPercent >= 1) {
      boxPainter.paint(canvas, Offset.zero, ImageConfiguration(size: Size(areaBounds.width, areaBounds.height)));
      return;
    }
    double ph = animatorPercent * areaBounds.height;
    boxPainter.paint(canvas, Offset(0, areaBounds.height - ph), ImageConfiguration(size: Size(areaBounds.width, ph)));
  }
}
