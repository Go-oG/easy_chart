import 'package:easy_chart/chart/options/label.dart';
import 'package:easy_chart/chart/options/string_number.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:flutter/material.dart';

enum RoseType { normal, radius, area }

/// 饼图系列
class PieSeries {
  final List<SNumber> center;
  final List<PieData> dataList;
  final SNumber innerRadius; //内圆半径(<=0时为圆)
  final SNumber outerRadius; //外圆最大半径(<=0时为圆)
  final double offsetAngle; // 偏移角度
  final double corner;
  final RoseType roseType;
  final double gapAngle;
  final ChartLabel label;
  final PieAnimatorStyle animatorStyle;

  PieSeries(
    this.center,
    this.dataList, {
    this.innerRadius = const SNumber.percent(20),
    this.outerRadius = const SNumber.percent(80),
    this.offsetAngle = 0,
    this.corner = 0,
    this.roseType = RoseType.radius,
    this.gapAngle = 0,
    this.label = const ChartLabel(),
    this.animatorStyle = PieAnimatorStyle.expandScale,
  });
}

class PieData {
  final double data;
  final String? label;
  final ItemStyle style;
  final bool fill;
  final Shader? shader;

  PieData(
    this.data,
    this.style, {
    this.shader,
    this.label,
    this.fill = true,
  });
}

enum PieAnimatorStyle {
  expand,
  expandScale,
  originExpand,
  originExpandScale,
}
