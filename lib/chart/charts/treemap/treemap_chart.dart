import 'dart:math';

import 'package:easy_chart/chart/charts/treemap/treemap_layout_algorithm.dart';
import 'package:easy_chart/chart/charts/treemap/treemap_series.dart';
import 'package:easy_chart/chart/core/chart_view.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:easy_chart/chart/utils/paint_util.dart';
import 'package:flutter/material.dart';

class TreeMapChartView extends ViewGroup {
  final TreeMapSeries series;

  TreeMapChartView(this.series) {
    double data = 0;
    List<TreeMapData> list = [];
    series.dataList.sort((a, b) {
      return b.computeChildrenData().compareTo(a.computeChildrenData());
    });
    for (var element in series.dataList) {
      data += element.computeChildrenData();
      list.add(element);
    }

    TreeMapData mapData = TreeMapData(data, list, style: const ItemStyle(BoxDecoration(), color: Colors.transparent));
    TreeMapNodeView nodeView = TreeMapNodeView(mapData);
    addView(nodeView);
  }
}

class TreeMapNodeView extends ViewGroup {
  final TreeMapData data;

  TreeMapNodeView(this.data);

  @override
  void onLayout(double left, double top, double right, double bottom) {
    clearChildren();
    SquarifiedLayout layouter = SquarifiedLayout(data,width,height);
    List<TreeNode> list = layouter.layout(left, top, right, bottom);
    for (var node in list) {
      Rect rect=node.rect;
      TreeMapNodeView view=TreeMapNodeView(node.data);
      addView(view);
      view.measure(rect.width, rect.height);
      view.layout(rect.left, rect.top, rect.right,rect.bottom);
    }
  }

  @override
  void onDraw(Canvas canvas, double animatorPercent) {
    //透明色 不绘制
    if (data.style.color == Colors.transparent) {
      return;
    }
    paint.reset();
    paint.style = PaintingStyle.fill;
    paint.color = data.style.color;
    Rect rect = Rect.fromLTWH(0, 0, width, height);
    canvas.drawRect(rect, paint);

    TextPainter textPainter = TextPainter(
        text: TextSpan(text: '${data.data.toInt()}', style: TextStyle(color: Colors.black, fontSize: 15)),
        textDirection: TextDirection.ltr);
    textPainter.layout(maxWidth: width);
    textPainter.paint(canvas, Offset(centerX, centerY));
  }
}
