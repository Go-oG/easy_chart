import 'package:easy_chart/chart/core/chart_view.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:easy_chart/chart/utils/paint_util.dart';
import 'package:flutter/material.dart';

/// 单个K线图
class CandleStickView extends View {
  final double maxPrice;
  final double minPrice;
  final double openPrice;
  final double closePrice;
  final Color upColor;
  final Color downColor;
  final bool fill;
  final double lineWidth;

  CandleStickView(
    this.maxPrice,
    this.minPrice,
    this.openPrice,
    this.closePrice, {
    this.lineWidth = 1,
    this.upColor = Colors.redAccent,
    this.downColor = Colors.green,
    this.fill = true,
    super.paint,
  });

  @override
  void onDraw(Canvas canvas, double animatorPercent) {
    paint.reset();
    double rectHeight;
    double downLineHeight;
    double upLineHeight;
    double all = maxPrice - minPrice;
    bool isUp = closePrice - openPrice >= 0;
    if (all == 0) {
      rectHeight = 1;
      downLineHeight = 0;
      upLineHeight = 0;
    } else {
      if (closePrice >= openPrice) {
        rectHeight = height * ((closePrice - openPrice) / all);
        downLineHeight = height * ((openPrice - minPrice) / all);
        upLineHeight = height * ((maxPrice - closePrice) / all);
      } else {
        rectHeight = height * ((openPrice - closePrice) / all);
        downLineHeight = height * ((closePrice - minPrice) / all);
        upLineHeight = height * ((maxPrice - openPrice) / all);
      }
    }

    paint.style = PaintingStyle.stroke;
    paint.color = isUp ? upColor : downColor;
    paint.strokeWidth = lineWidth;

    if (downLineHeight > 0) {
      canvas.drawLine(Offset(centerX, height), Offset(centerX, height - downLineHeight), paint);
    }
    if (rectHeight > 0) {
      canvas.drawLine(Offset(centerX, 0), Offset(centerX, rectHeight), paint);
    }

    if (rectHeight == 0) {
      canvas.drawLine(Offset(0, centerY), Offset(width, centerY), paint);
    } else {
      paint.style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, upLineHeight, width, rectHeight), paint);
    }
  }

}
