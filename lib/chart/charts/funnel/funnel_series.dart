import 'package:easy_chart/chart/options/label.dart';
import 'package:easy_chart/chart/options/string_number.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:flutter/material.dart';

class FunnelSeries {
  final String id;
  final double min;
  final double max;
  final ChartAlign labelPosition;
  final List<FunnelData> dataList;
  final SNumber minSize;
  final SNumber maxSize;
  final Direction direction;
  final bool sortAsc;
  final double gap;
  final Align2 funnelAlign;
  final bool legendHoverLink;
  final int zLevel;
  final bool animator;
  final AnimatorDirection animatorDirection;

  FunnelSeries(
    this.dataList, {
    this.labelPosition = ChartAlign.center,
    this.id = '',
    this.min = 0,
    this.max = 100,
    this.minSize = const SNumber(0, false),
    this.maxSize = const SNumber(100, true),
    this.direction = Direction.vertical,
    this.sortAsc = true,
    this.animator = false,
    this.animatorDirection = AnimatorDirection.ste,
    this.gap = 2,
    this.funnelAlign = Align2.center,
    this.legendHoverLink = true,
    this.zLevel = 0,
  });
}

class FunnelData {
  final double data;
  final String? labelText;
  final AreaStyle style;
  final ChartLabel label;
  final BorderSide? border;

  FunnelData(
    this.data,
    this.style, {
    this.border,
    LineStyle? labelLineStyle,
    this.label = const ChartLabel(),
    this.labelText,
  }) ;
}
