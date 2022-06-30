import 'dart:math';

import 'package:easy_chart/chart/core/chart_view.dart';
import 'package:easy_chart/chart/core/data_group.dart';
import 'package:easy_chart/chart/options/axis.dart';
import 'package:flutter/material.dart';

/// 笛卡尔坐标轴视图的基类
/// 使用时 必须先 call[onMeasure] -> call[onLayout]->call[draw]
abstract class BaseAxisView<T extends BaseAxis, D extends DataGroup> extends View {
  final T axis;
  final List<D> dataGroupList;

  ///这两个不会影响坐标轴线的绘制，只会影响相关的Tick和MinorTick以及显示的区域数据
  double scaleRatio = 1; //缩放因子
  Offset scrollOffset = Offset.zero; // 滚动的偏移量

  BaseAxisView(this.axis, this.dataGroupList);

  /// 坐标轴的类型
  AxisType getType();


  @override
  @mustCallSuper
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
  }

  bool get hasBounds;

}

class DataPosition {
  final DataPoint data;
  late Rect position;

  DataPosition(this.data, this.position);
}
