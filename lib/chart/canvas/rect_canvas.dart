import 'dart:ui';

import 'package:easy_chart/chart/canvas/area_canvas.dart';
import 'package:easy_chart/chart/canvas/chart_canvas.dart';
import 'package:flutter/material.dart';

class RectCanvas extends PathCanvas {
  RectCanvas(Rect rect, {Color? color, Shader? shader, bool fill = true})
      : super(Path()
    ..addRect(rect)
    ..close(), color: color, shader: shader, fill: fill);
}
