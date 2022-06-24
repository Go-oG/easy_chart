import 'package:flutter/material.dart';

import 'style.dart';

//轴线
class AxisLine {
  bool show = true;
  bool onZero = true;
  int onZeroAxisIndex = 0;
  AxisSymbol symbol = AxisSymbol.none; //控制是否显示箭头
  Size symbolSize = Size.zero;
  LineStyle style = LineStyle();

  void fillPaint(Paint paint) {
    style.fillPaint(paint);
  }

  Paint toPaint() {
    return style.toPaint();
  }
}
