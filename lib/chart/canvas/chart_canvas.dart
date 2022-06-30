import 'dart:ui';

abstract class ChartCanvas {
  final int level;

  ChartCanvas({this.level = 0});

  void onDraw(Canvas canvas, double animationPercent);
}
