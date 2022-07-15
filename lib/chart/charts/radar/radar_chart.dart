import 'dart:math' as math;

import 'package:easy_chart/chart/charts/radar/radar_series.dart';
import 'package:easy_chart/chart/component/views/area_view.dart';
import 'package:easy_chart/chart/component/views/line_view.dart';
import 'package:easy_chart/chart/core/chart_view.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:easy_chart/chart/utils/paint_util.dart';
import 'package:flutter/material.dart';

/// 雷达图
class RadarChartView extends ViewGroup {
  final RadarSeries series;

  RadarChartView(this.series, {super.paint, super.zIndex = 0}) {
    RadarAxis radarAxis = series.radar;
    int axisCount = radarAxis.indicatorList.length;
    double offsetAngle = radarAxis.offsetAngle;

    //添加轴视图
    if (radarAxis.show) {
      RadarAxisView axisView = RadarAxisView(radarAxis);
      addView(axisView);
    }

    List<double> maxDataList = List.filled(axisCount, 0, growable: true);
    List<double> minDataList = List.filled(axisCount, 0, growable: true);

    for (int i = 0; i < axisCount; i++) {
      maxDataList[i] = radarAxis.indicatorList[i].max;
      minDataList[i] = radarAxis.indicatorList[i].min;
    }
    for (var element in series.dataList) {
      RadarChildView childView = RadarChildView(radarAxis, element, axisCount, maxDataList, minDataList, offsetAngle, paint: paint);
      addView(childView);
    }
  }

  @override
  @mustCallSuper
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    RadarAxis axis = series.radar;
    double cx = axis.center[0].convert(width);
    double cy = axis.center[1].convert(height);
    double radius = 0.5*axis.radius.convert(math.min(width, height));
    for (var element in children) {
      element.onLayout(cx - radius, cy - radius, cx + radius, cy + radius);
    }
  }
}

/// 雷达图坐标轴视图
class RadarAxisView extends View {
  final RadarAxis axis;

  RadarAxisView(this.axis, {super.paint, super.zIndex});

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
    canvas.translate(centerX, centerY);
    double singleHeight = 0.5 * math.min(height, width) / axis.splitNumber;

    Path path = Path();
    for (int i = _pointList.length - 1; i >= 0; i--) {
      if (axis.styleList.isEmpty || i >= axis.styleList.length) {
        continue;
      }

      ItemStyle style = axis.styleList[i];
      path.reset();

      //计算路径
      List<Offset> list = _pointList[i];
      if (axis.shape == RadarShape.circle) {
        path.addArc(Rect.fromCircle(center: Offset.zero, radius: singleHeight * i), 0, 2 * math.pi);
      } else {
        path.moveTo(list[0].dx, list[0].dy);
        for (var element in list) {
          path.lineTo(element.dx, element.dy);
        }
        path.close();
      }

      //绘制背景
      paint.reset();
      paint.style = PaintingStyle.fill;
      paint.color = style.color;
      canvas.drawPath(path, paint);

      //绘制边框
      if (style.borderSide.width > 0) {
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = style.borderSide.width;
        paint.color = style.borderSide.color;
        canvas.drawPath(path, paint);
      }
    }

    //绘制轴线
    if (axis.axisLine != null && axis.axisLine!.show) {
      paint.reset();
      axis.axisLine!.style.fillPaint(paint);
      for (int i = 0; i < axis.indicatorList.length; i++) {
        canvas.drawLine(Offset.zero, _pointList[_pointList.length - 1][i], paint);
      }
    }
  }

  void _computePointIfNeed() {
    if (!_needComputePoint && _pointList.isNotEmpty) {
      return;
    }
    int axisCount = axis.indicatorList.length;
    int splitCount = axis.splitNumber;

    _pointList.clear();
    double singleHeight = 0.5 * math.min(height, width) / splitCount;
    double singleAngle = 360 / axisCount;
    for (int i = 0; i < splitCount; i++) {
      _pointList.add([]);
    }
    for (int i = 0; i < axisCount; i++) {
      double angle = axis.offsetAngle - 90 + i * singleAngle;
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
  final RadarAxis axis;
  final RadarData data;
  final List<double> maxDataList;
  final List<double> minDataList;
  final int axisCount;
  final double offsetAngle;
  final List<Offset> _pointList = []; //存储坐标点

  RadarChildView(
    this.axis,
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
    _pointList.clear();
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
        double length = percent * radius;
        double x = length * math.cos(radians);
        double y = length * math.sin(radians);
        offset = Offset(x + centerX, y + centerY);
      }
      _pointList.add(offset);
    }

    if (data.areaStyle != null && _pointList.length >= 3) {
      Path path = Path();
      path.moveTo(_pointList[0].dx, _pointList[0].dy);
      for (Offset offset in _pointList) {
        path.lineTo(offset.dx, offset.dy);
      }
      path.close();
      AreaView areaView = AreaView(path, data.areaStyle!);
      areaView.onMeasure(width, height);
      areaView.onLayout(0, 0, width, height);
      addView(areaView);
    }

    if (data.lineStyle != null) {
      LineView lineView = LineView(
        _pointList,
        data.lineStyle!,
        paint: paint,
        close: true,
        symbolStyle: data.symbolStyle,
        showSymbol: data.symbolStyle != null,
      );
      lineView.onMeasure(width, height);
      lineView.onLayout(0, 0, width, height);
      addView(lineView);
    }
  }
}
