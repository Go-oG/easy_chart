import 'package:easy_chart/chart/options/axis_line.dart';
import 'package:easy_chart/chart/options/label.dart';
import 'package:easy_chart/chart/options/string_number.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:flutter/material.dart';

//一个雷达图系列
class RadarSeries {
  final RadarAxis radar;
  final List<RadarData> dataList;

  RadarSeries(this.radar, this.dataList);
}

//单个数据
class RadarData {
  final List<double> dataList;
  final ChartLabel label;
  final AreaStyle? areaStyle;
  final LineStyle? lineStyle;
  final SymbolStyle? symbolStyle;

  RadarData(
    this.dataList, {
    this.label = const ChartLabel(),
    this.areaStyle,
    this.lineStyle = const LineStyle(color: Colors.blue),
    this.symbolStyle,
  }) {
    if (areaStyle == null && lineStyle == null) {
      throw FlutterError('areaStyle和LineStyle 不能同时为空');
    }
  }
}

///雷达图轴
class RadarAxis {
  final String id;
  final bool show;

  final AxisLine? axisLine; //轴，为空则不显示
  late final List<ItemStyle> styleList; // 每个单独的

  final List<RadarIndicator> indicatorList;
  final List<SNumber> center;
  final SNumber radius;
  final double offsetAngle;
  final num nameGap;
  final int splitNumber;

  final RadarShape shape;
  final bool silent;
  final bool triggerEvent;

  RadarAxis(
    this.id,
    this.indicatorList, {
    this.show = true,
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    this.radius = const SNumber.percent(75),
    this.offsetAngle = 0,
    this.nameGap = 15,
    this.splitNumber = 5,
    this.shape = RadarShape.polygon,
    this.silent = false,
    this.triggerEvent = false,
    this.axisLine,
    List<ItemStyle>? styleList,
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

    if (offsetAngle < 0 || offsetAngle > 360) {
      throw FlutterError('offsetAngle must in [0,360]');
    }

    if (styleList != null) {
      this.styleList = styleList;
    } else {
      this.styleList = [];
    }
  }
}

/// 雷达图指示
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

/// 雷达图样式
enum RadarShape { circle, polygon }
