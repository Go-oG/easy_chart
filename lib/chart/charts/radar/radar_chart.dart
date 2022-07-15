import 'dart:math' as math;

import 'package:easy_chart/chart/charts/radar/radar_series.dart';
import 'package:easy_chart/chart/component/views/area_view.dart';
import 'package:easy_chart/chart/component/views/line_view.dart';
import 'package:easy_chart/chart/component/views/shape_view.dart';
import 'package:easy_chart/chart/core/chart_view.dart';
import 'package:easy_chart/chart/options/axis_line.dart';
import 'package:easy_chart/chart/options/radar.dart';
import 'package:easy_chart/chart/utils/paint_util.dart';
import 'package:flutter/material.dart';

/// 雷达图
class RadarChartView extends ViewGroup {
  final RadarSeries series;

  RadarChartView(this.series, {super.paint, super.zIndex = 0}) {
    Radar radar = series.radar;
    int axisCount = radar.indicatorList.length;
    int splitCount = radar.splitNumber;
    bool circle = radar.shape == RadarShape.circle;
    double offsetAngle = radar.offsetAngle;

    //添加轴视图
    if (radar.show) {
      RadarAxisView axisView = RadarAxisView(
        axisCount,
        splitCount,
        radar.axisLine,
        circle: circle,
        offsetAngle: offsetAngle,
        areaColors: radar.areaColorList,
      );
      addView(axisView);
    }

    List<double> maxDataList = List.filled(axisCount, 0, growable: true);
    List<double> minDataList = List.filled(axisCount, 0, growable: true);

    for (int i = 0; i < axisCount; i++) {
      maxDataList[i] = radar.indicatorList[i].max;
      minDataList[i] = radar.indicatorList[i].min;
    }

    for (var element in series.dataList) {
      RadarChildView childView = RadarChildView(element, axisCount, maxDataList, minDataList, offsetAngle, paint: paint);
      addView(childView);
    }
  }
}

/// 雷达图坐标轴视图
class RadarAxisView extends View {
  final int axisCount;
  final int splitCount;

  /// 坐标轴是否是圆形视图
  final bool circle;

  /// 旋转偏移量
  final double offsetAngle;
  final List<Color> areaColors;

  /// 坐标轴
  final AxisLine axisLine;

  RadarAxisView(
    this.axisCount,
    this.splitCount,
    this.axisLine, {
    this.circle = false,
    this.offsetAngle = 0,
    this.areaColors = const [],
    super.paint,
  });

  /// 存储点坐标
  final List<List<Offset>> _pointList = [];
  bool _needComputePoint = true;

  @override
  @mustCallSuper
  void onLayout(double left, double top, double right, double bottom) {
    if (left != super.left || top != super.top || right != super.right || bottom != super.bottom) {
      _needComputePoint = true;
    }
    super.onLayout(left, top, right, bottom);
    _computePointIfNeed();
  }

  @override
  @protected
  void onDraw(Canvas canvas, double animatorPercent) {
    if(!axisLine.show){
      return;
    }
    canvas.translate(centerX, centerY);
    double singleHeight = 0.5 * math.min(height, width) / splitCount;
    double singleAngle = 360 / axisCount;

    //绘制背景 应该倒序
    if (areaColors.isNotEmpty) {
      paint.reset();
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
    paint.reset();
    axisLine.style.fillPaint(paint);
    Path path = Path();
    for (int i = 0; i < axisCount; i++) {
      double angle = offsetAngle - 90 + i * singleAngle;
      double radians = angle * math.pi / 180;
      double th = 0.5 * math.min(height, width);
      double x = th * math.cos(radians);
      double y = th * math.sin(radians);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
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

/// 雷达图子View
class RadarChildView extends ViewGroup {
  final RadarData data;
  final List<double> maxDataList;
  final List<double> minDataList;
  final int axisCount;
  final double offsetAngle;

  /// 绘制视图
  final Path _path = Path();
  final List<Offset> _offsetList = [];

  RadarChildView(
    this.data,
    this.axisCount,
    this.maxDataList,
    this.minDataList,
    this.offsetAngle, {
    super.paint,
  });

  @override
  @mustCallSuper
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    _offsetList.clear();
    clearChildren();
    double itemAngle = 360 / axisCount;
    double radius = 0.5 * math.min(height, width);
    for (int i = 0; i < axisCount; i++) {
      double d = 0;
      if (i < data.dataList.length) {
        d = data.dataList[i];
      }
      double angle = offsetAngle - 90 + i * itemAngle;
      double radians = angle * math.pi / 180;
      double sub = maxDataList[i] - minDataList[i];
      Offset offset;
      if (sub == 0) {
        offset = Offset(radius, radius);
      } else {
        double percent = (d - minDataList[i]) / (maxDataList[i] - minDataList[i]);
        print('radar Percent:$percent  $d  ${maxDataList[i]}  ${minDataList[i]}');
        double length = percent * radius;
        double x = length * math.cos(radians);
        double y = length * math.sin(radians);
        offset = Offset(x + centerX, y + centerY);
      }
      _offsetList.add(offset);
    }

    if (_offsetList.length > 1) {
      _path.moveTo(_offsetList[0].dx, _offsetList[0].dy);
      for (int i = 1; i < _offsetList.length; i++) {
        Offset offset = _offsetList[i];
        _path.lineTo(offset.dx, offset.dy);
      }
      _path.close();
    }

    if (data.areaStyle != null && _offsetList.length >= 3) {
      Path path = Path();
      path.moveTo(_offsetList[0].dx, _offsetList[0].dy);
      for (Offset offset in _offsetList) {
        path.lineTo(offset.dx, offset.dy);
      }
      path.close();
      AreaView areaView = AreaView(path, data.areaStyle!);
      areaView.onMeasure(width, height);
      areaView.onLayout(0, 0, width, height);
      addView(areaView);
    }

    if (data.lineStyle != null && _offsetList.length >= 2) {
      LineView lineView = LineView(_offsetList, data.lineStyle!, paint: paint, close: true);
      lineView.onMeasure(width, height);
      lineView.onLayout(0, 0, width, height);
      addView(lineView);
    }

    if (data.showSymbol && data.symbolStyle != null) {
      for (Offset offset in _offsetList) {
        ShapeView shapeView = ShapeView(data.symbolStyle!, paint: paint);
        shapeView.onMeasure(data.symbolStyle!.size.width, data.symbolStyle!.size.height);
        double left = offset.dx - data.symbolStyle!.size.width / 2;
        double top = offset.dx - data.symbolStyle!.size.height / 2;
        double right = offset.dx + data.symbolStyle!.size.width / 2;
        double bottom = offset.dx + data.symbolStyle!.size.height / 2;
        shapeView.onLayout(left, top, right, bottom);
        addView(shapeView);
      }
    }
  }
}
