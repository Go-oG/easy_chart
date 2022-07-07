import 'dart:math';
import 'dart:ui';
import 'package:easy_chart/chart/core/chart_view.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:easy_chart/chart/utils/monotonex.dart';

class LineView extends View {
  final List<Offset> pointList;
  final LineStyle style;

  late Path _path;

  LineView(this.pointList, this.style, {super.paint}) {
    if (pointList.length > 1) {
      if (style.smooth) {
        _path = MonotoneX.addCurve(null, pointList);
      } else {
        _path = Path();
        _path.moveTo(pointList.first.dx.toDouble(), pointList.first.dy.toDouble());
        for (int i = 1; i < pointList.length; i++) {
          Offset p = pointList[i];
          _path.lineTo(p.dx.toDouble(), p.dy.toDouble());
        }
      }
    }
  }

  @override
  void onDraw(Canvas canvas, double animatorPercent) {
    if (pointList.isEmpty) {
      return;
    }
    style.fillPaint(paint);
    if (pointList.length == 1) {
      canvas.drawPoints(PointMode.points, [Offset(pointList.first.dx.toDouble(), pointList.first.dy.toDouble())], paint);
      return;
    }
    canvas.drawPath(_path, paint);
  }
}
