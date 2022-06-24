import 'package:flutter/material.dart';

import 'tool_tip.dart';

class ChartGrid {
  final String id;
  bool show = false;
  EdgeInsetsGeometry margin = EdgeInsets.zero;
  EdgeInsetsGeometry padding = EdgeInsets.zero;
  Decoration decoration = const BoxDecoration();
  ToolTip toolTip = ToolTip();

  ChartGrid(this.id);
}
