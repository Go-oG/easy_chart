import 'package:flutter/material.dart';

import '../functions.dart';
import 'axis_pointer.dart';
import 'style.dart';

enum ToolTipTrigger { none, axis, item }

class ToolTip {
  bool show = false;
  ToolTipTrigger tipTrigger = ToolTipTrigger.item;
  AxisPointer axisPointer = AxisPointer();
  Position position = Position.center;
  ToolTipFormatter? tipFormatter;
  NumberFormatter? numberFormatter;
  Decoration decoration = const BoxDecoration();
  EdgeInsetsGeometry padding = EdgeInsets.zero;
  TextStyle textStyle = const TextStyle();
}
