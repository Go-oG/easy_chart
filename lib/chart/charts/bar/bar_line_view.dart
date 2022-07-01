import 'dart:math';

import 'package:easy_chart/chart/canvas/chart_canvas.dart';
import 'package:easy_chart/chart/canvas/line_canvas.dart';
import 'package:easy_chart/chart/canvas/rect_canvas.dart';
import 'package:easy_chart/chart/charts/bar/bar_data.dart';
import 'package:easy_chart/chart/core/chart_view.dart';
import 'package:easy_chart/chart/core/data_group.dart';
import 'package:easy_chart/chart/options/axis.dart';
import 'package:easy_chart/chart/options/string_number.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:flutter/material.dart';

class BarLineChartView extends View {
  //给定数据使用的坐标轴
  final XAxis xAxis;
  final YAxis yAxis;
  final List<BarGroup> dataList;
  double scaleFactory = 1; //缩放系数
  Offset scrollOffset = Offset.zero; // 平移偏移量
  bool needDrawFlag = true;
  List<ChartCanvas> canvasList = [];

  BarLineChartView(this.xAxis, this.yAxis, this.dataList);

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);

    if (xAxis.dataType == AxisDataType.category) {
      canvasList = _layoutForCategory();
    } else {
      _layoutForValue();
    }
  }

  @override
  void onDraw(Canvas canvas, double animatorPercent) {
    if (!needDrawFlag) {
      return;
    }
    for (var element in canvasList) {
      element.onDraw(canvas, animatorPercent);
    }
  }

  List<ChartCanvas> _layoutForCategory() {
    List<ChartCanvas> list = [];
    int dataLength = xAxis.data.length;
    if (dataLength <= 0) {
      dataLength = _findMaxDataLength();
    }

    if (dataLength <= 0) {
      needDrawFlag = false;
      return list;
    }

    needDrawFlag = true;

    double itemWidth = boundRect.width / dataLength;

    double? maxData;
    double? minData;
    for (var element in dataList) {
      for (var element2 in element.dataList) {
        if (element2 != null) {
          if (maxData == null) {
            maxData = element2.y;
          } else if (element2.y > maxData) {
            maxData = element2.y;
          }

          if (minData == null) {
            minData = element2.y;
          } else if (element2.y < minData) {
            minData = element2.y;
          }
        }
      }
    }
    maxData ??= 1;
    minData ??= 0;
    if (maxData < minData) {
      double a = maxData;
      maxData = minData;
      minData = a;
    }

    List<BarGroup> barList = [];
    List<BarGroup> lineList = [];
    for (var element in dataList) {
      if (element.type == ChartType.bar) {
        barList.add(element);
      } else if (element.type == ChartType.line) {
        lineList.add(element);
      } else {
        throw FlutterError('only support Line and Bar');
      }
    }

    //处理Bar
    if (barList.isNotEmpty) {
      list.addAll(_layoutForCategoryBar(barList, itemWidth, dataLength, maxData));
    }

    // 处理线
    if (lineList.isNotEmpty) {
      for (var element in lineList) {
        double offset = 0;

        List<Point> pl = [];
        for (var e2 in element.dataList) {
          if (e2 == null) {
            offset += itemWidth;
            continue;
          }
          double height = boundRect.height * e2.y / maxData;
          double x = offset + itemWidth / 2;
          double y = boundRect.bottom - height;
          pl.add(Point(x, y));
          offset += itemWidth;
        }
        LineStyle style = element.lineStyle;
        LineCanvas lineCanvas = LineCanvas(pl, lineWidth: style.width, color: style.color, shadow: style.shadow, gradient: style.shader);
        list.add(lineCanvas);
      }
    }

    return list;
  }

  // 给定一个数据列和总宽度计算出bar对应的宽度
  List<double> _computeItemWidth(List<BarGroup> list, double width) {
    List<double> widthList = [];
    //先将具体的数值转为百分比后再计算
    double allWidth = 0;
    for (var element in list) {
      double itemWidth = width / list.length;
      SNumber? tmp = element.barWidth;
      if (tmp != null) {
        double min = tmp.convert(width);
        if (itemWidth < min) {
          itemWidth = min;
        }
      }
      tmp = element.barMaxWidth;
      if (tmp != null) {
        double max = tmp.convert(width);
        if (itemWidth > max) {
          itemWidth = max;
        }
      }
      widthList.add(itemWidth);
      allWidth += itemWidth;
    }
    allWidth += (width / list.length) * (list.length - 1);
    if (allWidth > width) {
      double percent = width / allWidth;
      List<double> lis = List.from(widthList.map((e) => e * percent));
      widthList = lis;
    }
    return widthList;
  }

  List<ChartCanvas> _layoutForCategoryBar(List<BarGroup> barList, double itemWidth, int dataLength, double maxData) {
    List<ChartCanvas> canvasList = [];
    List<double> widthList = _computeItemWidth(barList, itemWidth);

    if (widthList.length != barList.length) {
      throw FlutterError('状态计算异常 barList Length=${barList.length} widthList Length:${widthList.length}');
    }
    double allWidth = 0;
    double gap = barList.first.barGap.convert(widthList.first);

    for (var element in widthList) {
      allWidth += element;
    }
    allWidth += (gap * (barList.length - 1));

    for (int j = 0; j < barList.length; j++) {
      List<Rect> rl = [];
      BarGroup data = barList[j];
      ItemStyle style = data.itemStyle!;

      double tmpOffset = 0;
      for (int k = 0; k < j; k++) {
        tmpOffset += widthList[k];
      }
      tmpOffset += (j * gap) + ((itemWidth - allWidth) / 2.0);

      for (int i = 0; i < dataLength; i++) {
        if (data.dataList.length <= i) {
          continue;
        }
        double offset = i * itemWidth + tmpOffset;
        DataPoint? point = data.dataList[i];
        if (point != null) {
          double height = boundRect.height * point.y / maxData;
          Rect rect = Rect.fromLTRB(offset, boundRect.height - height, offset + widthList[j], boundRect.height);
          rl.add(rect);
        }
      }
      canvasList.add(RectCanvas(rl, color: style.color, shader: style.shader, fill: true));
    }
    return canvasList;
  }

  void _layoutForValue() {}

  //找到最大的数据长度
  int _findMaxDataLength() {
    int dataLength = 0;
    for (var element in dataList) {
      if (element.dataList.length > dataLength) {
        dataLength = element.dataList.length;
      }
    }
    return dataLength;
  }

  // 找到所有给定数据中最大和最小的
  List<double> _findMaxMinData() {
    double? maxData;
    double? minData;
    for (var element in dataList) {
      for (var element2 in element.dataList) {
        if (element2 != null) {
          if (maxData == null) {
            maxData = element2.y;
          } else if (element2.y > maxData) {
            maxData = element2.y;
          }

          if (minData == null) {
            minData = element2.y;
          } else if (element2.y < minData) {
            minData = element2.y;
          }
        }
      }
    }

    maxData ??= 1;
    minData ??= 0;
    if (maxData < minData) {
      double a = maxData;
      maxData = minData;
      minData = a;
    }
    return [minData, maxData];
  }
}
