//雷达图坐标
import 'package:easy_chart/chart/functions.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:flutter/material.dart';

import 'axis_line.dart';
import 'string_number.dart';

class RadarName {
  bool show = true;
  NumberFormatter? formatter;
  TextStyle textStyle = const TextStyle();
  BoxDecoration decoration = const BoxDecoration();
  OverFlow overFlow = OverFlow.cut;
  String ellipsis = '';
}

class RadarIndicator {
  final String name;
  final double max;
  final double min;
  final Color? color;

  RadarIndicator(
    this.name,
    this.max, {
    this.min = 0,
    this.color = Colors.white,
  });
}

enum RadarShape { circle, polygon }

class Radar {
  final String id;
  final bool show;
  final List<RadarIndicator> indicatorList;
  final List<SNumber> center;
  final SNumber radius;
  final double offsetAngle;
  final num nameGap;
  final int splitNumber;
  final List<Color> areaColorList;
  final RadarShape shape;
  final bool silent;
  final bool triggerEvent;
  final AxisLine axisLine;

  Radar(
    this.id,
    this.indicatorList, {
    this.show = true,
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    this.radius = const SNumber.percent(75),
    this.offsetAngle = 0,
    this.nameGap = 15,
    this.splitNumber = 5,
    this.areaColorList = const [],
    this.shape = RadarShape.polygon,
    this.silent = false,
    this.triggerEvent = false,
    this.axisLine = const AxisLine(style: LineStyle(color: Colors.black26, width: 1)),
  }) {
    if (indicatorList.length < 3) {
      throw FlutterError("对于雷达图其维度必须大于等于3");
    }

    if (center.length != 2) {
      throw FlutterError('圆心坐标表示必需为2');
    }

    for (var element in center) {
      if (!element.isPositiveNumber()) {
        throw FlutterError("圆心坐标必须大于0");
      }
    }

    if (!radius.isPositiveNumber()) {
      throw FlutterError('半径必需大于0');
    }

    if (nameGap < 0) {
      throw FlutterError("nameGap must >=0");
    }
    if (splitNumber <= 0) {
      throw FlutterError("splitNumber must >0");
    }

    if (areaColorList.isNotEmpty && areaColorList.length != splitNumber) {
      throw FlutterError('当AreaColor 不为空时，其长度必须等于SplitNumber');
    }
    if (offsetAngle < 0 || offsetAngle > 360) {
      throw FlutterError('offsetAngle must in [0,360]');
    }
  }
}
