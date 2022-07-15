import 'package:flutter/material.dart';

import '../functions.dart';
import 'style.dart';

class ChartLabel {
  final bool show;
  final ChartAlign align;
  final double distance;
  final double rotate;
  final Offset offset;
  final NumberFormatter? formatter;
  final TextStyle textStyle;
  final BoxDecoration? decoration;
  final EdgeInsets padding;
  final OverFlow overFlow;
  final String ellipsis;

  final bool drawLabelLine;
  final double labelLineLength;
  final EdgeInsets lineMargin;
  final LineStyle? labelLineStyle;

  const ChartLabel({
    this.show = false,
    this.align = ChartAlign.center,
    this.distance = 0,
    this.rotate = 0,
    this.offset = Offset.zero,
    this.formatter,
    this.textStyle = const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.normal),
    this.decoration,
    this.padding = EdgeInsets.zero,
    this.overFlow = OverFlow.cut,
    this.ellipsis = '',
    this.drawLabelLine = true,
    this.lineMargin=const EdgeInsets.only(left: 2,right:2),
    this.labelLineLength = 10,
    this.labelLineStyle,
  });
}
