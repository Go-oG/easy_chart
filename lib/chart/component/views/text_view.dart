import 'dart:ui';

import 'package:easy_chart/chart/core/chart_view.dart';

class TextCanvas extends View {
  final String text;
  final TextStyle style;
  final double minWidth;
  final double maxWidth;

  TextCanvas(this.text, this.style, this.maxWidth, {this.minWidth = 0});

  @override
  void onDraw(Canvas canvas, double animatorPercent) {

  }

}
