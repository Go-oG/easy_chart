import 'dart:math';

import 'package:flutter/material.dart';

import 'gesture.dart';

abstract class ViewManager {
  void addView(View view);

  void removeView(View view);
}

abstract class ViewParent {
  void invalidate();

  void requestLayout();

  ViewParent? getParent();

  void clearChildFocus(View child);

  bool getChildVisibleRect(View child, Rect r, Offset offset);

  void changeChildToFront(View child);

  void focusableViewAvailable(View v);
}

/// 所有Chart 组件的基类(例如坐标轴、绘制的图形)
abstract class View with GestureListener {
  static const int visible = 0;
  static const int inVisible = 1;
  static const int gone = 2;

  static const int LAYOUT_DIRECTION_RTL = 0;
  static const int LAYOUT_DIRECTION_LTR = 1;

  static const int noId = 0;

  int id = noId;

  Rect boundRect = const Rect.fromLTRB(0, 0, 0, 0);
  Rect oldBoundRect = const Rect.fromLTRB(0, 0, 0, 0); //记录旧的边界位置，实现动画相关的计算
  Rect? clipRect;

  EdgeInsetsGeometry padding = EdgeInsets.zero;
  EdgeInsetsGeometry margin = EdgeInsets.zero;

  int visibility = visible;

  bool focusable = true;
  bool focused = false; //焦点

  bool enable = true;
  bool selected = false;

  bool hoverable = false;
  bool hovered = false;

  BoxDecoration? backgroundStyle;
  BoxPainter? _boxPainter;

  BoxDecoration? foregroundStyle;
  BoxPainter? _foregroundPainter;

  ViewParent? parent;

  int rawLayoutDirection = LAYOUT_DIRECTION_RTL; //水平布局方向

  Offset? _pivot; //存储旋转、缩放、等的中心点位置 没有设置则为视图中心
  Offset rotation = Offset.zero; //旋转
  Offset scale = Offset.zero; //缩放
  Offset scroll = Offset.zero; // 滚动
  Offset translation = Offset.zero; // 平移
  bool clickable = true;
  bool inLayout = false;

  bool _dirty = false; // 标记视图区域是否 需要重绘

  double alpha = 1;
  String? tooltip;

  late Paint paint;
  int zIndex = 0;

  View({Paint? paint, this.zIndex = 0}) {
    if (paint != null) {
      this.paint = paint;
    } else {
      this.paint = Paint();
    }
    if (backgroundStyle != null) {
      _boxPainter = backgroundStyle!.createBoxPainter();
    }
    if (foregroundStyle != null) {
      _foregroundPainter = foregroundStyle!.createBoxPainter();
    }
  }

  @mustCallSuper
  void onMeasure(double parentWidth, double parentHeight) {
    oldBoundRect = boundRect;
    boundRect = Rect.fromLTWH(0, 0, parentWidth, parentHeight);
  }

  @mustCallSuper
  void onLayout(double left, double top, double right, double bottom) {
    inLayout = true;
    oldBoundRect = boundRect;
    boundRect = Rect.fromLTRB(left, top, right, bottom);
  }

  @mustCallSuper
  void onLayoutEnd() {
    inLayout = false;
  }

  double get width => boundRect.width;

  double get height => boundRect.height;

  // 返回当前View在父Parent中的位置坐标
  double get left => boundRect.left;

  double get top => boundRect.top;

  double get right => boundRect.right;

  double get bottom => boundRect.bottom;

  // 返回自身的中心点坐标
  double get centerX => width / 2.0;

  double get centerY => height / 2.0;

  void draw(Canvas canvas, double animatorPercent) {
    ImageConfiguration configuration = ImageConfiguration(size: Size(width, height));
    _boxPainter?.paint(canvas, Offset.zero, configuration);
    onDraw(canvas, animatorPercent);
    _foregroundPainter?.paint(canvas, Offset.zero, configuration);
  }

  void onDraw(Canvas canvas, double animatorPercent) {}

  //返回其矩形边界
  Rect get areaBounds => boundRect;

  bool hitTest(Offset position) {
    Rectangle rectangle = Rectangle(left, top, width, height);
    return rectangle.containsPoint(Point(position.dx, position.dy));
  }

  void invalidate() {
    parent?.invalidate();
  }

  void requestLayout() {
    parent?.requestLayout();
  }

  void markDirty() {
    _dirty = true;
  }

  void clearDirty() {
    _dirty = false;
  }

  void onAnimationStart() {}

  void onAnimationEnd() {}

  void resetPivot() {
    _pivot = null;
  }

  set pivot(Offset pivot) {
    _pivot = pivot;
  }

  Offset? getPivot() {
    return _pivot;
  }

  void scrollTo(double x, double y) {
    if (scroll.dx != x || scroll.dy != y) {
      double oldX = scroll.dx;
      double oldY = scroll.dy;
      scroll = Offset(x, y);
      onScrollChanged(x, y, oldX, oldY);
    }
  }

  void scrollBy(int x, int y) {
    scrollTo(scroll.dx + x, scroll.dy + y);
  }

  void onScrollChanged(double l, double t, double oldl, double oldt) {}
}

/// ViewGroup
abstract class ViewGroup extends View implements ViewParent, ViewManager {
  final List<View> children = [];

  ViewGroup({super.paint, super.zIndex});

  @override
  void changeChildToFront(View child) {
    int index = children.indexOf(child);
    if (index != -1) {
      children.removeAt(index);
    }
    _addViewInner(child, -1);
    requestLayout();
  }

  @override
  void clearChildFocus(View child) {
    child.focused = false;
    invalidate();
  }

  @override
  void focusableViewAvailable(View v) {
    v.focusable = true;
    v.focused = true;
    invalidate();
  }

  @override
  bool getChildVisibleRect(View child, Rect r, Offset offset) {
    return false;
  }

  @override
  ViewParent? getParent() {
    return parent;
  }

  @override
  @mustCallSuper
  void onMeasure(double parentWidth, double parentHeight) {
    super.onMeasure(parentWidth, parentHeight);
    for (var element in children) {
      element.onMeasure(parentWidth, parentHeight);
    }
  }

  @override
  @mustCallSuper
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    for (var element in children) {
      element.onLayout(left, top, right, bottom);
    }
  }

  @override
  @mustCallSuper
  void onLayoutEnd() {
    super.onLayoutEnd();
    for (var element in children) {
      element.onLayoutEnd();
    }
  }

  @override
  void draw(Canvas canvas, double animatorPercent) {
    ImageConfiguration configuration = ImageConfiguration(size: Size(width, height));
    _boxPainter?.paint(canvas, Offset.zero, configuration);
    onDraw(canvas, animatorPercent);

    for (var element in children) {
      int count = canvas.getSaveCount();
      canvas.save();
      canvas.translate(element.left, element.top);
      element.draw(canvas, animatorPercent);
      canvas.clipRect(Rect.fromLTWH(0, 0, width, height));
      canvas.restore();
      if (canvas.getSaveCount() != count) {
        throw FlutterError('you should call canvas.restore when after call canvas.save');
      }
    }

    _foregroundPainter?.paint(canvas, Offset.zero, configuration);
  }

  @override
  void removeView(View view) {
    children.remove(view);
  }

  @override
  void addView(View view) {
    addView2(view, -1);
  }

  View getView(int index){
    return children[index];
  }

  void addView2(View child, int index) {
    _addViewInner(child, index);
    requestLayout();
  }

  void _addViewInner(View child, int index) {
    if (child.parent != null) {
      throw FlutterError("The specified child already has a parent. You must call removeView() on the child's parent first.");
    }
    child.parent = this;
    _addInArray(child, index);
  }

  void _addInArray(View child, int index) {
    if (index >= children.length || index < 0 || children.isEmpty) {
      children.add(child);
      return;
    }
    List<View> first = List.from(children.getRange(
      0,
      index,
    ));
    List<View> end = List.from(children.getRange(index, children.length));

    children.clear();
    children.addAll(first);
    children.add(child);
    children.addAll(end);
  }

  void clearChildren() {
    children.clear();
  }


}
