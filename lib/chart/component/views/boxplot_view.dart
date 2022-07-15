import 'package:easy_chart/chart/core/chart_view.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:easy_chart/chart/utils/assert_check.dart';
import 'package:easy_chart/chart/utils/paint_util.dart';
import 'package:flutter/material.dart';

class BoxPlotView extends View {
  final double maxValue;
  final double upAve4Value;
  final double middleValue;
  final double downAve4Value;
  final double minValue;

  final LineStyle style;
  final LineStyle connectLineStyle;

  BoxPlotView(
    this.maxValue,
    this.upAve4Value,
    this.middleValue,
    this.downAve4Value,
    this.minValue,
    this.style,
    this.connectLineStyle,
  ) {
    assertCheck(downAve4Value > minValue);
    assertCheck(middleValue > downAve4Value);
    assertCheck(upAve4Value > middleValue);
    assertCheck(maxValue > upAve4Value);
  }

  @override
  void onDraw(Canvas canvas, double animatorPercent) {
    paint.reset();
    style.fillPaint(paint);
    canvas.drawLine(Offset.zero, Offset(width, 0), paint);
    canvas.drawLine(Offset(0, height), Offset(width, height), paint);

    double all = maxValue - minValue;

    double downAve4Height = height * (downAve4Value - minValue) / all;
    connectLineStyle.fillPaint(paint);
    canvas.drawLine(Offset(centerX, height), Offset(centerX, height - downAve4Height), paint);

    style.fillPaint(paint);
    canvas.drawLine(Offset(0, height - downAve4Height), Offset(width, height - downAve4Height), paint);

    double middleHeight = height * (middleValue - minValue) / all;
    canvas.drawLine(Offset(0, height - middleHeight), Offset(width, height - middleHeight), paint);

    double upAve4Height = height * (upAve4Value - minValue) / all;
    canvas.drawLine(Offset(0, height - upAve4Height), Offset(width, height - upAve4Height), paint);

    canvas.drawLine(Offset(0, height - upAve4Height), Offset(0, height - middleHeight), paint);
    canvas.drawLine(Offset(width, height - upAve4Height), Offset(width, height - middleHeight), paint);

    connectLineStyle.fillPaint(paint);
    canvas.drawLine(Offset(centerX, height - upAve4Height), Offset(centerX, 0), paint);
  }
}
