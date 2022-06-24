import 'package:flutter/material.dart';

import 'axis_label.dart';
import 'axis_line.dart';
import 'axis_pointer.dart';
import 'axis_tick.dart';
import 'split_area.dart';
import 'split_line.dart';
import 'style.dart';

class AxisData {
  late String value;
  TextStyle style = const TextStyle();

  AxisData(this.value);
}

///笛卡尔坐标轴
class Axis {
  final String id;
  final Position position;
  bool show = true;
  double? width;
  double offset = 2;
  double labelMargin = 2;
  bool alignTicks = true;
  bool tickInside = false;
  String? name;
  Position nameLocation = Position.left;
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
  num minInterval = 2; //自动计算的坐标轴最小间隔大小
  num maxInterval = double.infinity; //自动计算的坐标轴最大间隔大小
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

  Axis(this.id, this.position,
      {this.width,
      this.offset = 2,
      this.labelMargin = 2,
      this.alignTicks = true,
      this.tickInside = false,
      this.name,
      this.nameLocation = Position.left,
      this.nameTextStyle = const TextStyle(color: Colors.black54, fontSize: 13),
      this.nameGap = 15,
      this.nameRotate = 0,
      this.inverse = false,
      this.margin = EdgeInsets.zero,
      this.min,
      this.max,
      this.scale = false,
      this.splitNumber = 5,
      this.minInterval = 2,
      this.maxInterval = double.infinity,
      this.interval,
      this.silent = false,
      this.triggerEvent = false}) {
    assert(id.isNotEmpty);
  }
}
