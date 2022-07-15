//雷达图坐标
import 'package:easy_chart/chart/functions.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:flutter/material.dart';

import 'axis_line.dart';
import 'string_number.dart';

class RadarName {
  bool show = true;
  NumberFormatter? formatter;
  TextStyle textStyle = const TextStyle();
  BoxDecoration decoration = const BoxDecoration();
  OverFlow overFlow = OverFlow.cut;
  String ellipsis = '';
}


