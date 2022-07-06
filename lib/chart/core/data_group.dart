import 'package:easy_chart/chart/options/label.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:flutter/material.dart';

///https://echarts.apache.org/zh/option.html#series-heatmap
class ChartType {
  final String key;

  const ChartType(this.key);

  static const ChartType line = ChartType('line');
  static const ChartType bar = ChartType('bar');
  static const ChartType pie = ChartType('pie');
  static const ChartType point = ChartType('point');
  static const ChartType tree = ChartType('tree');
  static const ChartType radar = ChartType('radar');
  static const ChartType treeMap = ChartType('treeMap');
  static const ChartType sunburst = ChartType('sunburst');
  static const ChartType boxplot = ChartType('boxplot');
  static const ChartType candlestick = ChartType('candlestick');
  static const ChartType heatMap = ChartType('heatMap');
  static const ChartType map = ChartType('map');
  static const ChartType parallel = ChartType('parallel');
  static const ChartType graph = ChartType('graph');
  static const ChartType sankey = ChartType('sankey');
  static const ChartType funnel = ChartType('funnel');
  static const ChartType gauge = ChartType('gauge');
  static const ChartType pictorialBar = ChartType('pictorialBar');
  static const ChartType themeRiver = ChartType('themeRiver');
}

enum StackStrategy { all, samesign, positive, negative }

//数据集
class DataGroup {
  final String? id;
  final String? name;
  final ChartType type;
  final String yAxisId;
  final String xAxisId;
  final String? polarAxisId;
  final List<DataPoint?> dataList;

  final ChartSymbol? symbol;
  final bool showAllSymbol;
  final bool legendHoverLink;

  final bool connectNulls;
  final bool clip;

  final ChartLabel? label;
  final ChartLabel? labelSelect;

  final ChartLabel? endLabel;
  final ChartLabel? endLabelSelect;

  final ItemStyle? itemStyle;
  final ItemStyle? itemSelectStyle;

  DataGroup(
    this.type,
    this.xAxisId,
    this.yAxisId,
    this.dataList, {
    this.id,
    this.polarAxisId,
    this.name,
    this.symbol,
    this.showAllSymbol = false,
    this.legendHoverLink = true,
    this.connectNulls = false,
    this.clip = true,
    this.label,
    this.labelSelect,
    this.endLabel,
    this.endLabelSelect,
    this.itemStyle,
    this.itemSelectStyle,
  });
}

// 数据点
class DataPoint {
  late final double y;
  late final double x;

  final ChartLabel? label;
  final ChartLabel? labelSelect;
  final ItemStyle itemStyle;
  final ItemStyle? itemSelectStyle;

  DataPoint(
    num x,
    num y, {
    this.label,
    this.labelSelect,
    this.itemStyle = const ItemStyle(BoxDecoration(color: Colors.lightGreen)),
    this.itemSelectStyle,
  }) {
    this.x = x.toDouble();
    this.y = y.toDouble();
  }
}
