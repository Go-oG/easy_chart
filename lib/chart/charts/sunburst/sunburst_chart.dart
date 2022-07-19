import 'dart:math';
import 'package:easy_chart/chart/component/views/arc_view.dart';
import 'package:easy_chart/chart/core/chart_view.dart';
import 'package:easy_chart/chart/options/string_number.dart';
import 'package:flutter/material.dart';

import 'sunburst_series.dart';

// 旭日图
class SunburstChartView extends ViewGroup {
  final SunburstSeries series;
  double maxData = 0;
  double minData = 0;
  double allData = 0;
  double radiusDiff = 0; //半径差值
  int level = 0; //记录层级

  SunburstChartView(this.series) {
    // 找到树的深度
    List<SunburstData> list = List.from(series.dataList);
    int level = 0;
    while (list.isNotEmpty) {
      level += 1;
      List<SunburstData> tmpList = List.from(list);
      list.clear();
      for (var element in tmpList) {
        if (element.childrenList != null && element.childrenList!.isNotEmpty) {
          list.addAll(element.childrenList!);
        }
      }
    }
    this.level = level;
    for (var element in series.dataList) {
      if (element.data > maxData) {
        maxData = element.data;
      }
      if (element.data < minData) {
        minData = element.data;
      }
      allData += element.data;
      SunburstParentView parentView = SunburstParentView(element, gapAngle: series.gapAngle);
      addView(parentView);
    }
  }

  @override
  @mustCallSuper
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    if (children.length != series.dataList.length) {
      throw FlutterError('状态异常');
    }
    List<SNumber> centerOffset = series.center;
    double cx = centerOffset[0].convert(width);
    double cy = centerOffset[1].convert(height);
    double maxRadius = 0.5 * min(series.outerRadius.convert(width), series.outerRadius.convert(height));

    radiusDiff = maxRadius / level;

    double size = series.innerRadius.convert(maxRadius);
    SNumber rootRadius = SNumber(size, false);
    int count = series.dataList.length;
    double gapAllAngle = count * series.gapAngle;
    double remainAngle = 360 - gapAllAngle;
    double all = 0;
    for (var element in series.dataList) {
      all += element.data;
    }

    double startAngle = series.gapAngle;
    int i = 0;
    for (var element in children) {
      element.layout(cx - maxRadius, cy - maxRadius, cx + maxRadius, cy + maxRadius);
      SunburstParentView view = element as SunburstParentView;
      view.radiusDiff = radiusDiff;
      view.innerRadius = rootRadius;

      SunburstData data = series.dataList[i];
      double sweepAngle = remainAngle * data.data / all;
      SunburstParentView arcView = getView(i) as SunburstParentView;
      arcView.startAngle = startAngle;
      arcView.sweepAngle = sweepAngle;
      startAngle += sweepAngle + series.gapAngle;
      i++;
    }
  }
}

class SunburstParentView extends ViewGroup {
  final SunburstData data;
  final double gapAngle;
  SNumber innerRadius; //是一个确定的数值
  double startAngle;
  double sweepAngle;
  double radiusDiff;

  final List<SunburstParentView> _viewList = [];
  late ArcView arcView;

  SunburstParentView(
    this.data, {
    this.innerRadius = const SNumber.percent(0),
    this.gapAngle = 0,
    this.startAngle = 0,
    this.sweepAngle = 0,
    this.radiusDiff = 0,
    super.paint,
    super.zIndex,
  }) {
    data.childrenList?.forEach((element) {
      SunburstParentView view = SunburstParentView(
        element,
        paint: paint,
        zIndex: zIndex,
        gapAngle: gapAngle,
        radiusDiff: radiusDiff,
      );
      addView(view);
      _viewList.add(view);
    });

    arcView = ArcView();
    addView(arcView);
  }

  @override
  @mustCallSuper
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    //设置自身圆弧的位置
    arcView.innerRadius = innerRadius;
    arcView.outerRadius = SNumber(innerRadius.number + radiusDiff, false);
    arcView.startAngle = startAngle;
    arcView.sweepAngle = sweepAngle;

    print(arcView.toString());

    // //计算底层圆弧的位置
    // double all = 0;
    // for (var element in _viewList) {
    //   all += element.data.data;
    // }
    //
    // double angleOffset = startAngle;
    // SNumber outerRadius = SNumber(innerRadius.number + radiusDiff, false);
    // for (var element in _viewList) {
    //   element.onLayout(0, 0, width, height);
    //   double percent = element.data.data / all;
    //   double childSweepAngle = sweepAngle * percent;
    //   element.startAngle = angleOffset;
    //   element.sweepAngle = childSweepAngle;
    //   element.innerRadius = outerRadius;
    //   angleOffset += childSweepAngle;
    //   angleOffset += gapAngle;
    // }
  }

  @override
  String toString() {
    return "Bound$boundRect IR:$innerRadius RD:$radiusDiff SA:${startAngle.toInt()} SA2:${sweepAngle.toInt()}";
  }
}
