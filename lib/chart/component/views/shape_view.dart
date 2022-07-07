import 'package:easy_chart/chart/core/chart_view.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:flutter/material.dart';

class ShapeView extends View {
  final SymbolStyle symbolStyle;

  ShapeView(this.symbolStyle, { super.paint});

  @override
  void onDraw(Canvas canvas, double animatorPercent) {
    if (symbolStyle.symbol.type == ChartSymbol.None) {
      return;
    }
    symbolStyle.fillPaint(paint);

    Offset offset = Offset(centerX, centerY);

    ChartSymbol symbol=symbolStyle.symbol;

    if (symbol.type == ChartSymbol.Circle) {
      canvas.drawCircle(offset, symbol.size.height, paint);
      return;
    }

    if (symbol.type == ChartSymbol.EmptyCircle) {
      canvas.drawCircle(offset, symbol.size.height, paint);
      paint.color = Colors.white;
      canvas.drawCircle(offset, symbol.size.height / 2, paint);
      return;
    }

    if (symbol.type == ChartSymbol.Rect) {
      canvas.drawRect(Rect.fromCenter(center: offset, width: symbol.size.width, height: symbol.size.height), paint);
      return;
    }

    if (symbol.type == ChartSymbol.RoundRect) {
      canvas.drawRRect(
          RRect.fromLTRBR(offset.dx - symbol.size.width / 2, offset.dy - symbol.size.height / 2, offset.dx + symbol.size.width / 2,
              offset.dy + symbol.size.height / 2, const Radius.circular(4)),
          paint);
      return;
    }

    if (symbol.type == ChartSymbol.Triangle) {
      Path path = Path();
      path.moveTo(offset.dx, offset.dy - symbol.size.height / 2);
      path.lineTo(offset.dx + symbol.size.width / 2, offset.dx + symbol.size.height / 2);
      path.lineTo(offset.dx - symbol.size.width / 2, offset.dx + symbol.size.height / 2);
      path.close();
      canvas.drawPath(path, paint);
      return;
    }

    if (symbol.type == ChartSymbol.Diamond) {
      Path path = Path();
      path.moveTo(offset.dx, offset.dy - symbol.size.height / 2);
      path.lineTo(offset.dx + symbol.size.width / 2, offset.dy);
      path.lineTo(offset.dx, offset.dy + symbol.size.height / 2);
      path.lineTo(offset.dx - symbol.size.width / 2, offset.dy);
      path.close();
      canvas.drawPath(path, paint);
      return;
    }

    if (symbol.type == ChartSymbol.Pin) {
      Path path = Path();
      path.moveTo(offset.dx, offset.dy - symbol.size.height / 2);
      path.lineTo(offset.dx + symbol.size.width / 2, offset.dy);
      path.lineTo(offset.dx, offset.dy + symbol.size.height / 2);
      path.lineTo(offset.dx - symbol.size.width / 2, offset.dy);
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
