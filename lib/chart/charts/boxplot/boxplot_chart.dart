import 'package:easy_chart/chart/core/chart_view.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:easy_chart/chart/utils/assert_check.dart';
import 'package:easy_chart/chart/utils/paint_util.dart';
import 'package:flutter/material.dart';

/// 单个盒须图
class BoxPlotView extends View {
  final double maxValue;
  final double upAve4Value;
  final double middleValue;
  final double downAve4Value;
  final double minValue;
  final LineStyle style;
  final LineStyle connectLineStyle;
  final Direction direction;

  BoxPlotView(this.maxValue, this.upAve4Value, this.middleValue, this.downAve4Value, this.minValue, this.style, this.connectLineStyle,
      {this.direction = Direction.vertical}) {
    assertCheck(downAve4Value > minValue);
    assertCheck(middleValue > downAve4Value);
    assertCheck(upAve4Value > middleValue);
    assertCheck(maxValue > upAve4Value);
  }

  @override
  void onDraw(Canvas canvas, double animatorPercent) {
    paint.reset();
    style.fillPaint(paint);
    if (direction == Direction.vertical) {
      _drawVertical(canvas, animatorPercent);
    } else {
      _drawHorizontal(canvas, animatorPercent);
    }
  }

  void _drawVertical(Canvas canvas, double animatorPercent) {
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

  void _drawHorizontal(Canvas canvas, double animatorPercent) {
    /// 先绘制开始和结尾的线
    canvas.drawLine(Offset.zero, Offset(0, height), paint);
    canvas.drawLine(Offset(width, 0), Offset(width, height), paint);

    double all = maxValue - minValue;

    /// 绘制25分位线
    double downAve4Width = width * (downAve4Value - minValue) / all;
    connectLineStyle.fillPaint(paint);
    canvas.drawLine(Offset(0, centerY), Offset(downAve4Width, centerY), paint);
    style.fillPaint(paint);
    canvas.drawLine(Offset(downAve4Width, 0), Offset(downAve4Width, height), paint);

    /// 绘制50分位线
    double middleWidth = width * (middleValue - minValue) / all;
    canvas.drawLine(Offset(middleWidth, 0), Offset(middleWidth, height), paint);

    /// 绘制75分位线
    double upAve4Width = width * (upAve4Value - minValue) / all;
    canvas.drawLine(Offset(upAve4Width, 0), Offset(upAve4Width, height), paint);

    // 连接框体
    canvas.drawLine(Offset(downAve4Width, 0), Offset(upAve4Width, 0), paint);
    canvas.drawLine(Offset(downAve4Width, height), Offset(upAve4Width, height), paint);

    connectLineStyle.fillPaint(paint);
    canvas.drawLine(Offset(upAve4Width, centerY), Offset(width, centerY), paint);
  }
}
