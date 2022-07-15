import 'package:easy_chart/chart/options/label.dart';
import 'package:easy_chart/chart/options/radar.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:flutter/material.dart';

class RadarSeries {
  final Radar radar;
  final List<RadarData> dataList;
  RadarSeries(this.radar, this.dataList);
}

class RadarData {
  final List<double> dataList;
  final ChartLabel label;
  final AreaStyle? areaStyle;
  final LineStyle? lineStyle;
  final bool showSymbol;
  final SymbolStyle? symbolStyle;

  RadarData(
    this.dataList, {
    this.label = const ChartLabel(),
    this.areaStyle,
    this.lineStyle = const LineStyle(color: Colors.blue),
    this.showSymbol = false,
    this.symbolStyle,
  });
}
