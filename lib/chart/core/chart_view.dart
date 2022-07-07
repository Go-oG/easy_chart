// ignore_for_file: constant_identifier_names

import 'dart:math';

import 'package:flutter/material.dart';

import 'gesture.dart';

class LayoutParams {
  static const int MATCH_PARENT = -1;
  static const int WRAP_CONTENT = -2;

  late int width;
  late int height;

  LayoutParams(this.width, this.height);

  LayoutParams.from(LayoutParams source) : this(source.width, source.height);

  void resolveLayoutDirection(int layoutDirection) {}

  static String sizeToString(int size) {
    if (size == WRAP_CONTENT) {
      return "wrap-content";
    }
    if (size == MATCH_PARENT) {
      return "match-parent";
    }
    return size.toString();
  }
}

abstract class ViewManager {
  void addView(View view, LayoutParams params);

  void updateViewLayout(View view, LayoutParams params);

  void removeView(View view);
}

abstract class ViewParent {
  void invalidate();

  void requestLayout();

  ViewParent? getParent();

  void requestChildFocus(View child, View focused);

  void recomputeViewAttributes(View child);

  void clearChildFocus(View child);

  bool getChildVisibleRect(View child, Rect r, Offset offset);

  void changeChildToFront(View child);

  void focusableViewAvailable(View v);
}

/// 所有Chart 组件的基类(例如坐标轴、绘制的图形)
abstract class View with GestureListener {
  static const int VISIBLE = 0;
  static const int INVISIBLE = 1;
  static const int GONE = 2;
  static const int LAYOUT_DIRECTION_RTL = 0;
  static const int LAYOUT_DIRECTION_LTR = 1;
  static const int TEXT_DIRECTION_RTL = 0;
  static const int TEXT_DIRECTION_LTR = 1;
  static const int NO_ID = 0;

  int id = NO_ID;

  Rect boundRect = const Rect.fromLTRB(0, 0, 0, 0);
  Rect? clipRect;

  @protected
  LayoutParams layoutParams = LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
  EdgeInsetsGeometry padding = EdgeInsets.zero;
  EdgeInsetsGeometry margin = EdgeInsets.zero;

  int visibility = VISIBLE;

  bool focusable = true;
  bool focused = false; //焦点

  bool enable = true;
  bool selected = false;

  bool hoverable = false;

  bool hovered = false;

  BoxDecoration backgroundStyle = const BoxDecoration(color: Colors.white);
  late BoxPainter _boxPainter;
  BoxDecoration? foregroundStyle;

  ViewParent? parent;

  int rawLayoutDirection = LAYOUT_DIRECTION_RTL; //水平布局方向
  int textDirection = TEXT_DIRECTION_LTR;

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

  View({Paint? paint}) {
    if (paint != null) {
      this.paint = paint;
    } else {
      this.paint = Paint();
    }
    _boxPainter = backgroundStyle.createBoxPainter();
  }

  @mustCallSuper
  void onMeasure(double parentWidth, double parentHeight) {
    boundRect = Rect.fromLTWH(0, 0, parentWidth, parentHeight);
  }

  @mustCallSuper
  void onLayout(double left, double top, double right, double bottom) {
    inLayout = true;
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
    onDraw(canvas, animatorPercent);
  }

  @protected
  void onDraw(Canvas canvas, double animatorPercent) {
    _boxPainter.paint(canvas, Offset.zero, ImageConfiguration(size: Size(width, height)));
  }

  //返回其矩形边界
  Rect get areaBounds => boundRect;

  bool hitTest(Offset position) {
    Rectangle rectangle = Rectangle(left, top, width, height);
    return rectangle.containsPoint(Point(position.dx, position.dy));
  }

  void invalidate() {
    parent?.invalidate();
  }

  void requestMeasure() {
    parent?.requestLayout();
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

  setLayoutParams(LayoutParams params) {
    layoutParams = params;
    //  resolveLayoutParams();
    if (parent is ViewGroup) {
      //    ( parent as ViewGroup).onSetLayoutParams(this, params);
    }
    requestLayout();
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

  LayoutParams getLayoutParams() {
    return layoutParams;
  }
}

/// ViewGroup
abstract class ViewGroup extends View implements ViewParent, ViewManager {
  final List<View> children = [];

  ViewGroup({super.paint});

  void clearChildren() {
    children.clear();
  }

  void addView1(View child) {
    addView2(child, -1);
  }

  void addView2(View child, int index) {
    LayoutParams? params = child.getLayoutParams();
    if (params == null) {
      params = generateDefaultLayoutParams();
      if (params == null) {
        throw FlutterError("generateDefaultLayoutParams() cannot return null  ");
      }
    }
    addView4(child, index, params);
  }

  void addView3(View child, int width, int height) {
    final LayoutParams params = generateDefaultLayoutParams();
    params.width = width;
    params.height = height;
    addView4(child, -1, params);
  }

  void addView4(View child, int index, LayoutParams params) {
    requestLayout();
    invalidate();
    _addViewInner(child, index, params, false);
  }

  @override
  void changeChildToFront(View child) {}

  @override
  void clearChildFocus(View child) {}

  @override
  void focusableViewAvailable(View v) {}

  @override
  bool getChildVisibleRect(View child, Rect r, Offset offset) {
    return false;
  }

  @override
  ViewParent? getParent() {
    return parent;
  }

  @override
  void draw(Canvas canvas, double animatorPercent) {
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
  }

  @override
  void recomputeViewAttributes(View child) {}

  @override
  void removeView(View view) {}

  @override
  void requestChildFocus(View child, View focused) {}

  @override
  void updateViewLayout(View view, LayoutParams params) {}

  @override
  void addView(View view, LayoutParams params) {
    addView4(view, -1, params);
  }

  LayoutParams generateDefaultLayoutParams() {
    return LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT);
  }

  void _addViewInner(View child, int index, LayoutParams params, bool preventRequestLayout) {
    if (child.parent != null) {
      throw FlutterError("The specified child already has a parent. " + "You must call removeView() on the child's parent first.");
    }
    if (preventRequestLayout) {
      child.layoutParams = params;
    } else {
      child.setLayoutParams(params);
    }

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
}
