import 'package:easy_chart/chart/charts/bar/bar_data.dart';
import 'package:easy_chart/chart/charts/funnel/funnel_chart.dart';
import 'package:easy_chart/chart/charts/funnel/funnel_series.dart';
import 'package:easy_chart/chart/charts/pie/pie_chart.dart';
import 'package:easy_chart/chart/charts/pie/pie_series.dart';
import 'package:easy_chart/chart/charts/radar/radar_chart.dart';
import 'package:easy_chart/chart/charts/radar/radar_series.dart';
import 'package:easy_chart/chart/charts/sunburst/sunburst_chart.dart';
import 'package:easy_chart/chart/charts/sunburst/sunburst_series.dart';
import 'package:easy_chart/chart/component/views/line_view.dart';
import 'package:easy_chart/chart/component/views/rect_view.dart';
import 'package:easy_chart/chart/core/chart_view.dart';
import 'package:easy_chart/chart/core/data_group.dart';
import 'package:easy_chart/chart/options/axis.dart';
import 'package:easy_chart/chart/options/axis_line.dart';
import 'package:easy_chart/chart/options/label.dart';
import 'package:easy_chart/chart/options/string_number.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:flutter/material.dart';

import 'dart:math' as math;

/// 标准笛卡尔坐标系下的柱状图，适用于bar、line
class BarLineChartView extends ViewGroup {
  //给定数据使用的坐标轴
  final XAxis xAxis;
  final YAxis yAxis;
  final List<BarGroup> dataList;

  BarLineChartView(this.xAxis, this.yAxis, this.dataList, {super.paint, super.zIndex});

  @override
  void onLayout(double left, double top, double right, double bottom) {
    clearChildren();
    if (xAxis.dataType == AxisDataType.category) {
      _layoutForCategory();
    } else {
      _layoutForValue();
    }
    _testSunburst();
  }

  //TODO 测试
  void _testFunnelChart() {
    List<FunnelData> list = [];
    math.Random random = math.Random();
    for (int i = 0; i < 5; i++) {
      AreaStyle areaStyle = AreaStyle(
          color: Color.fromARGB(
        255,
        (random.nextDouble() * 255).toInt(),
        (random.nextDouble() * 255).toInt(),
        (random.nextDouble() * 255).toInt(),
      ));
      FunnelData data = FunnelData(
        random.nextDouble() * 80 + 20,
        areaStyle,
        label: const ChartLabel(show: true, align: ChartAlign.rightCenter),
      );
      list.add(data);
    }

    FunnelSeries series = FunnelSeries(list,
        gap: 0,
        direction: Direction.vertical,
        funnelAlign: Align2.center,
        sortAsc: true,
        animator: true,
        animatorDirection: AnimatorDirection.ets);
    FunnelChartView chartView = FunnelChartView(series, paint: paint, zIndex: 20);
    chartView.layout(0, 0, width, height);
    addView(chartView);
  }

  void _testRadar() {
    List<RadarIndicator> indicatorList = [];
    for (int i = 0; i < 3; i++) {
      indicatorList.add(RadarIndicator('indicator$i', 100));
    }

    RadarAxis radarAxis = RadarAxis('123', indicatorList,
        splitNumber: 3,
        radius: const SNumber.percent(100),
        axisLine: const AxisLine(
          style: LineStyle(color: Colors.black26, width: 2),
        ),
        styleList: const [
          ItemStyle(
            BoxDecoration(),
            color: Colors.blueGrey,
          ),
          ItemStyle(
            BoxDecoration(),
            color: Colors.black26,
          ),
          ItemStyle(
            BoxDecoration(),
            color: Colors.blueAccent,
          ),
        ]);

    List<RadarData> dl = [];
    for (int i = 0; i < 1; i++) {
      List<double> list = [];
      math.Random random = math.Random();
      for (int j = 0; j < 3; j++) {
        list.add(random.nextDouble() * 50);
      }

      RadarData radarData = RadarData(list,
          lineStyle: const LineStyle(color: Colors.orangeAccent, width: 2),
          symbolStyle: SymbolStyle(ChartSymbol.circle, color: Colors.lightGreen));
      dl.add(radarData);
    }
    RadarSeries series = RadarSeries(radarAxis, dl);
    RadarChartView chartView = RadarChartView(series, paint: paint);
    chartView.layout(0, 0, width, height);
    addView(chartView);
  }

  void _testPie() {
    List<PieData> list = [];
    list.add(PieData(60, const ItemStyle(BoxDecoration(), color: Colors.blueGrey)));
    list.add(PieData(30, const ItemStyle(BoxDecoration(), color: Colors.green)));
    list.add(PieData(40, const ItemStyle(BoxDecoration(), color: Colors.lime)));
    list.add(PieData(50, const ItemStyle(BoxDecoration(), color: Colors.orange)));

    PieSeries series = PieSeries(
      const [SNumber(30, true), SNumber(20, true)],
      list,
      roseType: RoseType.normal,
      corner: 2,
      animatorStyle: PieAnimatorStyle.expandScale,
    );
    PieChartView pieChartView = PieChartView(series);
    pieChartView.layout(0, 0, width, height);
    addView(pieChartView);
  }

  void _testSunburst() {
    List<SunburstData> list = [];
    math.Random random = math.Random();
    for (int i = 0; i < 4; i++) {
      Color color = Color.fromARGB(
        255,
        (random.nextDouble() * 255).toInt(),
        (random.nextDouble() * 255).toInt(),
        (random.nextDouble() * 255).toInt(),
      );
      SunburstData data = SunburstData(90, null, ItemStyle(const BoxDecoration(), color: color), childrenList: []);

      for (int j = 0; j < 3; j++) {
        Color color2 = Color.fromARGB(
          255,
          (random.nextDouble() * 255).toInt(),
          (random.nextDouble() * 255).toInt(),
          (random.nextDouble() * 255).toInt(),
        );
        SunburstData data2 = SunburstData(20, data, ItemStyle(const BoxDecoration(), color: color2), radiusDiff: 20, childrenList: []);
        data.childrenList?.add(data2);
        for (int k = 0; k < 2; k++) {
          Color color3 = Color.fromARGB(
            255,
            (random.nextDouble() * 255).toInt(),
            (random.nextDouble() * 255).toInt(),
            (random.nextDouble() * 255).toInt(),
          );
          SunburstData data3 = SunburstData(10, data2, ItemStyle(const BoxDecoration(), color: color3), radiusDiff: 40, childrenList: []);
          data2.childrenList?.add(data3);
        }
      }
      list.add(data);
    }

    SunburstSeries series = SunburstSeries(list, innerRadius: const SNumber.percent(30), adjustData: true);
    SunburstChartView chartView = SunburstChartView(series);
    chartView.measure(width, height);
    chartView.layout(0, 0, width, height);
    addView(chartView);
  }

  void _layoutForCategory() {
    int dataLength = xAxis.data.length;
    if (dataLength <= 0) {
      dataLength = _findMaxDataLength();
    }

    if (dataLength <= 0) {
      return;
    }

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
      _layoutForCategoryBar(barList, itemWidth, dataLength, maxData);
    }

    // 处理线
    if (lineList.isNotEmpty) {
      _layoutForCategoryLine(lineList, itemWidth, maxData);
    }
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

  void _layoutForCategoryBar(List<BarGroup> barList, double itemWidth, int dataLength, double maxData) {
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
      BarGroup data = barList[j];
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
          RectView view = RectView(point.itemStyle.decoration, paint: paint);
          view.measure(widthList[j], height);
          view.layout(offset, boundRect.height - height, offset + widthList[j], boundRect.height);
          addView(view);
        }
      }
    }
  }

  void _layoutForCategoryLine(List<BarGroup> lineList, double itemWidth, double maxData) {
    for (var element in lineList) {
      double offset = 0;
      List<Offset> pl = [];
      for (var e2 in element.dataList) {
        if (e2 == null) {
          offset += itemWidth;
          continue;
        }
        double height = boundRect.height * e2.y / maxData;
        double x = offset + itemWidth / 2;
        double y = boundRect.bottom - height;
        pl.add(Offset(x, y));
        offset += itemWidth;
      }

      LineStyle style = element.lineStyle;
      LineView lineCanvas = LineView(pl, style, paint: paint, showSymbol: style.symbolStyle != null);
      lineCanvas.measure(areaBounds.width, areaBounds.height);
      lineCanvas.layout(0, 0, areaBounds.width, areaBounds.height);
      addView(lineCanvas);
    }
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
