import 'package:easy_chart/chart/core/data_group.dart';
import 'package:easy_chart/chart/core/gesture.dart';
import 'package:easy_chart/chart/options/axis.dart';
import 'package:easy_chart/chart/options/grid.dart';
import 'package:flutter/material.dart';

//所有坐标轴视图的基类
abstract class BaseAxisView<C extends BaseAxis> with GestureListener {
  C mainAxis; //主坐标轴相关的配置
  C crossAxis; //副坐标轴相关的配置

  List<ChartGrid> gridList = []; //表格相关的功能

  ///这两个不会影响坐标轴线的绘制，只会影响相关的Tick和MinorTick以及显示的区域数据
  double scaleRatio = 1; //缩放因子
  Offset scrollOffset = Offset.zero; // 滚动的偏移量
  late Size canvasSize; //画布的大小
  late Rect mainAxisPosition; // 主轴的位置
  late Rect crossAxisPosition; // 交叉轴位置

  BaseAxisView(this.mainAxis, this.crossAxis);

  /// 返回坐标轴主轴的大小，如果未知则使用[double.nan]来代替
  Size getMainAxisArea();

  /// 返回坐标轴副轴的大小等，如果未使用则使用[double.nan]来代替
  Size getCrossAxisArea();

  /// 坐标轴的类型
  AxisType getType();

  /// 用于进行坐标轴相关的测量
  @mustCallSuper
  void onMeasure(Size canvasSize) {
    this.canvasSize = Size.copy(canvasSize);
  }

  /// 布局当前坐标轴 主轴和副轴的位置
  @mustCallSuper
  void onLayout(Rect mainAxisPosition, Rect crossAxisPosition) {
    this.mainAxisPosition = mainAxisPosition;
    this.crossAxisPosition = crossAxisPosition;
  }

  /// 绘制坐标轴
  @mustCallSuper
  void onDraw(Canvas canvas) {}

  /// 当有触控或者鼠标相关的事件到达时，会调用该方法判断是否处理
  /// 返回true 表示处理,然后会调用[GestureListener]里的其它回调
  bool hitTest(Offset offset) {
    return false;
  }

  /// 给定一个数据集合，返回在该坐标轴下的对应的数据范围和每个数据的绘制位置(该方法一般只会在横轴上才会调用)
  List<DataPosition> computeViewportData(List<DataPoint> list);

  Size computeTextSize(String text, TextStyle style, double maxWidth) {
    if (text.isEmpty) {
      return Size.zero;
    }
    TextSpan span = TextSpan(text: text, style: style);
    TextPainter painter = TextPainter(text: span, textDirection: TextDirection.ltr);
    painter.layout(minWidth: 0, maxWidth: maxWidth);
    return painter.size;
  }
}

class DataPosition {
  final DataPoint data;
  late Rect position;

  DataPosition(this.data, this.position);
}
