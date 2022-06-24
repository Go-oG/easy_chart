import 'package:easy_chart/chart/component/axis/axis_manager.dart';
import 'package:easy_chart/chart/options/animation.dart';
import 'package:easy_chart/chart/options/axis.dart';
import 'package:easy_chart/chart/options/base_config.dart';
import 'package:easy_chart/chart/options/legend.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:easy_chart/chart/options/title.dart' as chart;
import 'data_group.dart';
import 'gesture.dart';

class Chart<D extends DataGroup> extends StatefulWidget {
  final ChartConfig config;
  final List<BaseRender> renderList;

  const Chart(this.config, this.renderList, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChartState<D>();
  }
}

class ChartState<D extends DataGroup> extends State<Chart<D>> with TickerProviderStateMixin {
  late final MultiRender render;
  late AnimationController? _animationController;
  late Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    if (widget.config.animation.enable) {
      ChartAnimation animation = widget.config.animation;
      _animationController = AnimationController(vsync: this, duration: animation.duration, reverseDuration: animation.reverseDuration);
      _animation = CurvedAnimation(
        parent: _animationController!,
        curve: animation.curve,
      );
    }

    //注入动画
    for (var element in widget.renderList) {
      element._animation = element.obtainAnimation(this);
    }

    render = MultiRender(widget.renderList, animation: _animation);
  }

  @override
  Widget build(BuildContext context) {
    ChartConfig config = widget.config;
    List<Widget> wl = [];
    chart.ChartTitle? title = config.title;
    Legend? legend = config.legend;

    //构建Title
    Widget? titleWidget = title?.obtainWidget();
    //构建图例
    Widget? legendWidget = legend?.obtainWidget();

    // 判断是否需要添加顶部的相关控件
    if (title != null && titleWidget != null) {
      Alignment? alignment;
      if (title.position == ChartAlign.topLeft || title.position == ChartAlign.auto) {
        alignment = Alignment.topLeft;
      } else if (title.position == ChartAlign.topCenter) {
        alignment = Alignment.topCenter;
      } else if (title.position == ChartAlign.topRight) {
        alignment = Alignment.topRight;
      }

      if (alignment != null) {
        Widget child = Container(
          width: double.infinity,
          alignment: alignment,
          child: titleWidget,
        );
        wl.add(child);
      }
    }
    if (legend != null && legendWidget != null) {
      Alignment? alignment;
      if (legend.position == ChartAlign.topLeft || legend.position == ChartAlign.auto) {
        alignment = Alignment.topLeft;
      } else if (legend.position == ChartAlign.topCenter) {
        alignment = Alignment.topCenter;
      } else if (legend.position == ChartAlign.topRight) {
        alignment = Alignment.topRight;
      }
      if (alignment != null) {
        Widget child = Container(
          width: double.infinity,
          alignment: alignment,
          child: legendWidget,
        );
        wl.add(child);
      }
    }

    List<Widget> contentList = [];

    List<Widget> columns = [];
    if (title != null && titleWidget != null) {
      Alignment? alignment;
      if (title.position == ChartAlign.leftTop) {
        alignment = Alignment.topRight;
      } else if (title.position == ChartAlign.leftBottom) {
        alignment = Alignment.bottomRight;
      } else if (title.position == ChartAlign.leftCenter) {
        alignment = Alignment.centerRight;
      }
      if (alignment != null) {
        Widget child = Expanded(
            child: Container(
          height: double.infinity,
          alignment: alignment,
          child: titleWidget,
        ));
        columns.add(child);
      }
    }
    if (legend != null && legendWidget != null) {
      Alignment? alignment;
      if (legend.position == ChartAlign.leftTop) {
        alignment = Alignment.topRight;
      } else if (legend.position == ChartAlign.leftCenter) {
        alignment = Alignment.centerRight;
      } else if (legend.position == ChartAlign.leftBottom) {
        alignment = Alignment.bottomRight;
      }

      Widget child = Expanded(
          child: Container(
        height: double.infinity,
        alignment: alignment,
        child: legendWidget,
      ));
      columns.add(child);
    }
    contentList.add(Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columns,
    ));

    //中间区域
    contentList.add(Expanded(
        child: SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: _buildPainter(config),
    )));

    List<Widget> columns2 = [];
    if (title != null && titleWidget != null) {
      Alignment? alignment;
      if (title.position == ChartAlign.rightTop) {
        alignment = Alignment.topLeft;
      } else if (title.position == ChartAlign.rightBottom) {
        alignment = Alignment.bottomLeft;
      } else if (title.position == ChartAlign.rightCenter) {
        alignment = Alignment.centerLeft;
      }
      if (alignment != null) {
        Widget child = Expanded(
            child: Container(
          height: double.infinity,
          alignment: alignment,
          child: titleWidget,
        ));
        columns2.add(child);
      }
    }
    if (legend != null && legendWidget != null) {
      Alignment? alignment;
      if (legend.position == ChartAlign.rightTop) {
        alignment = Alignment.topLeft;
      } else if (legend.position == ChartAlign.rightCenter) {
        alignment = Alignment.centerLeft;
      } else if (legend.position == ChartAlign.rightBottom) {
        alignment = Alignment.bottomLeft;
      }
      Widget child = Expanded(
          child: Container(
        height: double.infinity,
        alignment: alignment,
        child: legendWidget,
      ));
      columns2.add(child);
    }
    if (columns2.isNotEmpty) {
      contentList.add(Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: columns2,
      ));
    }

    wl.add(Expanded(
        child: Row(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: contentList,
    )));

    // 底部区域
    List<Widget> bottomList = [];
    if (legend != null && legendWidget != null) {
      Alignment? alignment;
      if (legend.position == ChartAlign.bottomLeft) {
        alignment = Alignment.centerLeft;
      } else if (legend.position == ChartAlign.bottomRight) {
        alignment = Alignment.centerRight;
      } else if (legend.position == ChartAlign.bottomCenter) {
        alignment = Alignment.center;
      }

      if (alignment != null) {
        Widget child = Container(
          width: double.infinity,
          alignment: alignment,
          child: legendWidget,
        );
        bottomList.add(child);
      }
    }
    if (title != null && titleWidget != null) {
      Alignment? alignment;
      if (title.position == ChartAlign.bottomLeft) {
        alignment = Alignment.centerLeft;
      } else if (title.position == ChartAlign.bottomCenter) {
        alignment = Alignment.center;
      } else if (title.position == ChartAlign.bottomRight) {
        alignment = Alignment.centerRight;
      }

      if (alignment != null) {
        Widget child = Container(
          width: double.infinity,
          alignment: alignment,
          child: titleWidget,
        );
        bottomList.add(child);
      }
    }
    if (bottomList.isNotEmpty) {
      wl.add(Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: bottomList,
      ));
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: config.decoration,
      margin: config.margin,
      padding: config.padding,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: wl,
      ),
    );
  }

  Widget _buildPainter(ChartConfig config) {
    GestureTapDownCallback? onTapDown = render.onTapDown;
    GestureTapUpCallback? onTapUp = render.onTapUp;
    GestureTapCallback? onTap = render.onTap;
    GestureTapCancelCallback? onTapCancel = render.onTapCancel;
    GestureTapCallback? onSecondaryTap = render.onSecondaryTap;
    GestureTapDownCallback? onSecondaryTapDown = render.onSecondaryTapDown;
    GestureTapUpCallback? onSecondaryTapUp = render.onSecondaryTapUp;
    GestureTapCancelCallback? onSecondaryTapCancel = render.onSecondaryTapCancel;
    GestureTapDownCallback? onTertiaryTapDown = render.onTertiaryTapDown;
    GestureTapUpCallback? onTertiaryTapUp = render.onTertiaryTapUp;
    GestureTapCancelCallback? onTertiaryTapCancel = render.onTertiaryTapCancel;
    GestureTapDownCallback? onDoubleTapDown = render.onDoubleTapDown;
    GestureTapCallback? onDoubleTap = render.onDoubleTap;
    GestureTapCancelCallback? onDoubleTapCancel = render.onDoubleTapCancel;
    GestureLongPressDownCallback? onLongPressDown = render.onLongPressDown;
    GestureLongPressCancelCallback? onLongPressCancel = render.onLongPressCancel;
    GestureLongPressCallback? onLongPress = render.onLongPress;
    GestureLongPressStartCallback? onLongPressStart = render.onLongPressStart;
    GestureLongPressMoveUpdateCallback? onLongPressMoveUpdate = render.onLongPressMoveUpdate;
    GestureLongPressUpCallback? onLongPressUp = render.onLongPressUp;
    GestureLongPressEndCallback? onLongPressEnd = render.onLongPressEnd;
    GestureLongPressDownCallback? onSecondaryLongPressDown = render.onSecondaryLongPressDown;
    GestureLongPressCancelCallback? onSecondaryLongPressCancel = render.onSecondaryLongPressCancel;
    GestureLongPressCallback? onSecondaryLongPress = render.onSecondaryLongPress;
    GestureLongPressStartCallback? onSecondaryLongPressStart = render.onSecondaryLongPressStart;
    GestureLongPressMoveUpdateCallback? onSecondaryLongPressMoveUpdate = render.onSecondaryLongPressMoveUpdate;
    GestureLongPressUpCallback? onSecondaryLongPressUp = render.onSecondaryLongPressUp;
    GestureLongPressEndCallback? onSecondaryLongPressEnd = render.onSecondaryLongPressEnd;
    GestureLongPressDownCallback? onTertiaryLongPressDown = render.onTertiaryLongPressDown;
    GestureLongPressCancelCallback? onTertiaryLongPressCancel = render.onTertiaryLongPressCancel;
    GestureLongPressCallback? onTertiaryLongPress = render.onTertiaryLongPress;
    GestureLongPressStartCallback? onTertiaryLongPressStart = render.onTertiaryLongPressStart;
    GestureLongPressMoveUpdateCallback? onTertiaryLongPressMoveUpdate = render.onTertiaryLongPressMoveUpdate;
    GestureLongPressUpCallback? onTertiaryLongPressUp = render.onTertiaryLongPressUp;
    GestureLongPressEndCallback? onTertiaryLongPressEnd = render.onTertiaryLongPressEnd;
    // GestureDragDownCallback? onVerticalDragDown = render.onVerticalDragDown;
    // GestureDragStartCallback? onVerticalDragStart = render.onVerticalDragStart;
    // GestureDragUpdateCallback? onVerticalDragUpdate = render.onVerticalDragUpdate;
    // GestureDragEndCallback? onVerticalDragEnd = render.onVerticalDragEnd;
    // GestureDragCancelCallback? onVerticalDragCancel = render.onVerticalDragCancel;
    // GestureDragDownCallback? onHorizontalDragDown = render.onHorizontalDragDown;
    // GestureDragStartCallback? onHorizontalDragStart = render.onHorizontalDragStart;
    // GestureDragUpdateCallback? onHorizontalDragUpdate = render.onHorizontalDragUpdate;
    // GestureDragEndCallback? onHorizontalDragEnd = render.onHorizontalDragEnd;
    // GestureDragCancelCallback? onHorizontalDragCancel = render.onHorizontalDragCancel;
    // GestureDragDownCallback? onPanDown = render.onPanDown;
    // GestureDragStartCallback? onPanStart = render.onPanStart;
    // GestureDragUpdateCallback? onPanUpdate = render.onPanUpdate;
    // GestureDragEndCallback? onPanEnd = render.onPanEnd;
    // GestureDragCancelCallback? onPanCancel = render.onPanCancel;

    GestureScaleStartCallback? onScaleStart = render.onScaleStart;
    GestureScaleUpdateCallback? onScaleUpdate = render.onScaleUpdate;
    GestureScaleEndCallback? onScaleEnd = render.onScaleEnd;
    GestureForcePressStartCallback? onForcePressStart = render.onForcePressStart;
    GestureForcePressPeakCallback? onForcePressPeak = render.onForcePressPeak;
    GestureForcePressUpdateCallback? onForcePressUpdate = render.onForcePressUpdate;
    GestureForcePressEndCallback? onForcePressEnd = render.onForcePressEnd;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: onTapDown,
      onTapUp: onTapUp,
      onTap: onTap,
      onTapCancel: onTapCancel,
      onSecondaryTap: onSecondaryTap,
      onSecondaryTapDown: onSecondaryTapDown,
      onSecondaryTapUp: onSecondaryTapUp,
      onSecondaryTapCancel: onSecondaryTapCancel,
      onTertiaryTapDown: onTertiaryTapDown,
      onTertiaryTapUp: onTertiaryTapUp,
      onTertiaryTapCancel: onTertiaryTapCancel,
      onDoubleTapDown: onDoubleTapDown,
      onDoubleTap: onDoubleTap,
      onDoubleTapCancel: onDoubleTapCancel,
      onLongPressDown: onLongPressDown,
      onLongPressCancel: onLongPressCancel,
      onLongPress: onLongPress,
      onLongPressStart: onLongPressStart,
      onLongPressMoveUpdate: onLongPressMoveUpdate,
      onLongPressUp: onLongPressUp,
      onLongPressEnd: onLongPressEnd,
      onSecondaryLongPressDown: onSecondaryLongPressDown,
      onSecondaryLongPressCancel: onSecondaryLongPressCancel,
      onSecondaryLongPress: onSecondaryLongPress,
      onSecondaryLongPressStart: onSecondaryLongPressStart,
      onSecondaryLongPressMoveUpdate: onSecondaryLongPressMoveUpdate,
      onSecondaryLongPressUp: onSecondaryLongPressUp,
      onSecondaryLongPressEnd: onSecondaryLongPressEnd,
      onTertiaryLongPressDown: onTertiaryLongPressDown,
      onTertiaryLongPressCancel: onTertiaryLongPressCancel,
      onTertiaryLongPress: onTertiaryLongPress,
      onTertiaryLongPressStart: onTertiaryLongPressStart,
      onTertiaryLongPressMoveUpdate: onTertiaryLongPressMoveUpdate,
      onTertiaryLongPressUp: onTertiaryLongPressUp,
      onTertiaryLongPressEnd: onTertiaryLongPressEnd,
      // onVerticalDragDown: onVerticalDragDown,
      // onVerticalDragStart: onVerticalDragStart,
      // onVerticalDragUpdate: onVerticalDragUpdate,
      // onVerticalDragEnd: onVerticalDragEnd,
      // onVerticalDragCancel: onVerticalDragCancel,
      // onHorizontalDragDown: onHorizontalDragDown,
      // onHorizontalDragStart: onHorizontalDragStart,
      // onHorizontalDragUpdate: onHorizontalDragUpdate,
      // onHorizontalDragEnd: onHorizontalDragEnd,
      // onHorizontalDragCancel: onHorizontalDragCancel,
      onForcePressStart: onForcePressStart,
      onForcePressPeak: onForcePressPeak,
      onForcePressUpdate: onForcePressUpdate,
      onForcePressEnd: onForcePressEnd,
      // onPanDown: onPanDown,
      // onPanStart: onPanStart,
      // onPanUpdate: onPanUpdate,
      // onPanEnd: onPanEnd,
      // onPanCancel: onPanCancel,
      onScaleStart: onScaleStart,
      onScaleUpdate: onScaleUpdate,
      onScaleEnd: onScaleEnd,
      child: CustomPaint(painter: render),
    );
  }
}

/// 渲染的基类，支持多个Render 同时渲染
class MultiRender extends ChangeNotifier with GestureListener implements CustomPainter {
  final Animation<double>? animation; //全局
  final List<BaseRender> renderList;

  //记录图表占用区域的范围
  Rect chartRect = const Rect.fromLTRB(0, 0, 0, 0);

  MultiRender(this.renderList, {this.animation}) {
    if (animation != null) {
      animation?.addListener(() {
        notifyListeners();
      });
    }

    for (var element in renderList) {
      element._refresh = updateUI;
      element.onInit();
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    //先测量 获取各个Render的尺寸信息
    for (var element in renderList) {
      element.onMeasure(size);
    }
    //再绘制
    for (var element in renderList) {
      element.onDraw(canvas);
    }
  }

  @override
  bool? hitTest(Offset position) {
    for (var element in renderList) {
      if (element.hitTest(position)) {
        return true;
      }
    }
    return false;
  }

  @override
  SemanticsBuilderCallback? get semanticsBuilder => null;

  @override
  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) {
    return true;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    for (var element in renderList) {
      if (element.shouldRepaint()) {
        return true;
      }
    }
    return false;
  }

  void updateUI() {
    notifyListeners();
  }
}

/// 图表渲染器，负责整个视图的渲染
/// 由于单独的一个Render占据整个画布，因此没有布局时是占满整个区域的，因此没有onLayout 方法
/// 整个Render 包含坐标轴和图表区

abstract class BaseRender with GestureListener {
  VoidCallback? _refresh;
  late Size canvasSize;
  late AxisManager axisManager; //坐标轴管理工具
  Animation<double>? _animation;


  @mustCallSuper
  void onInit() {
    _animation?.addListener(updateUI);
    axisManager=AxisManager();
  }

  Animation<double>? obtainAnimation(TickerProvider vsync) {
    return null;
  }

  @mustCallSuper
  void onMeasure(Size canvasSize) {
    this.canvasSize = canvasSize;
  }

  void onDraw(Canvas canvas);

  void updateUI() {
    _refresh?.call();
  }

  bool hitTest(Offset position) {
    return false;
  }

  bool shouldRepaint() {
    return true;
  }
}

/// 适用于二维笛卡尔坐标系的简单渲染器
class SimpleRender<C extends BaseAxis, D extends DataGroup> extends BaseRender {
  @override
  void onDraw(Canvas canvas) {}

  @override
  void onMeasure(Size canvasSize) {
    super.onMeasure(canvasSize);
  }
}
