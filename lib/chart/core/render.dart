import 'package:easy_chart/chart/component/axis/axis_view.dart';
import 'package:easy_chart/chart/options/axis.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:flutter/material.dart';
import 'chart_view.dart';
import 'data_group.dart';

/// 适用于二维笛卡尔坐标系的简单渲染器
/// 负责对数据的测量以及坐标轴相关刻度的计算
/// 折线图 、柱状图、散点图、K线图等
abstract class DescartesViewGroup<D extends DataGroup> extends ViewGroup {
  final List<D> dataList;
  final List<XAxis> xAxis;
  final List<YAxis> yAxis;
  final Map<XAxis, XAxisView> xAxisMap = {};
  final Map<YAxis, YAxisView> yAxisMap = {};
  Rect windowRect = Rect.zero; //记录Chart窗口的信息
  Offset scaleRatio = const Offset(1, 1);
  Offset scrollOffset = Offset.zero;

  DescartesViewGroup(this.dataList, this.xAxis, this.yAxis, List<View> viewList) {
    Set<String> ids = <String>{};
    for (var element in xAxis) {
      if (ids.contains(element.id)) {
        throw FlutterError("坐标轴ID 必须唯一");
      }
      ids.add(element.id);
      XAxisView view = XAxisView(element, dataList);
      xAxisMap[element] = view;
      addView1(view);
    }

    for (var element in yAxis) {
      if (ids.contains(element.id)) {
        throw FlutterError("坐标轴ID 必须唯一");
      }
      ids.add(element.id);
      YAxisView view = YAxisView(element, dataList);
      yAxisMap[element] = view;
      addView1(view);
    }
    for (var element in viewList) {
      addView1(element);
    }
  }

  @override
  void onMeasure(double parentWidth, double parentHeight) {
    super.onMeasure(parentWidth, parentHeight);
    xAxisMap.forEach((key, value) {
      value.onMeasure(parentWidth, parentHeight);
    });
    yAxisMap.forEach((key, value) {
      value.onMeasure(parentWidth, parentHeight);
    });
    double leftOffset = 0;
    double topOffset = 0;
    double rightOffset = 0;
    double bottomOffset = 0;

    // 统计总的轴范围区域
    for (var element in xAxis) {
      XAxisView view = xAxisMap[element]!;
      if (element.position == Position.top) {
        topOffset += view.height;
      } else {
        bottomOffset += view.height;
      }
    }
    for (var element in yAxis) {
      YAxisView view = yAxisMap[element]!;
      if (element.position == Position.right) {
        rightOffset += view.width;
      } else {
        leftOffset += view.width;
      }
    }

    windowRect = Rect.fromLTRB(leftOffset , topOffset , parentWidth - rightOffset , parentHeight - bottomOffset);

    for (var element in children) {
      element.onMeasure(windowRect.width, windowRect.height);
    }
  }

  @override
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    //对X轴进行布局
    double topOffset = 0;
    double bottomOffset = 0;
    for (var element in xAxis) {
      if (!element.show) {
        continue;
      }
      XAxisView view = xAxisMap[element]!;
      double left, top, right, bottom;
      left = windowRect.left;
      right = windowRect.right;
      if (element.position == Position.top) {
        top = windowRect.top - view.height - topOffset;
        bottom = top + view.height;
        topOffset += view.height;
      } else {
        top = windowRect.bottom + bottomOffset;
        bottom = top + view.height;
        bottomOffset += view.height;
      }
      view.onLayout(left, top, right, bottom);
    }
    //对Y轴进行布局
    double leftOffset = 0;
    double rightOffset = windowRect.right;
    for (var element in yAxis) {
      if (!element.show) {
        continue;
      }
      YAxisView view = yAxisMap[element]!;
      double left, right;
      if (element.position == Position.left) {
        left = leftOffset;
        right = left + view.width;
        leftOffset += view.width;
      } else {
        left = rightOffset;
        right = left + view.width;
        rightOffset += view.width;
      }
      view.onLayout(left, windowRect.top, right, windowRect.bottom);
    }

    for (var element in children) {
      if (element is XAxisView || element is YAxisView) {
        continue;
      }
      element.onLayout(windowRect.left, windowRect.top, windowRect.right, windowRect.bottom);
    }
  }
}

/// 适用于极坐标系的简单渲染器
/// 饼图、雷达图、旭日图 相关
class PolarChartRender<D extends DataGroup> extends ViewGroup {
  @override
  void draw(Canvas canvas, double animatorPercent) {}
}
