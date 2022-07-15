import 'package:easy_chart/chart/charts/bar/bar_data.dart';
import 'package:easy_chart/chart/charts/bar/bar_line_view.dart';
import 'package:easy_chart/chart/core/core_chart.dart';
import 'package:easy_chart/chart/core/render.dart';
import 'package:flutter/material.dart';

class LineChart extends Chart {
  final List<BarGroup> data;

  LineChart(super.config, this.data, {Key? key}) : super(key: key) {
    renderList.clear();
    renderList.add(LineRender(data, config.xAxis, config.yAxis, [BarLineChartView(config.xAxis[0], config.yAxis[0], data)]));
  }
}

class LineRender extends DescartesViewGroup {
  LineRender(super.dataList, super.xAxis, super.yAxis, super.viewList);
}
