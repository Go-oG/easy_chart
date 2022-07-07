import 'package:easy_chart/chart/core/chart_view.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:flutter/material.dart';

class ShapeView extends View {
  final SymbolStyle symbolStyle;

  ShapeView(this.symbolStyle, {super.paint});

  @override
  void onDraw(Canvas canvas, double animatorPercent) {
    if (symbolStyle.symbol == ChartSymbol.none) {
      return;
    }
    symbolStyle.fillPaint(paint);

    Offset offset = Offset(centerX, centerY);

    ChartSymbol symbol = symbolStyle.symbol;

    if (symbol == ChartSymbol.circle) {
      canvas.drawCircle(offset, symbolStyle.size.height, paint);
      return;
    }

    if (symbol == ChartSymbol.emptyCircle) {
      canvas.drawCircle(offset, symbolStyle.size.height, paint);
      paint.color = Colors.white;
      canvas.drawCircle(offset, symbolStyle.size.height / 2, paint);
      return;
    }

    if (symbol == ChartSymbol.rect) {
      canvas.drawRect(Rect.fromCenter(center: offset, width: symbolStyle.size.width, height: symbolStyle.size.height), paint);
      return;
    }

    if (symbol == ChartSymbol.roundRect) {
      canvas.drawRRect(
          RRect.fromLTRBR(offset.dx - symbolStyle.size.width / 2, offset.dy - symbolStyle.size.height / 2,
              offset.dx + symbolStyle.size.width / 2, offset.dy + symbolStyle.size.height / 2, const Radius.circular(4)),
          paint);
      return;
    }

    if (symbol == ChartSymbol.triangle) {
      Path path = Path();
      path.moveTo(offset.dx, offset.dy - symbolStyle.size.height / 2);
      path.lineTo(offset.dx + symbolStyle.size.width / 2, offset.dx + symbolStyle.size.height / 2);
      path.lineTo(offset.dx - symbolStyle.size.width / 2, offset.dx + symbolStyle.size.height / 2);
      path.close();
      canvas.drawPath(path, paint);
      return;
    }

    if (symbol == ChartSymbol.diamond) {
      Path path = Path();
      path.moveTo(offset.dx, offset.dy - symbolStyle.size.height / 2);
      path.lineTo(offset.dx + symbolStyle.size.width / 2, offset.dy);
      path.lineTo(offset.dx, offset.dy + symbolStyle.size.height / 2);
      path.lineTo(offset.dx - symbolStyle.size.width / 2, offset.dy);
      path.close();
      canvas.drawPath(path, paint);
      return;
    }

    if (symbol == ChartSymbol.pin) {
      Path path = Path();
      path.moveTo(offset.dx, offset.dy - symbolStyle.size.height / 2);
      path.lineTo(offset.dx + symbolStyle.size.width / 2, offset.dy);
      path.lineTo(offset.dx, offset.dy + symbolStyle.size.height / 2);
      path.lineTo(offset.dx - symbolStyle.size.width / 2, offset.dy);
      path.close();
      canvas.drawPath(path, paint);
      return;
    }
  }
}

class ShapeData {
  final Offset position;
  final ChartSymbol symbol;

  ShapeData(this.position, this.symbol);
}
