import 'dart:ui';

import 'data_group.dart';

/// 所有表格渲染相关的基类表示
abstract class ChartRender {
  /// 在绘制前回调，可用于数据计算
  void onLayout(Rect rect);

  /// [rect] 可绘制区域
  void onDraw(Canvas canvas, Rect rect);
}

abstract class RenderFactory {
  ChartRender? obtainRender(ChartType type);
}

class DefaultRenderFactory implements RenderFactory {
  @override
  ChartRender? obtainRender(ChartType type) {
    return null;
  }

}
