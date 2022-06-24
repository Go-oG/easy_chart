import 'package:easy_chart/chart/core/data_group.dart';
import 'package:easy_chart/chart/options/string_number.dart';
import 'package:flutter/material.dart';

class BarGroup extends DataGroup {
  final bool roundCap;
  final bool stack;
  final StackStrategy stackStrategy;
  final bool realtimeSort;
  final bool showBackground;
  final BoxDecoration? backgroundStyle;
  final SNumber? barWidth;
  final SNumber? barMaxWidth;
  final SNumber? barMinWidth;
  final num barMinHeight;
  final num barMinAngle;
  final SNumber barGap;
  final SNumber barCategoryGap;

  BarGroup(
    super.type,
    super.xAxisId,
    super.yAxisId,
    super.dataList, {
    this.barWidth,
    this.barMaxWidth,
    this.barMinWidth,
    this.barMinHeight = 0,
    this.barMinAngle = 0,
    this.barGap = const SNumber.percent(30),
    this.barCategoryGap = const SNumber.percent(20),
    this.stack = false,
    this.stackStrategy = StackStrategy.all,
    this.realtimeSort = false,
    this.roundCap = false,
    this.showBackground = false,
    this.backgroundStyle,
    super.id,
    super.polarAxisId,
    super.name,
    super.symbol,
    super.showAllSymbol = false,
    super.legendHoverLink = true,
    super.connectNulls = false,
    super.clip = true,
    super.label,
    super.labelSelect,
    super.endLabel,
    super.endLabelSelect,
    super.itemStyle,
    super.itemSelectStyle,
  });
}
