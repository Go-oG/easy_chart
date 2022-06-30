// 轴标签相关
import 'package:easy_chart/chart/functions.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:flutter/material.dart';

class AxisLabel {
  bool show = true;

  //坐标轴刻度标签的显示间隔，在类目轴中有效。
  // 默认会采用标签不重叠的策略间隔显示标签。默认-1
  // 可以设置成 0 强制显示所有标签。
  // 如果设置为 1，表示『隔一个标签显示一个标签』，如果值为 2，表示隔两个标签显示一个标签，以此类推。
  int interval = -1;
  bool inside = false;
  double rotate = 0;
  double margin = 8;

  NumberFormatter? formatter;
  bool? showMinLabel;
  bool? showMaxLabel;
  bool hideOverLap = true;

  TextStyle textStyle = const TextStyle();
  TextAlign textAlign = TextAlign.center;
  BoxDecoration decoration = const BoxDecoration();

  num? width;
  num? height;
  OverFlow overFlow = OverFlow.cut;
  String ellipsis = '';

  TextPainter toTextPainter(String s) {
    TextSpan span = TextSpan(text: s, style: textStyle);
    TextPainter painter = TextPainter(text: span, textAlign: textAlign, textDirection: TextDirection.ltr);

    return painter;
  }
}
