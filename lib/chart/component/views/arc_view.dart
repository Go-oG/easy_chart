import 'dart:math';

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
    Path path = Path();
    if (ir <= 0.01) {
      double ox1 = or * cos(startAngle * pi / 180);
      double oy1 = or * sin(startAngle * pi / 180);
      double ox2 = or * cos((startAngle + sweepAngle) * pi / 180);
      double oy2 = or * sin((startAngle + sweepAngle) * pi / 180);
      path.moveTo(0, 0);
      path.lineTo(ox1, oy1);
      path.arcToPoint(Offset(ox2, oy2), radius: Radius.circular(or), largeArc: false, clockwise: true);
      path.lineTo(0, 0);
      path.close();
      return path;
    }

    double iy = ir * sin(startAngle * pi / 180);
    double ix = ir * cos(startAngle * pi / 180);
    if (corner <= 0) {
      double ix2 = ir * cos((startAngle + sweepAngle) * pi / 180);
      double iy2 = ir * sin((startAngle + sweepAngle) * pi / 180);
      double ox1 = or * cos(startAngle * pi / 180);
      double oy1 = or * sin(startAngle * pi / 180);
      double ox2 = or * cos((startAngle + sweepAngle) * pi / 180);
      double oy2 = or * sin((startAngle + sweepAngle) * pi / 180);
      path.moveTo(ix, iy);
      path.lineTo(ox1, oy1);
      path.arcToPoint(Offset(ox2, oy2), radius: Radius.circular(or), largeArc: false, clockwise: true);
      path.lineTo(ix2, iy2);
      path.arcToPoint(Offset(ix, iy), radius: Radius.circular(ir), largeArc: false, clockwise: false);
      path.close();
      return path;
    }

    List<Offset> offsetList = _computeLeftTopPosition(or, corner);
    Offset p1 = offsetList[0];
    Offset p2 = offsetList[1];
    path.moveTo(ix, iy);
    path.lineTo(p1.dx, p1.dy);
    path.arcToPoint(p2, radius: Radius.circular(corner), largeArc: false, clockwise: true);

    offsetList = _computeRightTopPosition(or, corner);
    p1 = offsetList[0];
    p2 = offsetList[1];
    path.arcToPoint(p1, radius: Radius.circular(or), largeArc: false, clockwise: true);
    path.arcToPoint(p2, radius: Radius.circular(corner), largeArc: false, clockwise: true);

    offsetList = _computeRightBottomPosition(ir, corner);
    p1 = offsetList[0];
    p2 = offsetList[1];
    path.lineTo(p1.dx, p1.dy);
    path.arcToPoint(p2, radius: Radius.circular(corner), largeArc: false, clockwise: true);
    offsetList = _computeLeftBottomPosition(ir, corner);
    p1 = offsetList[0];
    p2 = offsetList[1];
    path.arcToPoint(p1, radius: Radius.circular(ir), largeArc: false, clockwise: false);
    path.arcToPoint(p2, radius: Radius.circular(corner), largeArc: false, clockwise: true);
    path.close();
    return path;
  }

  @override
  String toString() {
    return 'ArcView IR:${innerRadius.toString()} OR:${outerRadius.toString()} SA:${startAngle.toInt()} WA:${sweepAngle.toInt()} OA:$offsetAngle';
  }

  //计算圆弧左上顶角当有圆角时的外部半径坐标
  List<Offset> _computeLeftTopPosition(double outRadius, double corner) {
    const double tmp = pi / 180.0;
    double pe = (corner * corner) / (outRadius - corner);
    double anglePCE = asin(pe / corner) * 180 / pi;
    double py = -(outRadius - corner) * sin((90 - anglePCE) * tmp);
    double px = (outRadius - corner) * cos((90 - anglePCE) * tmp);
    double by = py;
    double bx = px - corner;
    double cx = outRadius * sin(pe / corner);
    double cy = -outRadius * cos(pe / corner);

    ///调整偏移量
    double startAngle = this.startAngle + offsetAngle;
    bx = -by * sin(startAngle * pi / 180);
    by = by * cos(startAngle * pi / 180);
    cx = outRadius * sin((startAngle + anglePCE) * tmp);
    cy = -outRadius * cos((startAngle + anglePCE) * tmp);
    return [Offset(bx, by), Offset(cx, cy)];
  }

  //计算圆弧右上顶角当有圆角时的外部半径坐标
  List<Offset> _computeRightTopPosition(double outRadius, double corner) {
    const double tmp = pi / 180.0;

    double tmpRadius = outRadius - corner;
    double angleCorner = asin(corner / tmpRadius) * 180 / pi; //夹角度数
    double oc = tmpRadius * cos(angleCorner * tmp);

    double endAngle = startAngle + offsetAngle + sweepAngle;

    double bx = outRadius * sin((endAngle - angleCorner) * tmp);
    double by = -outRadius * cos((endAngle - angleCorner) * tmp);

    double cx = oc * sin(endAngle * tmp);
    double cy = -oc * cos(endAngle * tmp);

    return [Offset(bx, by), Offset(cx, cy)];
  }

  ///计算圆弧左下顶角当有圆角时的外部半径坐标
  List<Offset> _computeLeftBottomPosition(double innerRadius, double corner) {
    const double tmp = pi / 180.0;
    double op = innerRadius + corner;
    double eb = corner * innerRadius / op;
    double angleEOB = asin(eb / innerRadius) * 180 / pi;
    double startAngle = this.startAngle + offsetAngle;

    double bx = innerRadius * sin((startAngle + angleEOB) * tmp);
    double by = -innerRadius * cos((startAngle + angleEOB) * tmp);

    double oc = op * cos(angleEOB * tmp);
    double cx = oc * sin(startAngle * tmp);
    double cy = -op * cos(startAngle * tmp);

    return [Offset(bx, by), Offset(cx, cy)];
  }

  List<Offset> _computeRightBottomPosition(double innerRadius, double corner) {
    const double tmp = pi / 180.0;
    double op = innerRadius + corner;
    double ec = corner * innerRadius / op;
    double angleEOC = (asin(ec / innerRadius) * 180 / pi);
    double ob = op * cos(angleEOC * tmp);

    double endAngle = startAngle + sweepAngle + offsetAngle;
    double angleOPB = (endAngle - angleEOC) * tmp;

    double cx = innerRadius * sin(angleOPB);
    double cy = -innerRadius * cos(angleOPB);

    double bx = ob * sin(endAngle * tmp);
    double by = -ob * cos(endAngle * tmp);

    return [Offset(bx, by), Offset(cx, cy)];
  }
}
