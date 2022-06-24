import 'package:flutter/material.dart';

import '../functions.dart';
import 'style.dart';

class ChartLabel{
  bool show = true;
  Position position=Position.top;
  double distance=5;
  double rotate = 0;
  Offset offset=Offset.zero;
  NumberFormatter? formatter;
  TextStyle textStyle = const TextStyle(fontSize: 11, color: Colors.black54);
  Alignment alignment=Alignment.center;
  BoxDecoration decoration = const BoxDecoration();
  EdgeInsetsGeometry padding = EdgeInsets.zero;
  EdgeInsetsGeometry margin = EdgeInsets.zero;
  OverFlow overFlow = OverFlow.cut;
  String ellipsis = '';
}