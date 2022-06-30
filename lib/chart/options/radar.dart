//雷达图坐标
import 'package:easy_chart/chart/functions.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:flutter/material.dart';

import 'axis_label.dart';
import 'axis_line.dart';
import 'axis_tick.dart';
import 'split_area.dart';
import 'split_line.dart';
import 'string_number.dart';

class RadarName {
  bool show = true;
  NumberFormatter? formatter;

  TextStyle textStyle = const TextStyle();
  BoxDecoration decoration = const BoxDecoration();
  OverFlow overFlow=OverFlow.cut;
  String ellipsis='';
}

class RadarIndicator {
  String name = '';
  num? max;
  num? min;
  Color? color;
}

enum RadarShape { circle, polygon }

class Radar {
  final String id;
  bool show = true;
  List<SNumber> center = const [SNumber.percent(50), SNumber.percent(50)];
  SNumber radius = const SNumber.percent(75); // 支持数字和百分比表示
  double startAngle = 90;

  List<RadarName> itemList = [];

  num nameGap = 15;
  num splitNumber = 5;
  RadarShape shape = RadarShape.circle;
  bool silent = false;
  bool triggerEvent = false;

  AxisLine axisLine = AxisLine();
  AxisTick axisTick = AxisTick();
  AxisLabel axisLabel = AxisLabel();
  SplitLine splitLine = SplitLine();
  SplitArea splitArea = SplitArea();
  List<RadarIndicator> indicatorList = [];

  Radar(this.id);
}
