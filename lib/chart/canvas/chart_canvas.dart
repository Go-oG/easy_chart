import 'dart:ui';

/// 图元相关的绘制基类 负责具体的绘制
abstract class ChartCanvas {
  final int level;

  ChartCanvas({this.level = 0});

  void onDraw(Canvas canvas, double animationPercent);
}
