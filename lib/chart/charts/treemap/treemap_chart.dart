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
    for (var element in series.dataList) {
      data += element.data;
      list.add(element);
    }
    TreeMapData mapData = TreeMapData(data, list, style: const ItemStyle(BoxDecoration(), color: Colors.transparent));
    TreeMapNodeView nodeView = TreeMapNodeView(mapData, series.algorithm, 0);
    addView(nodeView);
  }
}

class TreeMapNodeView extends ViewGroup {
  final TreeMapData data;
  final TreemapLayoutAlgorithm algorithm;
  final int deepLevel;

  TreeMapNodeView(this.data, this.algorithm, this.deepLevel);

  @override
  void onLayout(double left, double top, double right, double bottom) {
    clearChildren();
    List<TreeNode> list = obtainLayout(data, width, height, deepLevel).layout(left, top, right, bottom);
    for (var node in list) {
      Rect rect = node.rect;
      TreeMapNodeView view = TreeMapNodeView(node.data, algorithm, deepLevel + 1);
      addView(view);
      view.measure(rect.width, rect.height);
      view.layout(rect.left, rect.top, rect.right, rect.bottom);
    }
  }

  TreemapLayout obtainLayout(TreeMapData data, double width, double height, int deepLevel) {
    if (algorithm == TreemapLayoutAlgorithm.dice) {
      return DiceLayout(data, width, height);
    }
    if (algorithm == TreemapLayoutAlgorithm.slice) {
      return SliceLayout(data, width, height);
    }
    if (algorithm == TreemapLayoutAlgorithm.sliceDice) {
      return SliceDiceLayout(data, width, height, deepLevel);
    }
    if (algorithm == TreemapLayoutAlgorithm.binary) {
      return BinaryLayout(data, width, height);
    }
    return SquareLayout(data, width, height);
  }

  @override
  void onDraw(Canvas canvas, double animatorPercent) {
    //有孩子则不绘制自身
    if (data.childrenList.isNotEmpty) {
      return;
    }

    paint.reset();
    paint.style = PaintingStyle.fill;
    paint.color = data.style.color;
    Rect rect = Rect.fromLTWH(0, 0, width, height);
    canvas.drawRect(rect, paint);

    TextPainter textPainter = TextPainter(
        text: TextSpan(text: '${data.data.toInt()}', style: TextStyle(color: Colors.white, fontSize: 12)),
        textDirection: TextDirection.ltr);
    textPainter.layout(maxWidth: width);
    textPainter.paint(canvas, Offset(centerX - textPainter.width / 2, centerY - textPainter.height / 2));
  }
}
