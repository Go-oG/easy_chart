import 'package:easy_chart/chart/component/chart_symbol_view.dart';
import 'package:flutter/material.dart';

import 'style.dart';

class Legend {
  bool show = true;
  bool scroll = false;
  ChartAlign position = ChartAlign.bottomCenter;

  BoxDecoration decoration = const BoxDecoration();
  EdgeInsetsGeometry margin = EdgeInsets.zero;
  EdgeInsetsGeometry padding = EdgeInsets.zero;
  num itemGap = 10;

  //自适应或者固定
  num? width;
  num? height;

  Direction direction = Direction.horizontal;
  Size itemSize = const Size(25, 14);
  List<LegendItem> itemList = [];

  Widget? obtainWidget({BoxConstraints? constraints}) {
    if (itemList.isEmpty || !show) {
      return null;
    }
    List<Widget> wl = [];
    for (var element in itemList) {
      Widget? widget = element.obtainWidget();
      if (widget != null) {
        if (wl.isNotEmpty && itemGap > 0) {
          if (direction == Direction.horizontal) {
            wl.add(SizedBox(width: itemGap.toDouble(), height: 1));
          } else {
            wl.add(SizedBox(width: 1, height: itemGap.toDouble()));
          }
        }
        wl.add(widget);
      }
    }
    if (wl.isEmpty) {
      return null;
    }

    Widget child = Wrap(
      alignment: WrapAlignment.start,
      crossAxisAlignment: WrapCrossAlignment.center,
      direction: direction == Direction.horizontal ? Axis.horizontal : Axis.vertical,
      children: wl,
    );

    return Container(
      constraints: constraints,
      decoration: decoration,
      margin: margin,
      padding: padding,
      child: child,
    );
  }
}

class LegendItem {
  String id = '';
  String name = '';
  TextStyle textStyle = const TextStyle();
  TextStyle textClosedStyle = const TextStyle();
  TextStyle textSelectedStyle = const TextStyle();
  ChartSymbol symbol =  ChartSymbol.rect;

  num gap = 10;

  //自适应或者固定
  num? width;
  num? height;

  EdgeInsetsGeometry padding = EdgeInsets.zero;
  EdgeInsetsGeometry margin = EdgeInsets.zero;

  Decoration decoration = const BoxDecoration(); //正常的装饰
  Decoration closedDecoration = const BoxDecoration(); //关闭时的装饰
  Decoration selectDecoration = const BoxDecoration(); //选中时的装饰

  num symbolRotate = 0;

  Alignment? align; // only support left right
  Direction direction = Direction.horizontal;

  bool closed = false;
  bool allowSelected = false;
  bool selected = false;

  Widget? obtainWidget() {
    double w = (width == null || width! < 0) ? 0 : width!.toDouble();
    double h = (height == null || height! < 0) ? 0 : height!.toDouble();

    BoxConstraints constraints = BoxConstraints(minWidth: w, minHeight: h, maxWidth: w, maxHeight: h);

    List<Widget> wl = [];
    if (symbol != ChartSymbol.none) {
      wl.add(ChartSymbolView(symbol: symbol));
    }

    if (name.isNotEmpty) {
      if (gap > 0 && wl.isNotEmpty) {
        if (direction == Direction.horizontal) {
          wl.add(SizedBox(width: gap.toDouble(), height: 1));
        } else {
          wl.add(SizedBox(width: 1, height: gap.toDouble()));
        }
      }
      TextStyle style = textStyle;
      if (closed) {
        style = textClosedStyle;
      } else if (allowSelected) {
        style = selected ? textSelectedStyle : textStyle;
      }
      Widget child = Text(name, style: style);
      wl.add(child);
    }

    if (wl.isEmpty) {
      return null;
    }

    if (wl.length == 1) {
      return Container(
        constraints: constraints,
        margin: margin,
        padding: padding,
        child: wl[0],
      );
    }

    Widget child;

    if (direction == Direction.horizontal) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: wl,
      );
    } else {
      child = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: wl,
      );
    }

    return Container(
      constraints: constraints,
      margin: margin,
      padding: padding,
      child: child,
    );
  }
}
