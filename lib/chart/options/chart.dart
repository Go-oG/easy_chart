//表格的通用配置
import 'package:easy_chart/chart/options/grid.dart';
import 'package:easy_chart/chart/options/radar.dart';
import 'package:flutter/material.dart';

import 'animation.dart';
import 'axis.dart';
import 'axis_polar.dart';
import 'legend.dart';
import 'title.dart';


class ChartConfig {
  ChartTitle? title;
  Legend? legend;
  List<ChartGrid>? gridList;
  //用于笛卡尔坐标系的相关坐标轴
  List<XAxis> xAxis = [];
  List<YAxis> yAxis = [];
  PolarAxis? polarAxis;//用于极坐标系
  ChartAnimation animation = ChartAnimation();
  Decoration? decoration;
  EdgeInsetsGeometry padding = EdgeInsets.zero;
  EdgeInsetsGeometry margin = EdgeInsets.zero;
  //这里是为了优化点击事件回调而存在
  bool useLongPress = true;
  bool useDoubleClick = true;
}