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

    double radiusDiff=maxRadius/level;

    for (var element in children) {
      element.onLayout(cx - maxRadius, cy - maxRadius, cx + maxRadius, cy + maxRadius);
      SunburstParentView view=element as SunburstParentView;
      view.radiusDiff=radiusDiff;

    }
  }

  @override
  void draw(Canvas canvas, double animatorPercent) {
    _drawForNormal(animatorPercent);
    super.draw(canvas, animatorPercent);
  }

  void _drawForNormal(double animatorPercent) {
    int count = series.dataList.length;
    double gapAllAngle = count * series.gapAngle;
    double remainAngle = 360 - gapAllAngle;
    double all = 0;
    for (var element in series.dataList) {
      all += element.data;
    }

    double startAngle = series.gapAngle;
    for (int i = 0; i < series.dataList.length; i++) {
      SunburstData pieData = series.dataList[i];
      double sweepAngle = remainAngle * pieData.data / all;
      SunburstParentView arcView = getView(i) as SunburstParentView;
      arcView.innerRadius = series.innerRadius;
      arcView.startAngle = startAngle;
      arcView.sweepAngle = sweepAngle * animatorPercent;
      if (series.animatorStyle == PieAnimatorStyle.expand || series.animatorStyle == PieAnimatorStyle.expandScale) {
        startAngle += arcView.sweepAngle + series.gapAngle;
      } else {
        startAngle += sweepAngle + series.gapAngle;
      }
    }
  }

}

class SunburstParentView extends ViewGroup {
  final SunburstData data;
  final double gapAngle;
  SNumber innerRadius;
  double startAngle;
  double sweepAngle;
  double radiusDiff;

  final List<SunburstParentView> _viewList = [];
  late ArcView arcView;

  SunburstParentView(this.data, {
    this.innerRadius = const SNumber.percent(0),
    this.gapAngle = 0,
    this.startAngle = 0,
    this.sweepAngle = 0,
    this.radiusDiff = 0;
  }) {
    arcView = ArcView();
    addView(arcView);
    data.childrenList?.forEach((element) {
      SunburstParentView view = SunburstParentView(element);
      addView(view);
      _viewList.add(view);
    });
  }

  @override
  @mustCallSuper
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);

    //设置自身圆弧的位置
    arcView.innerRadius = innerRadius;
    arcView.outerRadius = outerRadius;
    arcView.startAngle = startAngle;
    arcView.sweepAngle = sweepAngle;

    //计算底层圆弧的位置
    double all = 0;
    for (var element in _viewList) {
      all += element.data.data;
    }
    double angleOffset = startAngle;
    for (var element in _viewList) {
      double percent = element.data.data / all;
      double childSweepAngle = sweepAngle * percent;
      element.startAngle = angleOffset;
      element.sweepAngle = childSweepAngle;
      element.innerRadius = outerRadius;
      //这里要优化一下
      element.outerRadius = SNumber(2 * outerRadius.number - innerRadius.number, outerRadius.percent);
      angleOffset += childSweepAngle;
      angleOffset += gapAngle;
    }
  }
}
