import 'package:easy_chart/chart/core/chart_view.dart';
import 'package:flutter/material.dart';

class TextView extends View {
  final String text;
  final TextStyle style;
  final double minWidth;
  final TextAlign textAlign;
  final TextDirection textDirection;
  late TextSpan _textSpan;
  late TextPainter _textPainter;

  TextView(
    this.text,
    this.style, {
    this.minWidth = 0,
    this.textAlign = TextAlign.start,
    this.textDirection = TextDirection.ltr,
  }) {
    _textSpan = TextSpan(
      text: text,
      style: style,
    );
    _textPainter = TextPainter(text: _textSpan, textAlign: textAlign, textDirection: textDirection);
  }

  @override
  void onDraw(Canvas canvas, double animatorPercent) {
    _textPainter.layout(minWidth: minWidth, maxWidth: width);
    _textPainter.paint(canvas, Offset(centerX - _textPainter.width / 2, centerY - _textPainter.height / 2));
  }
}
