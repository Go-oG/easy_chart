import 'package:flutter/material.dart';

import 'animation.dart';
import 'axis.dart' as chart;
import 'legend.dart';
import 'title.dart';

class BaseConfig {
  ChartAnimation animation = ChartAnimation();
  Legend? legend;

  List<chart.Axis> yAxis = [];
  List<chart.Axis> xAxis = [];

  ChartTitle? title;
  Decoration? decoration;
  EdgeInsetsGeometry padding = EdgeInsets.zero;
  EdgeInsetsGeometry margin = EdgeInsets.zero;

  //这里是为了优化点击事件回调而存在
  bool useLongPress = true;
  bool useDoubleClick = true;
}
