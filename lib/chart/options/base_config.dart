import 'package:flutter/material.dart';

import 'animation.dart';
import 'axis.dart';
import 'legend.dart';
import 'title.dart';

class ChartConfig {
  ChartAnimation animation = ChartAnimation();
  Legend? legend;
  List<BaseAxis> yAxis = [];
  List<BaseAxis> xAxis = [];

  ChartTitle? title;
  Decoration? decoration;
  EdgeInsetsGeometry padding = EdgeInsets.zero;
  EdgeInsetsGeometry margin = EdgeInsets.zero;
  //这里是为了优化点击事件回调而存在
  bool useLongPress = true;
  bool useDoubleClick = true;


}
