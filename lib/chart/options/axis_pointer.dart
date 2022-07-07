import 'package:flutter/material.dart';

import 'style.dart';

enum AxisPointerType {
  line,
  shadow,
  none,
}

/// 坐标轴指示器
class AxisPointer {
  final bool show;
  final AxisPointerType type;
  final bool? snap; //坐标轴指示器是否自动吸附到点上。默认自动判断
  final LineStyle lineStyle;
  final BoxShadow shadow;
  final bool triggerTooltip;
  final TextStyle labelStyle;
  final BoxDecoration? handle;

  AxisPointer({
    this.show = false,
    this.type = AxisPointerType.none,
    this.snap,
    this.lineStyle = const LineStyle(color: Colors.black45),
    this.shadow = const BoxShadow(color: Color.fromRGBO(150, 150, 150, 0.3)),
    this.triggerTooltip = true,
    this.labelStyle = const TextStyle(color: Colors.black54),
    this.handle,
  });
}
