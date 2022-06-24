import 'package:easy_chart/chart/charts/line/line_data.dart';
import 'package:easy_chart/chart/core/base_chart.dart';
import 'package:flutter/material.dart';


class LineRender extends BaseRender {
  final List<LineGroup> windowDataList = []; //只存储窗口范围内的数据
  double scrollOffset = 0; // 水平滚动偏移量
  double scaleRatio = 1;


  LineRender(super.config, super.dataList, {super.animation});

  @override
  void onDraw(Canvas canvas, Size size) {
    axisView.onMeasure(size, scaleRatio, Offset(scrollOffset, 0), List.from(dataList.map((e) => e)));
    axisView.drawAxis(canvas);

    Rect rect = axisView.chartBoundRect;
    Paint paint = Paint();
    paint.style = PaintingStyle.fill;
    paint.color = Colors.teal;
    canvas.drawRect(rect, paint);
  }
}
