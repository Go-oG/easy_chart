import 'package:easy_chart/chart/core/chart_view.dart';
import 'package:flutter/material.dart';

//TODO 待完成
class PathView extends View {
  final Path path;
  final Color? color;
  final Shader? shader;
  final bool fill;
  final Border? border;

  PathView(
    this.path,
    this.color,
    this.shader, {
    this.fill = true,
    this.border,
  });

  @override
  @protected
  void onDraw(Canvas canvas, double animatorPercent) {

  }

}
