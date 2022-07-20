import 'dart:math';
import 'package:easy_chart/chart/core/chart_view.dart';
import 'package:easy_chart/chart/options/string_number.dart';
import 'package:easy_chart/chart/utils/paint_util.dart';
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

      SunburstNodeView nodeView = SunburstNodeView(element,
          angleGap: series.angleGap,
          radiusGap: series.radiusGap,
          radiusDiff: radiusDiff,
          adjustData: series.adjustData,
          paint: paint,
          zIndex: zIndex);
      addView(nodeView);
    }
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    if (children.length != series.dataList.length) {
      throw FlutterError('状态异常');
    }

    double radiusDiffTmp = -1;
    for (var element in series.dataList) {
      if (element.radiusDiff != null && element.radiusDiff! > 0) {
        if (element.radiusDiff! > radiusDiffTmp) {
          radiusDiffTmp = element.radiusDiff!;
        }
      }
    }

    List<SNumber> centerOffset = series.center;
    double cx = centerOffset[0].convert(width);
    double cy = centerOffset[1].convert(height);
    double maxRadius = 0.5 * min(series.outerRadius.convert(width), series.outerRadius.convert(height));
    double size = series.innerRadius.convert(maxRadius);
    radiusDiff = (maxRadius - size) / level;

    if (radiusDiffTmp > 0.01) {
      radiusDiff = radiusDiffTmp;
    }

    SNumber rootRadius = SNumber(size, false);
    int count = series.dataList.length;

    double gapAllAngle = count * series.angleGap;
    if (count <= 1) {
      gapAllAngle = 0;
    }

    double remainAngle = 360 - gapAllAngle;

    double all = 0;
    for (var element in series.dataList) {
      all += element.computeAllData(adjustData: series.adjustData);
    }
    double startAngle = 0;
    int i = 0;
    SNumber outer = SNumber(size + radiusDiff, false);
    for (var element in children) {
      SunburstNodeView view = element as SunburstNodeView;
      SunburstData data = series.dataList[i];
      view.innerRadius = rootRadius;
      view.outerRadius = outer;
      view.radiusDiff = radiusDiff;
      view.startAngle = startAngle;
      view.sweepAngle = remainAngle * data.data / all;
      element.measure(maxRadius * 2, maxRadius * 2);
      element.layout(cx - maxRadius, cy - maxRadius, cx + maxRadius, cy + maxRadius);
      startAngle += view.sweepAngle + series.angleGap;
      i++;
    }
  }
}

class SunburstNodeView extends ViewGroup {
  final SunburstData data;
  final double angleGap;
  final double radiusGap;
  final bool adjustData;
  SNumber innerRadius; //是一个确定的数值
  SNumber outerRadius; // 也是一个确定的数值
  double startAngle;
  double sweepAngle;
  double radiusDiff;
  late Path _path;

  SunburstNodeView(
    this.data, {
    this.innerRadius = const SNumber.number(0),
    this.outerRadius = const SNumber.number(0),
    this.angleGap = 0,
    this.radiusGap = 0,
    this.startAngle = 0,
    this.sweepAngle = 0,
    this.radiusDiff = 0,
    this.adjustData = true,
    super.paint,
    super.zIndex,
  }) {
    if (innerRadius.percent || outerRadius.percent) {
      throw FlutterError('不支持百分比');
    }

    data.childrenList?.forEach((element) {
      SunburstNodeView view = SunburstNodeView(
        element,
        paint: paint,
        zIndex: zIndex,
        angleGap: angleGap,
        radiusGap: radiusGap,
        radiusDiff: radiusDiff,
        adjustData: adjustData,
      );
      addView(view);
    });
  }

  @override
  @mustCallSuper
  void onLayout(double left, double top, double right, double bottom) {
    _path = _computeArcPath();
    if (data.childrenList == null || data.childrenList!.isEmpty) {
      return;
    }
    // 布局子View
    List<SunburstData> list = data.childrenList!;

    double radiusDiffTmp = -1;
    for (var element in list) {
      if (element.radiusDiff != null && element.radiusDiff! > 0) {
        if (element.radiusDiff! > radiusDiffTmp) {
          radiusDiffTmp = element.radiusDiff!;
        }
      }
    }

    if (radiusDiffTmp > 0.01) {
      radiusDiff = radiusDiffTmp;
    }

    double remainAngle = sweepAngle - (list.length - 1) * angleGap;
    double all = data.computeAllData(adjustData: adjustData);
    double angleOffset = startAngle;
    SNumber inner = SNumber(outerRadius.number + radiusGap, false);
    SNumber outer = SNumber(inner.number + radiusDiff, false);
    for (int i = 0; i < list.length; i++) {
      SunburstData sunData = list[i];
      SunburstNodeView nodeView = getChildAt(i) as SunburstNodeView;
      nodeView.innerRadius = inner;
      nodeView.outerRadius = outer;
      nodeView.radiusDiff = radiusDiff;
      nodeView.startAngle = angleOffset;
      nodeView.sweepAngle = remainAngle * sunData.data / all;
      angleOffset += nodeView.sweepAngle;
      angleOffset += angleGap;
      nodeView.measure(width, height);
      nodeView.layout(0, 0, width, height);
    }
  }

  @override
  void onDraw(Canvas canvas, double animatorPercent) {
    paint.reset();
    paint.color = data.style.color;
    if (data.shader != null) {
      paint.shader = data.shader!;
    }
    paint.style = PaintingStyle.fill;
    canvas.translate(centerX, centerY);
    canvas.drawPath(_path, paint);
    canvas.translate(-centerX, -centerY);
  }

  @override
  String toString() {
    return "Bound$boundRect IR:$innerRadius RD:$radiusDiff SA:${startAngle.toInt()} SA2:${sweepAngle.toInt()}";
  }

  // 计算路径
  Path _computeArcPath() {
    double size = min(width, height);
    double ir = innerRadius.convert(size);
    double or = outerRadius.convert(size);
    double corner = 0;
    double startAngle = this.startAngle - 90;
    double sweepAngle = this.sweepAngle;

    double ox1 = or * cos(startAngle * pi / 180);
    double oy1 = or * sin(startAngle * pi / 180);
    double ox2 = or * cos((startAngle + sweepAngle) * pi / 180);
    double oy2 = or * sin((startAngle + sweepAngle) * pi / 180);
    double iy = ir * sin(startAngle * pi / 180);
    double ix = ir * cos(startAngle * pi / 180);
    double ix2 = ir * cos((startAngle + sweepAngle) * pi / 180);
    double iy2 = ir * sin((startAngle + sweepAngle) * pi / 180);

    Path path = Path();
    if (innerRadius.number <= 0.01) {
      path.moveTo(0, 0);
      path.lineTo(ox1, oy1);
      path.arcToPoint(Offset(ox2, oy2), radius: Radius.circular(or), largeArc: false, clockwise: true);
      path.lineTo(0, 0);
      path.close();
    } else {
      path.moveTo(ix, iy);
      path.lineTo(ox1, oy1);
      path.arcToPoint(Offset(ox2, oy2), radius: Radius.circular(or), largeArc: false, clockwise: true);
      path.lineTo(ix2, iy2);
      path.arcToPoint(Offset(ix, iy), radius: Radius.circular(ir), largeArc: false, clockwise: false);
      path.close();
    }
    return path;
  }
}
