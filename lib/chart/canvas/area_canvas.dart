import 'dart:ui';

import 'chart_canvas.dart';

class PathCanvas extends ChartCanvas {
  final Path path;
  final Color? color;
  final Shader? shader;
  final bool fill;
  late Paint _paint;

  PathCanvas(this.path, {this.color, this.shader, this.fill = true}) {
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
    canvas.drawPath(path, _paint);
  }


}
