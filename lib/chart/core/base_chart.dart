import 'package:easy_chart/chart/component/axis_view.dart';
import 'package:easy_chart/chart/options/animation.dart';
import 'package:easy_chart/chart/options/base_config.dart';
import 'package:easy_chart/chart/options/legend.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'package:easy_chart/chart/options/title.dart' as chart;
import 'package:easy_chart/chart/options/axis.dart' as chart;

import 'data_group.dart';
import 'gesture.dart';

abstract class BaseChart<C extends BaseConfig, D extends DataGroup> extends StatefulWidget {
  final C config;

  const BaseChart(this.config, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return BaseChartState<C, D>();
  }

  BaseChartRender<C,D> obtainRender(C config, Animation<double>? animation);
}

class BaseChartState<C extends BaseConfig, D extends DataGroup> extends State<BaseChart<C, D>> with TickerProviderStateMixin {
  late final BaseChartRender render;
  late AnimationController? _animationController;
  late Animation<double>? _animation;

  BaseChartState();

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

    render = widget.obtainRender(widget.config, _animation);
  }

  @override
  Widget build(BuildContext context) {
    BaseConfig config = widget.config;
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

  Widget _buildPainter(BaseConfig config) {
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

/// 适用笛卡尔坐标系下的Chart基类
abstract class BaseChartRender<C extends BaseConfig, D extends DataGroup> extends ChangeNotifier
    with GestureListener
    implements CustomPainter {
  final C config;
  final List<D> dataList;
  final Animation<double>? animation;
  late AxisView axisView;

  //记录图表占用区域的范围
  Rect chartRect = const Rect.fromLTRB(0, 0, 0, 0);

  BaseChartRender(this.config, this.dataList, {this.animation}) {
    if (animation != null) {
      animation?.addListener(() {
        notifyListeners();
      });
    }
    axisView = AxisView(config);
  }

  @override
  void paint(Canvas canvas, Size size) {
    onDraw(canvas, size);
  }

  void onDraw(Canvas canvas, Size size);

  @override
  bool? hitTest(Offset position) {
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
    return true;
  }

  void updateUI() {
    notifyListeners();
  }

  ///获取可用的坐标轴数量
  List<chart.Axis> getCanUseXAxis() {
    List<chart.Axis> list = [];
    for (var element in config.xAxis) {
      if (element.show) {
        list.add(element);
      }
    }
    return list;
  }

  List<chart.Axis> getCanUseYAxis() {
    List<chart.Axis> list = [];
    for (var element in config.yAxis) {
      if (element.show) {
        list.add(element);
      }
    }
    return list;
  }
}
