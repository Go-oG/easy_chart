import 'dart:ui';
import 'package:easy_chart/chart/component/views/shape_view.dart';
import 'package:easy_chart/chart/core/chart_view.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:easy_chart/chart/utils/monotonex.dart';
import 'package:easy_chart/chart/utils/paint_util.dart';
import 'package:flutter/material.dart';

class LineView extends ViewGroup {
  final List<Offset> pointList;
  final LineStyle style;
  final bool showSymbol;
  final bool close;
  final SymbolStyle? symbolStyle;
  late Path _path;

  LineView(this.pointList, this.style, {this.showSymbol = false, this.symbolStyle, this.close = false, super.paint}) {
    if (showSymbol && symbolStyle == null) {
      throw FlutterError('当需要显示Symbol时，symbolStyle必须不为空');
    }
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
      if (close) {
        _path.close();
      }
    }
  }

  @override
  @mustCallSuper
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    if (!showSymbol) {
      return;
    }
    SymbolStyle tmpStyle = symbolStyle!;
    Size size = tmpStyle.size;
    for (var element in pointList) {
      ShapeView shapeView = ShapeView(tmpStyle, paint: paint);
      shapeView.measure(size.width, size.height);
      shapeView.layout(
          element.dx - size.width / 2, element.dy - size.height / 2, element.dx + size.width / 2, element.dy + size.height / 2);
      addView(shapeView);
    }
  }

  @override
  void onDraw(Canvas canvas, double animatorPercent) {
    super.onDraw(canvas, animatorPercent);
    if (pointList.isEmpty) {
      return;
    }
    paint.reset();
    style.fillPaint(paint);
    if (pointList.length == 1) {
      canvas.drawPoints(PointMode.points, [Offset(pointList.first.dx.toDouble(), pointList.first.dy.toDouble())], paint);
    } else {
      canvas.drawPath(_path, paint);
    }
  }
}
