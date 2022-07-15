import 'dart:ui';

import 'package:easy_chart/chart/core/chart_view.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:easy_chart/chart/utils/paint_util.dart';

class AreaView extends View {
  final Path path;
  final AreaStyle style;

  AreaView(this.path, this.style);

  @override
  void onDraw(Canvas canvas, double animatorPercent) {
    paint.reset();
    style.fillPaint(paint);
    canvas.drawPath(path, paint);
  }
}
