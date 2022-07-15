import 'dart:math';

import 'package:easy_chart/chart/core/chart_view.dart';
import 'package:easy_chart/chart/options/string_number.dart';
import 'package:easy_chart/chart/utils/paint_util.dart';
import 'package:flutter/material.dart';

//TODO 圆弧视图
class ArcView extends View {
  final SNumber innerRadius; //内圆半径(<=0时为圆)
  final SNumber outerRadius; //外圆半径

  final double offsetAngle; // 偏移角度
  final double startAngle; // 开始角度
  final double sweepAngle; // 扫过的角度
  final Color? color;
  final Shader? shader;
  final bool fill;
  final Border? border;
  final double corner; // 圆角(只有为圆弧时才有用及内圆半径大于0)

  ArcView(
    this.innerRadius,
    this.outerRadius,
    this.startAngle,
    this.sweepAngle, {
    this.color = Colors.lightBlue,
    this.offsetAngle = 0,
    this.shader,
    this.fill = true,
    this.corner = 0,
    this.border,
    super.paint,
    super.zIndex = 0,
  });

  @override
  void onDraw(Canvas canvas, double animatorPercent) {
    paint.reset();
    paint.color = Colors.deepPurple;
    paint.style = PaintingStyle.fill;
    canvas.translate(centerX, centerY);
    canvas.drawPath(_computeArcPath(), paint);
  }

  // 计算路径
  Path _computeArcPath() {
    double size = min(width, height) / 2;
    double ir = innerRadius.convert(size);
    double or = outerRadius.convert(size);
    double radiusDiff = or - ir; //内外半径差
    double corner = this.corner > radiusDiff / 2 ? radiusDiff / 2 : this.corner;
    double startAngle = this.startAngle - 90 + offsetAngle;
    double ox1 = or * cos(startAngle * pi / 180);
    double oy1 = or * sin(startAngle * pi / 180);
    double ox2 = or * cos((startAngle + sweepAngle) * pi / 180);
    double oy2 = or * sin((startAngle + sweepAngle) * pi / 180);

    double iy = ir * sin(startAngle * pi / 180);
    double ix = ir * cos(startAngle * pi / 180);
    double ix2 = ir * cos((startAngle + sweepAngle) * pi / 180);
    double iy2 = ir * sin((startAngle + sweepAngle) * pi / 180);

    Path path = Path();
    if (ir <= 0) {
      path.moveTo(0, 0);
      path.addArc(Rect.fromCircle(center: Offset.zero, radius: or), startAngle * pi / 180, sweepAngle * pi / 180);
      path.lineTo(
        0,
        0,
      );
      path.close();
    } else {
      path.moveTo(ix, iy);
      path.lineTo(ox1, oy1);
      path.arcToPoint(Offset(ox2, oy2), radius: Radius.circular(or), largeArc: false, clockwise: true);
      path.lineTo(ix2, iy2);
      path.arcToPoint(Offset(ix, iy), radius: Radius.circular(ir), largeArc: false, clockwise: false);
      path.close();
    }
    return path;
  }
}
