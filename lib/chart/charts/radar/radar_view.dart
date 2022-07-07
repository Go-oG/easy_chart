import 'dart:math' as math;

import 'package:easy_chart/chart/component/views/area_view.dart';
import 'package:easy_chart/chart/component/views/line_view.dart';
import 'package:easy_chart/chart/component/views/shape_view.dart';
import 'package:easy_chart/chart/core/chart_view.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:flutter/material.dart';

class RadarView extends View {
  final int axisCount;
  final int splitCount;
  final bool circle;
  final double offsetAngle;
  final List<Color> areaColors;
  final Color axisColor;

  RadarView(
    this.axisCount,
    this.splitCount, {
    super.paint,
    this.circle = false,
    this.offsetAngle = 0,
    this.areaColors = const [],
    this.axisColor = Colors.black45,
  }) {
    if (areaColors.isNotEmpty && areaColors.length != splitCount) {
      throw FlutterError('areaColor 必须和splitCount相匹配');
    }

  }

  final List<List<Offset>> _pointList = [];
  bool _needComputePoint = true;

  @override
  @mustCallSuper
  void onLayout(double left, double top, double right, double bottom) {
    if (left != super.left || top != super.top || right != super.right || bottom != super.bottom) {
      _needComputePoint = true;
    }
    super.onLayout(left, top, right, bottom);
  }

  @override
  @protected
  void onDraw(Canvas canvas, double animatorPercent) {
    canvas.translate(centerX, centerY);
    double singleHeight = 0.5 * math.min(height, width) / splitCount;
    double singleAngle = 360 / axisCount;
    _computePointIfNeed();

    //绘制背景 应该倒序
    if (areaColors.isNotEmpty) {
      paint.style = PaintingStyle.fill;
      for (int i = _pointList.length - 1; i >= 0; i--) {
        paint.color = areaColors[i];
        List<Offset> list = _pointList[i];
        if (circle) {
          canvas.drawCircle(Offset.zero, singleHeight * i, paint);
        } else {
          Path path = Path();
          path.moveTo(list[0].dx, list[0].dy);
          for (var element in list) {
            path.lineTo(element.dx, element.dy);
          }
          path.close();
          canvas.drawPath(path, paint);
        }
      }
    }

    //绘制轴线
    paint.color = Colors.white;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1;
    for (int i = 0; i < axisCount; i++) {
      double angle = offsetAngle - 90 + i * singleAngle;
      double radians = angle * math.pi / 180;
      double th = 0.5 * math.min(height, width);
      double x = th * math.cos(radians);
      double y = th * math.sin(radians);
      Offset offset = Offset(x, y);
      canvas.drawLine(Offset.zero, offset, paint);
    }
  }

  void _computePointIfNeed() {
    if (!_needComputePoint && _pointList.isNotEmpty) {
      return;
    }

    _pointList.clear();
    double singleHeight = 0.5 * math.min(height, width) / splitCount;
    double singleAngle = 360 / axisCount;
    for (int i = 0; i < splitCount; i++) {
      _pointList.add([]);
    }
    for (int i = 0; i < axisCount; i++) {
      double angle = offsetAngle - 90 + i * singleAngle;
      double radians = angle * math.pi / 180;
      for (int j = 0; j < splitCount; j++) {
        double th = (j + 1) * singleHeight;
        double x = th * math.cos(radians);
        double y = th * math.sin(radians);
        Offset offset = Offset(x, y);
        _pointList[j].add(offset);
      }
    }
    _needComputePoint = false;
  }
}

class RadarItemView extends ViewGroup {
  final int axisCount;
  final int splitCount;
  final double maxValue;
  final double offsetAngle;
  final LineStyle? lineStyle;
  final AreaStyle? areaStyle;
  final bool showSymbol;
  final SymbolStyle? symbolStyle;
  final List<num> dataList;

  RadarItemView(
    this.maxValue,
    this.dataList,
    this.axisCount,
    this.splitCount, {
    this.offsetAngle = 0,
    this.lineStyle,
    this.areaStyle,
    this.showSymbol = false,
    this.symbolStyle,
    super.paint,
  }) {
    if (lineStyle == null && areaStyle == null) {
      throw FlutterError('lineStyle和AreaStyle不能同时为空');
    }
  }

  @override
  @mustCallSuper
  void onMeasure(double parentWidth, double parentHeight) {
    super.onMeasure(parentWidth, parentHeight);
  }

  @override
  @mustCallSuper
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    double maxHeight = 0.5 * math.min(height, width);
    double singleAngle = 360 / axisCount;
    Path path = Path();
    bool move = true;
    List<Offset> offsetList = [];
    for (int i = 0; i < axisCount; i++) {
      double angle = offsetAngle - 90 + i * singleAngle;
      double radians = angle * math.pi / 180;
      double data = 0;
      if (i < dataList.length) {
        data = dataList[i].toDouble();
      }
      double h = maxHeight * (data / maxValue);
      double x = h * math.cos(radians);
      double y = h * math.sin(radians);
      offsetList.add(Offset(x, y));
      if (move) {
        path.moveTo(x, y);
        move = false;
      } else {
        path.lineTo(x, y);
      }
    }

    if (areaStyle != null) {
      AreaView areaView = AreaView(path, areaStyle!);
      areaView.onMeasure(width, height);
      areaView.onLayout(0, 0, width, height);
      addView1(areaView);
    }

    if (lineStyle != null) {
      LineView lineView = LineView(offsetList, lineStyle!, paint: paint);
      lineView.onMeasure(width, height);
      lineView.onLayout(0, 0, width, height);
      addView1(lineView);
    }

    if (!showSymbol || symbolStyle == null) {
      return;
    }

    for (Offset offset in offsetList) {
      ShapeView shapeView = ShapeView(symbolStyle!, paint: paint);
      shapeView.onMeasure(symbolStyle!.symbol.size.width, symbolStyle!.symbol.size.height);
      double left = offset.dx - symbolStyle!.symbol.size.width / 2;
      double top = offset.dx - symbolStyle!.symbol.size.height / 2;
      double right = offset.dx + symbolStyle!.symbol.size.width / 2;
      double bottom = offset.dx + symbolStyle!.symbol.size.height / 2;
      shapeView.onLayout(left,top,right,bottom);
      addView1(shapeView);
    }
  }

}
