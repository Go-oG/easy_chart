import 'package:flutter/material.dart';

import 'style.dart';

//轴线
class AxisLine {
  final bool show;
  final bool onZero;
  final String onZeroAxisId;
  final AxisSymbol symbol; //控制是否显示箭头
  final Size symbolSize;
  final LineStyle style;

  AxisLine(
      {this.show = true,
      this.onZero = true,
      this.onZeroAxisId = '',
      this.symbol = AxisSymbol.none,
      this.symbolSize = const Size(4, 4),
      this.style = const LineStyle(color: Colors.black45)});

  void fillPaint(Paint paint) {
    style.fillPaint(paint);
  }
}
