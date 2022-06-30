import 'package:easy_chart/chart/options/string_number.dart';
import 'package:flutter/material.dart';

import 'axis_label.dart';
import 'axis_line.dart';
import 'axis_pointer.dart';
import 'axis_tick.dart';
import 'split_area.dart';
import 'split_line.dart';
import 'style.dart';

//坐标轴
enum AxisType {
  normal,
  polar,
  geo,
}

enum AxisDataType {
  value,
  category,
  time,
  log,
}

//所有坐标轴的基类
abstract class BaseAxis {
  final String id;

  BaseAxis(this.id);

  /// 坐标轴的类型
  AxisType get type;
}

///笛卡尔坐标轴
class Axis extends BaseAxis {
  final Position position;
  final AxisDataType dataType;
  bool show = true;
  String? gridId;
  bool alignTicks = true;
  double offset = 2;

  String? name;
  Position nameLocation = Position.left;
  TextStyle nameTextStyle = const TextStyle(color: Colors.black54, fontSize: 13);
  num nameGap = 15;
  num nameRotate = 0;
  bool inverse = false;

  num? min;
  num? max;

  //是否是脱离 0 值比例。设置成 true 后坐标刻度不会强制包含零刻度
  bool scale = false;
  int splitNumber = 5; //坐标轴的分割段数，需要注意的是这个分割段数只是个预估值，实际显示的段数会在这个基础上根据分割后坐标轴刻度显示的易读程度作调整
  int minInterval = 0; //自动计算的坐标轴最小间隔大小
  int? maxInterval; //自动计算的坐标轴最大间隔大小
  int? interval; //强制设置坐标轴分割间隔

  SNumber? width;
  SNumber? maxWidth;
  SNumber? minWidth;
  SNumber itemGap = const SNumber.number(0);

  int logBase = 10;
  bool silent = false; //坐标轴是否是静态无法交互
  bool triggerEvent = false; //坐标轴的标签是否响应和触发鼠标事件，默认不响应

  AxisLine axisLine = AxisLine();
  AxisTick axisTick = AxisTick();
  MinorTick minorTick = MinorTick();
  AxisLabel axisLabel = AxisLabel();

  SplitLine splitLine = SplitLine();
  MinorSplitLine minorSplitLine = MinorSplitLine();
  SplitArea splitArea = SplitArea();

  /// 只有当[dataType]==[AxisDataType.category]时才有用
  List<AxisData> data = [];
  AxisPointer axisPointer = AxisPointer();

  Axis(super.id, this.position,
      {this.alignTicks = true,
      this.dataType = AxisDataType.category,
      this.name,
      this.nameLocation = Position.left,
      this.nameTextStyle = const TextStyle(color: Colors.black54, fontSize: 13),
      this.nameGap = 15,
      this.nameRotate = 0,
      this.inverse = false,
      this.min,
      this.max,
      this.scale = false,
      this.splitNumber = 5,
      this.minInterval = 2,
      this.maxInterval,
      this.interval,
      this.silent = false,
      this.triggerEvent = false});

  @override
  AxisType get type => AxisType.normal;
}

class XAxis extends Axis {
  XAxis(super.id, super.position,
      {super.alignTicks = true,
      super.dataType = AxisDataType.category,
      super.name,
      super.nameLocation = Position.left,
      super.nameTextStyle = const TextStyle(color: Colors.black54, fontSize: 13),
      super.nameGap = 15,
      super.nameRotate = 0,
      super.inverse = false,
      super.min,
      super.max,
      super.scale = false,
      super.splitNumber = 5,
      super.minInterval = 2,
      super.maxInterval,
      super.interval,
      super.silent = false,
      super.triggerEvent = false});

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (other is XAxis) {
      return other.id == id;
    }
    return false;
  }
}

class YAxis extends Axis {
  YAxis(super.id, super.position,
      {super.alignTicks = true,
      super.dataType = AxisDataType.category,
      super.name,
      super.nameLocation = Position.left,
      super.nameTextStyle = const TextStyle(color: Colors.black54, fontSize: 13),
      super.nameGap = 15,
      super.nameRotate = 0,
      super.inverse = false,
      super.min,
      super.max,
      super.scale = false,
      super.splitNumber = 5,
      super.minInterval = 2,
      super.maxInterval,
      super.interval,
      super.silent = false,
      super.triggerEvent = false});

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  bool operator ==(Object other) {
    if (other is YAxis) {
      return other.id == id;
    }
    return false;
  }
}

class AxisData {
  late String value;
  TextStyle style = const TextStyle();

  AxisData(this.value);
}
