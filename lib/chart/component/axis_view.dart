import 'package:easy_chart/chart/core/data_group.dart';
import 'package:easy_chart/chart/functions.dart';
import 'package:easy_chart/chart/options/axis_line.dart';
import 'package:easy_chart/chart/options/base_config.dart';
import 'package:easy_chart/chart/options/axis.dart' as chart;
import 'package:easy_chart/chart/options/style.dart';
import 'package:flutter/material.dart';

class AxisView {
  BaseConfig config;
  late List<DataGroup> dataGroupList; // 存放全部的数据

  AxisView(this.config) {
    //校验坐标轴ID是否唯一
    checkAxisIdUnique();
  }

  Size windowSize = Size.zero;
  Rect chartBoundRect = Rect.zero;

  ///这两个不会影响坐标轴线的绘制，只会影响相关的Tick和MinorTick以及显示的区域数据
  double scaleRatio = 1; //缩放因子
  Offset scrollOffset = Offset.zero; // 滚动的偏移量

  Map<String, Rect> axisSizeMap = {}; //存储每个坐标轴的位置

  // 存储x轴和y轴占用的各方向大小
  late List<double> xAxisAreaSize;
  late List<double> yAxisAreaSize;
  bool layoutFlag = false;

  //必须先调用 layout 然后再调用drawAxis;
  void layout(Size size, double newScaleRatio, Offset newScrollOffset, List<DataGroup> dataGroupList) {
    layoutFlag = true;
    this.dataGroupList = dataGroupList;
    windowSize = Size.copy(size);
    scaleRatio = newScaleRatio;
    scrollOffset = newScrollOffset;

    //布局计算开始
    Map<String, double> sizeMap = computeAxisSingleSize();
    List<chart.Axis> xAxis = getCanUseXAxis();
    List<chart.Axis> yAxis = getCanUseYAxis();

    //计算所有的X轴累加高度
    xAxisAreaSize = computeAxisXBounds(xAxis, sizeMap);
    yAxisAreaSize = computeAxisYBounds(yAxis, sizeMap);

    //计算累计位置
    axisSizeMap.clear();
    axisSizeMap.addAll(computeAxisXPosition(xAxis, sizeMap, yAxisAreaSize[1], yAxisAreaSize[2]));
    axisSizeMap.addAll(computeAxisYPosition(yAxis, sizeMap, xAxisAreaSize[1], xAxisAreaSize[2]));

    //计算图表区的React区域
    double left = yAxisAreaSize[1] + 1;
    double top = xAxisAreaSize[1] - 1;
    double right = size.width - yAxisAreaSize[2] + 1;
    double bottom = size.height - xAxisAreaSize[2] + 1;
    chartBoundRect = Rect.fromLTRB(left, top, right, bottom);
  }

  // 开始绘制
  void drawAxis(Canvas canvas) {
    if (!layoutFlag) {
      throw Exception('you must first call layout');
    }
    //测试代码
    Paint paint = Paint();
    paint.color = Colors.blue;
    paint.style = PaintingStyle.fill;
    paint.strokeWidth = 5;
    canvas.drawCircle(Offset(windowSize.width / 2, windowSize.height / 2), 30, paint);

    List<chart.Axis> xAxis = getCanUseXAxis();
    List<chart.Axis> yAxis = getCanUseYAxis();

    for (var element in yAxis) {
      Rect rect = axisSizeMap[element.id]!;
      _drawAxisLine(canvas, true, element, rect);
    }

    for (var element in xAxis) {
      Rect rect = axisSizeMap[element.id]!;
      _drawAxisLine(canvas, false, element, rect);
    }
  }

  void _drawAxisLine(Canvas canvas, bool yAxis, chart.Axis axis, Rect rect) {
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
    double x1 = yAxis ? rect.right : rect.left;
    double y1 = yAxis ? rect.top : rect.top;

    double x2 = yAxis ? rect.right : rect.right;
    double y2 = yAxis ? rect.bottom : rect.top;

    path.moveTo(x1, y1);
    path.lineTo(x2, y2);

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

  void _drawAxisTick(Canvas canvas, bool yAxis, chart.Axis axis, Rect rect, List<String> tickLabel) {
    if (!axis.axisTick.show) {
      return;
    }
  }

  void _drawAxisMinorTick(Canvas canvas, bool yAxis, chart.Axis axis, Rect rect, List<String> tickLabel) {
    if (!axis.minorTick.show) {
      return;
    }
  }

  void _drawXAxisLine(List<chart.Axis> list) {}

  // 检查坐标轴的ID
  void checkAxisIdUnique() {
    Set<String> idSet = <String>{};
    for (var element in config.xAxis) {
      if (idSet.contains(element.id)) {
        throw Exception("坐标轴的ID应全局唯一");
      }
      idSet.add(element.id);
    }

    for (var element in config.yAxis) {
      if (idSet.contains(element.id)) {
        throw Exception("坐标轴的ID应全局唯一");
      }
      idSet.add(element.id);
    }
  }

  //计算每个Axis的单独大小
  Map<String, double> computeAxisSingleSize() {
    Map<String, double> axisSizeMap = {};
    Map<String, DataGroup> yAxisMap = {};
    Map<String, DataGroup> xAxisMap = {};
    for (var element in dataGroupList) {
      yAxisMap[element.yAxisId] = element;
      xAxisMap[element.xAxisId] = element;
    }
    for (var element in config.xAxis) {
      if (!element.show) {
        axisSizeMap[element.id] = 0;
        continue;
      }
      if (element.width != null && element.width! > 0) {
        axisSizeMap[element.id] = element.width!;
        continue;
      }
      DataGroup? group = xAxisMap[element.id];
      String s = findMaxLengthLabel(group?.dataList, false, formatter: element.axisLabel.label.formatter);
      Size textSize = computeTextSize(s, element.axisLabel.label.textStyle, windowSize.width);
      axisSizeMap[element.id] = computeAxisWidth(element, false, textSize);
    }

    for (var element in config.yAxis) {
      if (!element.show) {
        axisSizeMap[element.id] = 0;
        continue;
      }
      if (element.width != null && element.width! > 0) {
        axisSizeMap[element.id] = element.width!;
        continue;
      }
      DataGroup? group = yAxisMap[element.id];
      String s = findMaxLengthLabel(group?.dataList, true, formatter: element.axisLabel.label.formatter);
      Size textSize = computeTextSize(s, element.axisLabel.label.textStyle, windowSize.height);
      axisSizeMap[element.id] = computeAxisWidth(element, true, textSize);
    }
    return axisSizeMap;
  }

  Map<String, Rect> computeAxisYPosition(
    List<chart.Axis> axisList,
    Map<String, double> sizeMap,
    double top,
    double bottom,
  ) {
    double height = windowSize.height - bottom - top;
    Map<String, Rect> map = {};

    //先计算左边的
    double left = 0;
    for (var axis in axisList) {
      if (axis.position != Position.left) {
        continue;
      }
      double width = sizeMap[axis.id]!;
      left += axis.offset;
      Rect rect = Rect.fromLTWH(left, top, width, height);
      map[axis.id] = rect;
      left += width;
    }
    // 再计算右边的
    List<chart.Axis> rightAxis = [];
    for (var axis in axisList) {
      if (axis.position == Position.right) {
        rightAxis.add(axis);
      }
    }

    double right = windowSize.width;
    for (var axis in rightAxis.reversed) {
      double width = sizeMap[axis.id]!;
      Rect rect = Rect.fromLTRB(right - width, top, right, height);
      map[axis.id] = rect;
      right -= axis.offset;
      right -= width;
    }
    return map;
  }

  Map<String, Rect> computeAxisXPosition(
    List<chart.Axis> axisList,
    Map<String, double> sizeMap,
    double left,
    double right,
  ) {
    double width = windowSize.width - right - left;

    Map<String, Rect> map = {};
    double top = 0;
    for (var axis in axisList) {
      if (axis.position == Position.bottom) {
        continue;
      }
      double height = sizeMap[axis.id]!;
      top += axis.offset;
      Rect rect = Rect.fromLTWH(left, top, width, height);
      map[axis.id] = rect;
      top += height;
    }

    // 再计算下边的
    List<chart.Axis> rightAxis = [];
    for (var axis in axisList) {
      if (axis.position == Position.bottom) {
        rightAxis.add(axis);
      }
    }

    double bottom = windowSize.height;
    for (var axis in rightAxis.reversed) {
      double height = sizeMap[axis.id]!;
      Rect rect = Rect.fromLTWH(left, bottom - height, width, height);
      map[axis.id] = rect;
      bottom -= axis.offset;
      bottom -= height;
    }
    return map;
  }

  /// 计算给定X轴的位置
  /// [all,top,bottom]
  List<double> computeAxisXBounds(List<chart.Axis> axisList, Map<String, double> sizeMap) {
    double top = 0;
    double bottom = 0;
    for (var element in axisList) {
      if (element.position == Position.top) {
        top += sizeMap[element.id]! + element.offset;
      } else {
        bottom += sizeMap[element.id]! + element.offset;
      }
    }
    return [top + bottom, top, bottom];
  }

  /// 计算给定Y轴占用的总横向区域大小
  /// [all,left,right]
  List<double> computeAxisYBounds(List<chart.Axis> axisList, Map<String, double> sizeMap) {
    double left = 0;
    double right = 0;
    for (var element in axisList) {
      if (element.position == Position.right) {
        right += sizeMap[element.id]! + element.offset;
      } else {
        left += sizeMap[element.id]! + element.offset;
      }
    }
    return [left + right, left, right];
  }

  //计算一个轴的最小高度或者宽度
  // 对于X轴是高度 Y轴是宽度
  double computeAxisWidth(chart.Axis axis, bool yAxis, Size maxLabelSize) {
    if (axis.width != null && axis.width! > 0) {
      return axis.width!;
    }
    double tickWidth = computeAxisTickMaxLength(axis);
    if (yAxis) {
      return maxLabelSize.width + tickWidth + axis.labelMargin + axis.axisLine.style.width;
    }
    return maxLabelSize.height + tickWidth + axis.labelMargin + axis.axisLine.style.width;
  }

  double computeAxisTickMaxLength(chart.Axis axis) {
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
  String findMaxLengthLabel(List<DataPoint?>? list, bool yAxis, {NumberFormatter? formatter}) {
    if (list == null || list.isEmpty) {
      return '';
    }
    String s = '';
    for (var element in list) {
      if (element == null) {
        continue;
      }
      double data = yAxis ? element.y : element.x;
      String? label = yAxis ? '' : element.label?.formatter?.call(element.x);
      String tmp = data.toString();

      if (label != null && label.isNotEmpty) {
        tmp = label;
      }
      if (formatter != null) {
        String s2 = formatter.call(data);
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

  Size computeTextSize(String text, TextStyle style, double maxWidth) {
    if (text.isEmpty) {
      return Size.zero;
    }
    TextSpan span = TextSpan(text: text, style: style);
    TextPainter painter = TextPainter(text: span, textDirection: TextDirection.ltr);
    painter.layout(minWidth: 0, maxWidth: maxWidth);
    return painter.size;
  }

  /// 获取可用的坐标轴数量
  List<chart.Axis> getCanUseXAxis() {
    List<chart.Axis> list = [];
    for (var element in config.xAxis) {
      if (element.show) {
        list.add(element);
      }
    }
    return list;
  }

  List<chart.Axis> getCanUseYAxis() {
    List<chart.Axis> list = [];
    for (var element in config.yAxis) {
      if (element.show) {
        list.add(element);
      }
    }
    return list;
  }
}
