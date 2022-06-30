import 'package:easy_chart/chart/core/data_group.dart';
import 'package:easy_chart/chart/functions.dart';
import 'package:easy_chart/chart/options/axis.dart';
import 'package:easy_chart/chart/options/axis_line.dart';
import 'package:flutter/material.dart';

import 'base_axis_view.dart';

/// X 轴
class XAxisView<D extends DataGroup> extends BaseAxisView<XAxis, D> {
  XAxisView(super.axis, super.dataGroupList);

  @override
  bool get hasBounds => axis.show;

  @override
  AxisType getType() => AxisType.normal;

  @override
  void onMeasure(double parentWidth, double parentHeight) {
    if (!axis.show) {
      super.onMeasure(0, 0);
      return;
    }

    D data = dataGroupList.firstWhere((element) => element.xAxisId == axis.id);
    String s = findMaxLengthLabel(data.dataList, formatter: axis.axisLabel.formatter);
    double textHeight = 0;
    if (s.isNotEmpty) {
      TextPainter painter = axis.axisLabel.toTextPainter(s);
      painter.layout(minWidth: 0, maxWidth: parentWidth);
      textHeight = painter.height;
    }
    double axisHeight = computeAxisHeight(axis, textHeight);
    super.onMeasure(parentWidth, axisHeight);
  }

  @override
  void onDraw(Canvas canvas, double animatorPercent) {
    super.onDraw(canvas, animatorPercent);
    _drawAxisLine(canvas);
  }

  void _drawAxisLine(Canvas canvas) {
    if (!axis.axisLine.show) {
      return;
    }
    AxisLine axisLine = axis.axisLine;
    Paint paint;
    if (axisLine.style.shadow != null) {
      BoxShadow shadow = axisLine.style.shadow!;
      paint = shadow.toPaint();
    } else {
      paint = Paint();
      axisLine.fillPaint(paint);
    }

    //这里是为了修正相交时的空隙
    paint.strokeCap = StrokeCap.square;

    Path path = Path();
    double paintWidth = axisLine.style.width / 2;
    path.moveTo(0, paintWidth);
    path.lineTo(width, paintWidth);

    if (axisLine.style.shadow != null) {
      BoxShadow shadow = axisLine.style.shadow!;
      paint.color = shadow.color;
    }
    if (axisLine.style.dash.isNotEmpty) {
      path = axisLine.style.getPath(path);
    }
    paint.style = PaintingStyle.stroke; // 对于线段只能是 stroke
    canvas.drawPath(path, paint);
  }

  double computeAxisHeight(XAxis axis, double maxLabelHeight) {
    double tickWidth = computeAxisTickMaxLength(axis);
    return maxLabelHeight + tickWidth + axis.axisLabel.margin + axis.axisLine.style.width;
  }

  double computeAxisTickMaxLength(XAxis axis) {
    double tickWidth = 0;
    if (axis.axisTick.show && axis.axisTick.length > tickWidth) {
      tickWidth = axis.axisTick.length;
    }
    if (axis.minorTick.show && axis.minorTick.length > tickWidth) {
      tickWidth = axis.minorTick.length;
    }
    return tickWidth;
  }

  // 找到给定数据转为String后最长的字符串
  String findMaxLengthLabel(List<DataPoint?>? list, {NumberFormatter? formatter}) {
    if (list == null || list.isEmpty) {
      return '';
    }
    String s = '';
    for (var element in list) {
      if (element == null) {
        continue;
      }
      double data = element.x;
      String? label = element.label?.formatter?.call(element.x, 0);
      String tmp = data.toString();

      if (label != null && label.isNotEmpty) {
        tmp = label;
      }
      if (formatter != null) {
        String s2 = formatter.call(data, 0);
        if (s2.isNotEmpty) {
          tmp = s2;
        }
      }
      if (tmp.length > s.length) {
        s = tmp;
      }
    }
    return s;
  }

  void _computeXAxisItemWidth(D data, XAxis xAxis) {
    if (xAxis.dataType == AxisDataType.category) {
      _computeItemWidthAndGapForCategory(data, xAxis);
      return;
    }
    int count = data.dataList.length;
    double viewWidth = areaBounds.width;
  }

  void _computeYAxisItemHeight(D data, XAxis xAxis) {}

  //类目轴
  List<double> _computeItemWidthAndGapForCategory(D data, XAxis xAxis) {
    int count = data.dataList.length;
    double viewWidth = areaBounds.width;
    double? tmp = _tryGetItemWidth(xAxis);
    double viewGap = 0;
    if (tmp != null) {
      double allWidth;
      double gap = 0;
      if (xAxis.itemGap.percent) {
        gap = tmp * xAxis.itemGap.percentRatio();
        allWidth = count * (tmp * (1 + 2 * xAxis.itemGap.percentRatio()));
      } else {
        allWidth = count * (tmp + 2 * xAxis.itemGap.number);
        gap = xAxis.itemGap.number;
      }
      if (allWidth <= viewWidth) {
        return [allWidth / count, gap];
      }
    }
    double itemWidth = viewWidth / count;
    tmp = 0;
    if (xAxis.width != null) {
      if (xAxis.width!.percent) {
        tmp = itemWidth * xAxis.width!.percentRatio();
      } else {
        tmp = xAxis.width!.number;
      }
    }
    if (xAxis.minWidth != null) {
      double min;
      if (xAxis.minWidth!.percent) {
        min = itemWidth * xAxis.minWidth!.percentRatio();
      } else {
        min = xAxis.minWidth!.number;
      }
      if (tmp < min) {
        tmp = min;
      }
    }
    if (xAxis.maxWidth != null) {
      double max;
      if (xAxis.maxWidth!.percent) {
        max = itemWidth * xAxis.maxWidth!.percentRatio();
      } else {
        max = xAxis.maxWidth!.number;
      }
      if (tmp > max) {
        tmp = max;
      }
    }
    viewGap = 0;
    if (xAxis.itemGap.percent) {
      viewGap = xAxis.itemGap.percentRatio() * tmp;
      itemWidth = itemWidth - 2 * viewGap;
    } else {
      viewGap = xAxis.itemGap.number;
      if (viewGap > tmp * 0.4) {
        viewGap = tmp * 0.4;
      }
      itemWidth = itemWidth - 2 * viewGap;
    }
    if (itemWidth < 2) {
      itemWidth = 2;
      if (xAxis.itemGap.percent) {
        viewGap = xAxis.itemGap.percentRatio() * itemWidth;
      } else {
        viewGap = xAxis.itemGap.number;
      }
    }
    return [itemWidth, viewGap];
  }

  double? _tryGetItemWidth(XAxis axis) {
    double? tmp;
    if (axis.width != null) {
      if (!axis.width!.percent) {
        tmp = axis.width!.number;
      }
    }
    if (axis.maxWidth != null) {
      if (!axis.maxWidth!.percent) {
        tmp = axis.maxWidth!.number;
      }
      if (axis.minWidth != null && !axis.minWidth!.percent) {
        tmp = axis.minWidth!.number;
      }
    } else {
      if (axis.minWidth != null) {
        if (!axis.minWidth!.percent) {
          tmp = axis.minWidth!.number;
        }
      }
    }
    return tmp;
  }

  // 数值轴
  List<double> _computeItemWidthAndGapForValue(D data, XAxis xAxis) {
    double max = double.negativeInfinity;
    for (var element in data.dataList) {
      if (element == null) {
        continue;
      }
      if (element.x > max) {
        max = element.x;
      }
    }
    double start = 0;
    if (max < start) {
      double a = start;
      start = max;
      max = a;
    }

    return [];
  }

  // 时间轴
  List<double> _computeItemWidthAndGapForTime(D data, XAxis xAxis) {
    return [];
  }

  // log 对数轴
  List<double> _computeItemWidthAndGapForLog(D data, XAxis xAxis) {
    return [];
  }
}

/// Y 轴
class YAxisView<D extends DataGroup> extends BaseAxisView<YAxis, D> {
  YAxisView(super.axis, super.dataGroupList);

  @override
  AxisType getType() => AxisType.normal;

  @override
  bool get hasBounds => axis.show;

  @override
  void onMeasure(double parentWidth, double parentHeight) {
    if (!axis.show) {
      super.onMeasure(0, 0);
      return;
    }
    D data = dataGroupList.firstWhere((element) => element.yAxisId == axis.id);
    String s = findMaxLengthLabel(data.dataList, formatter: axis.axisLabel.formatter);
    double textWidth = 0;
    if (s.isNotEmpty) {
      TextPainter painter = axis.axisLabel.toTextPainter(s);
      painter.layout(minWidth: 0, maxWidth: parentWidth);
      textWidth = painter.width;
    }
    double axisWidth = computeAxisWidth(axis, textWidth);
    super.onMeasure(axisWidth, parentHeight);
  }

  @override
  void onDraw(Canvas canvas, double animatorPercent) {
    super.onDraw(canvas, animatorPercent);
    _drawAxisLine(canvas);
  }

  void _drawAxisLine(Canvas canvas) {
    if (!axis.axisLine.show) {
      return;
    }
    AxisLine axisLine = axis.axisLine;
    Paint paint;
    if (axisLine.style.shadow != null) {
      BoxShadow shadow = axisLine.style.shadow!;
      paint = shadow.toPaint();
    } else {
      paint = Paint();
      axisLine.fillPaint(paint);
    }

    //这里是为了修正相交时的空隙
    paint.strokeCap = StrokeCap.square;
    Path path = Path();
    path.moveTo(width, 0);
    path.lineTo(width, height);

    if (axisLine.style.shadow != null) {
      BoxShadow shadow = axisLine.style.shadow!;
      paint.color = shadow.color;
    }
    if (axisLine.style.dash.isNotEmpty) {
      path = axisLine.style.getPath(path);
    }
    paint.style = PaintingStyle.stroke; // 对于线段只能是 stroke
    canvas.drawPath(path, paint);
  }

  double computeAxisWidth(YAxis axis, double maxLabelWidth) {
    double tickWidth = computeAxisTickMaxLength(axis);
    return maxLabelWidth + tickWidth + axis.axisLabel.margin + axis.axisLine.style.width;
  }

  double computeAxisTickMaxLength(YAxis axis) {
    double tickWidth = 0;
    if (axis.axisTick.show && axis.axisTick.length > tickWidth) {
      tickWidth = axis.axisTick.length;
    }
    if (axis.minorTick.show && axis.minorTick.length > tickWidth) {
      tickWidth = axis.minorTick.length;
    }
    return tickWidth;
  }

  // 找到给定数据转为String后最长的字符串
  String findMaxLengthLabel(List<DataPoint?>? list, {NumberFormatter? formatter}) {
    if (list == null || list.isEmpty) {
      return '';
    }
    String s = '';
    for (var element in list) {
      if (element == null) {
        continue;
      }
      double data = element.x;
      String? label = element.label?.formatter?.call(element.x, 0);
      String tmp = data.toString();

      if (label != null && label.isNotEmpty) {
        tmp = label;
      }
      if (formatter != null) {
        String s2 = formatter.call(data, 0);
        if (s2.isNotEmpty) {
          tmp = s2;
        }
      }
      if (tmp.length > s.length) {
        s = tmp;
      }
    }
    return s;
  }
}
