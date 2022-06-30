import 'package:easy_chart/chart/options/string_number.dart';
import 'package:flutter/material.dart';

import 'axis.dart';
import 'axis_label.dart';
import 'axis_line.dart';
import 'axis_pointer.dart';
import 'axis_tick.dart';
import 'split_area.dart';
import 'split_line.dart';
import 'style.dart';
import 'tool_tip.dart';

///极坐标径向轴
class PolarRadiusAxis {
  final String id;

  int index = 0;
  bool show = true;

  String? name;
  Position? nameLocation;
  TextStyle nameTextStyle = const TextStyle(color: Colors.black54, fontSize: 13);
  num nameGap = 15;
  num nameRotate = 0;

  bool inverse = false;
  EdgeInsetsGeometry margin = EdgeInsets.zero;
  num? min;
  num? max;

  //是否是脱离 0 值比例。设置成 true 后坐标刻度不会强制包含零刻度
  bool scale = false;

  num splitNumber = 5; //坐标轴的分割段数，需要注意的是这个分割段数只是个预估值，实际显示的段数会在这个基础上根据分割后坐标轴刻度显示的易读程度作调整
  num? minInterval; //自动计算的坐标轴最小间隔大小
  num? maxInterval; //自动计算的坐标轴最大间隔大小
  num? interval; //强制设置坐标轴分割间隔
  bool silent = false; //坐标轴是否是静态无法交互
  bool triggerEvent = false;

  PolarRadiusAxis(this.id); //坐标轴的标签是否响应和触发鼠标事件，默认不响应

}

///极坐标角度轴
class PolarAngleAxis {
  final String id;
  bool show = true;
  int index = 0;
  num startAngle = 0;
  bool clockwise = true;

  num? min;
  num? max;

  //是否是脱离 0 值比例。设置成 true 后坐标刻度不会强制包含零刻度
  bool scale = false;

  num splitNumber = 5; //坐标轴的分割段数，需要注意的是这个分割段数只是个预估值，实际显示的段数会在这个基础上根据分割后坐标轴刻度显示的易读程度作调整
  num? minInterval; //自动计算的坐标轴最小间隔大小
  num? maxInterval; //自动计算的坐标轴最大间隔大小
  num? interval; //强制设置坐标轴分割间隔
  bool silent = false; //坐标轴是否是静态无法交互
  bool triggerEvent = false; //坐标轴的标签是否响应和触发鼠标事件，默认不响应

  AxisLine axisLine = AxisLine();
  AxisTick axisTick = AxisTick();
  MinorTick minorTick = MinorTick();
  AxisLabel axisLabel = AxisLabel();
  SplitLine splitLine = SplitLine();
  MinorSplitLine minorSplitLine = MinorSplitLine();
  SplitArea splitArea = SplitArea();
  AxisPointer axisPointer = AxisPointer();
  List<AxisData> data = [];

  PolarAngleAxis(this.id);
}

class PolarAxis {
  final String id;
  num? radius;
  List<SNumber> center = const [SNumber.percent(50), SNumber.percent(50)];

  PolarRadiusAxis radiusAxis = PolarRadiusAxis('');
  PolarAngleAxis angleAxis = PolarAngleAxis('');

  ToolTip toolTip = ToolTip();

  PolarAxis(this.id);
}
