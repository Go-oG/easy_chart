import 'dart:math';

import 'package:easy_chart/chart/charts/pie/pie_series.dart';
import 'package:easy_chart/chart/core/chart_view.dart';
import 'package:easy_chart/chart/options/string_number.dart';
import 'package:easy_chart/chart/utils/paint_util.dart';
import 'package:flutter/material.dart';

/// 用于实现饼图、旭日图、圆弧相关的
class ArcView extends View {
  SNumber innerRadius; //内圆半径(<=0时为圆)
  SNumber outerRadius; //外圆半径
  double offsetAngle; // 偏移角度
  double startAngle; // 开始角度
  double sweepAngle; // 扫过的角度
  Color? color;
  Shader? shader;
  bool fill;
  BorderSide? border;
  double corner; // 圆角(只有为圆弧时才有用及内圆半径大于0)

  ArcView({
    this.innerRadius = const SNumber.number(0),
    this.outerRadius = const SNumber.percent(75),
    this.startAngle = 0,
    this.sweepAngle = 0,
    this.color = Colors.lightBlue,
    this.offsetAngle = 0,
    this.shader,
    this.fill = true,
    this.corner = 0,
    this.border,
    super.paint,
    super.zIndex = 0,
  }) {
    if (color == null && shader == null && fill) {
      throw FlutterError('当样式为fill时 color 和shader 不能同时为空');
    }
  }

  @override
  void onDraw(Canvas canvas, double animatorPercent) {
    paint.reset();
    if (color != null) {
      paint.color = color!;
    }
    if (shader != null) {
      paint.shader = shader!;
    }
    paint.style = fill ? PaintingStyle.fill : PaintingStyle.stroke;
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
    double sweepAngle = this.sweepAngle;

    double ox1 = or * cos(startAngle * pi / 180);
    double oy1 = or * sin(startAngle * pi / 180);
    double ox2 = or * cos((startAngle + sweepAngle) * pi / 180);
    double oy2 = or * sin((startAngle + sweepAngle) * pi / 180);
    double iy = ir * sin(startAngle * pi / 180);
    double ix = ir * cos(startAngle * pi / 180);
    double ix2 = ir * cos((startAngle + sweepAngle) * pi / 180);
    double iy2 = ir * sin((startAngle + sweepAngle) * pi / 180);

    Path path = Path();
    if (innerRadius.number <= 0.01) {
      path.moveTo(0, 0);
      path.lineTo(ox1, oy1);
      path.arcToPoint(Offset(ox2, oy2), radius: Radius.circular(or), largeArc: false, clockwise: true);
      path.lineTo(0, 0);
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

  @override
  String toString() {
    return 'ArcView IR:${innerRadius.toString()} OR:${outerRadius.toString()} SA:${startAngle.toInt()} WA:${sweepAngle.toInt()} OA:$offsetAngle';
  }

  //计算圆弧左上顶角当有圆角时的外部半径坐标
  List<Offset> _computeLeftTopPosition(double innerRadius, double outRadius, double startAngle, double corner) {
    const double tmp = pi / 180.0;
    double ratio = corner / (outRadius - corner);
    double ox = ratio * corner / (ratio + 1);
    double xe = sqrt(ox * ox + corner * corner);
    double xo = xe / ratio;
    double cox = acos((outRadius - corner) / xo) * (180 / pi);
    double eob = tmp * (90 - cox - startAngle);
    double ex = outRadius * cos(eob);
    double ey = outRadius * sin(eob);

    //计算圆心坐标
    double tmp2 = startAngle * tmp;
    double cx = innerRadius * sin(tmp2);
    double cy = innerRadius * cos(tmp2);
    double o1x = cx + corner * cos(tmp2);
    double o1y = cy + corner * sin(tmp2);
    return [Offset(o1x, o1y), Offset(ex, ey)];
  }
}
