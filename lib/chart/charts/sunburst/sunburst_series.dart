import 'package:easy_chart/chart/options/label.dart';
import 'package:easy_chart/chart/options/string_number.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:flutter/material.dart';

/// 旭日图
class SunburstSeries {
  final List<SNumber> center;
  final List<SunburstData> dataList;
  final SNumber innerRadius; //内圆半径(<=0时为圆)
  final SNumber outerRadius; //外圆最大半径(<=0时为圆)
  final double offsetAngle; // 偏移角度
  final double corner;
  final double gapAngle;
  final ChartLabel label;

  SunburstSeries(
    this.dataList, {
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    this.innerRadius = const SNumber.percent(10),
    this.outerRadius = const SNumber.percent(80),
    this.offsetAngle = 0,
    this.corner = 0,
    this.gapAngle = 0,
    this.label = const ChartLabel(),
  });
}

class SunburstData {
  final double data;
  final String? label;
  final ItemStyle style;
  final bool fill;
  final Shader? shader;
  final List<SunburstData>? childrenList;

  SunburstData(
    this.data,
    this.style, {
    this.shader,
    this.label,
    this.fill = true,
    this.childrenList,
  });
}

