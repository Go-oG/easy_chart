import 'package:easy_chart/chart/core/chart_view.dart';
import 'package:flutter/material.dart';

//TODO 圆弧视图
class ArcView extends View {
  final Offset center; //圆心坐标
  final double innerRadius; //内圆半径(<=0时为圆)
  final double outerRadius; //外圆半径
  final double startAngle; // 开始角度
  final double sweepAngle; // 扫过的角度
  final Color? color;
  final Shader? shader;
  final bool fill;
  final Border? border;
  final double corner;// 圆角(只有为圆弧时才有用)

  ArcView(this.center,
      this.innerRadius,
      this.outerRadius,
      this.startAngle,
      this.sweepAngle, {
        this.color = Colors.lightBlue,
        this.shader,
        this.fill = true,
        this.corner = 0,
        this.border,
        super.paint,
      });

  @override
  void onDraw(Canvas canvas, double animatorPercent) {


  }

  // 计算路径
 Path _computePath(){
    Path path=Path();



    return path;
 }

}
