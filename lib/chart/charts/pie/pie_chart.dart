import 'dart:math';

import 'package:easy_chart/chart/charts/pie/pie_series.dart';
import 'package:easy_chart/chart/component/views/arc_view.dart';
import 'package:easy_chart/chart/core/chart_view.dart';
import 'package:easy_chart/chart/options/string_number.dart';
import 'package:flutter/material.dart';

class PieChartView extends ViewGroup {
  final PieSeries series;
  double maxData = 0;
  double minData = 0;
  double allData = 0;

  PieChartView(this.series) {
    for (var element in series.dataList) {
      if (element.data > maxData) {
        maxData = element.data;
      }
      if (element.data < minData) {
        minData = element.data;
      }
      allData += element.data;
      ArcView arcView = ArcView(
        shader: element.shader,
        fill: element.fill,
        color: element.style.color,
        border: element.style.borderSide,
        corner: series.corner,
      );
      addView(arcView);
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
    for (var element in children) {
      element.layout(cx - maxRadius, cy - maxRadius, cx + maxRadius, cy + maxRadius);
    }
  }

  @override
  void draw(Canvas canvas, double animatorPercent) {
    if (series.roseType == RoseType.normal) {
      _drawForNormal(animatorPercent);
    } else {
      _drawForNightingale(animatorPercent);
    }
    super.draw(canvas, animatorPercent);
  }

  //普通饼图
  void _drawForNormal(double animatorPercent) {
    int count = series.dataList.length;
    double gapAllAngle = count * series.gapAngle;
    double remainAngle = 360 - gapAllAngle;
    double startAngle = series.gapAngle;
    SNumber innerRadius = const SNumber(0, false);
    SNumber outerRadius = series.outerRadius;
    if (series.animatorStyle == PieAnimatorStyle.expandScale || series.animatorStyle == PieAnimatorStyle.originExpandScale) {
      outerRadius = SNumber(series.outerRadius.number * animatorPercent, series.outerRadius.percent);
    }

    for (int i = 0; i < series.dataList.length; i++) {
      PieData pieData = series.dataList[i];
      double sweepAngle = remainAngle * pieData.data / allData;
      ArcView arcView = getChildAt(i) as ArcView;
      arcView.innerRadius = innerRadius;
      arcView.outerRadius = outerRadius;
      arcView.offsetAngle = series.offsetAngle;
      arcView.startAngle = startAngle;
      arcView.sweepAngle = sweepAngle * animatorPercent;
      if (series.animatorStyle == PieAnimatorStyle.expand || series.animatorStyle == PieAnimatorStyle.expandScale) {
        startAngle += arcView.sweepAngle + series.gapAngle;
      } else {
        startAngle += sweepAngle + series.gapAngle;
      }
    }
  }

  // 南丁格尔玫瑰图
  void _drawForNightingale(double animatorPercent) {
    int count = series.dataList.length;
    double gapAllAngle = count * series.gapAngle;
    double remainAngle = 360 - gapAllAngle;
    if (series.roseType == RoseType.area) {
      double itemAngle = remainAngle / count;
      double startAngle = series.gapAngle;
      for (int i = 0; i < series.dataList.length; i++) {
        PieData pieData = series.dataList[i];
        double percent = pieData.data / maxData;
        ArcView arcView = getChildAt(i) as ArcView;
        arcView.innerRadius = series.innerRadius;
        if (series.animatorStyle == PieAnimatorStyle.expandScale || series.animatorStyle == PieAnimatorStyle.originExpandScale) {
          arcView.outerRadius = SNumber(series.outerRadius.number * percent * animatorPercent, series.outerRadius.percent);
        } else {
          arcView.outerRadius = SNumber(series.outerRadius.number * percent, series.outerRadius.percent);
        }
        arcView.offsetAngle = series.offsetAngle;
        arcView.startAngle = startAngle;
        arcView.sweepAngle = itemAngle * animatorPercent;
        if (series.animatorStyle == PieAnimatorStyle.expand || series.animatorStyle == PieAnimatorStyle.expandScale) {
          startAngle += arcView.sweepAngle + series.gapAngle;
        } else {
          startAngle += itemAngle + series.gapAngle;
        }
      }
    } else {
      double all = 0;
      for (var element in series.dataList) {
        all += element.data;
      }
      double startAngle = series.gapAngle;
      for (int i = 0; i < series.dataList.length; i++) {
        PieData pieData = series.dataList[i];
        double sweepAngle = remainAngle * pieData.data / all;
        double percent = pieData.data / maxData;
        ArcView arcView = getChildAt(i) as ArcView;
        arcView.innerRadius = series.innerRadius;
        if (series.animatorStyle == PieAnimatorStyle.expandScale || series.animatorStyle == PieAnimatorStyle.originExpandScale) {
          arcView.outerRadius = SNumber(series.outerRadius.number * percent * animatorPercent, series.outerRadius.percent);
        } else {
          arcView.outerRadius = SNumber(series.outerRadius.number * percent, series.outerRadius.percent);
        }
        arcView.offsetAngle = series.offsetAngle;
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
}
