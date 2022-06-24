//轴刻度
import 'style.dart';

class AxisTick {
  bool show = true;
  bool alignLabel = true;

  ///坐标轴刻度的显示间隔
  ///-1为默认
  /// 在类目轴中有效 0 强制显示所有标签
  /// 如果设置为 1，表示『隔一个标签显示一个标签』
  /// 如果值为 2，表示隔两个标签显示一个标签，以此类推
  int interval = -1;


  double length = 4;

  LineStyle style = LineStyle();
}

class MinorTick {
  bool show = false;
  int splitNumber = 5;
  double length = 3;
  LineStyle style = LineStyle();
}