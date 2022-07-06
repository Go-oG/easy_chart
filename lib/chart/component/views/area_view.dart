import 'dart:ui';

import 'package:easy_chart/chart/core/chart_view.dart';

class PathCanvas extends View {
  final Path path;
  final Color? color;
  final Shader? shader;
  final bool fill;

  PathCanvas(this.path, {this.color, this.shader, this.fill = true}) {
    paint.style = fill ? PaintingStyle.fill : PaintingStyle.stroke;
    paint.strokeWidth = 2;
    if (color != null) {
      paint.color = color!;
    }
    if (shader != null) {
      paint.shader = shader!;
    }
  }

  @override
  void onDraw(Canvas canvas, double animatorPercent) {
    canvas.drawPath(path, paint);
  }
}
