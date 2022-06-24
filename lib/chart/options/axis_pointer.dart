
import 'package:flutter/material.dart';

import 'style.dart';

class AxisPointer{
  static const int TYPE_LINE = 1;
  static const int TYPE_SHADOW = 2;
  static const int TYPE_NONE = 0;
  bool show = false;
  int type = TYPE_NONE;
  bool? snap; //坐标轴指示器是否自动吸附到点上。默认自动判断
  LineStyle lineStyle = LineStyle();
  BoxShadow shadow = const BoxShadow();
  bool triggerTooltip = false;
  TextStyle labelStyle = const TextStyle();
  BoxDecoration handle = const BoxDecoration();
}