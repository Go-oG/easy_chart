import 'dart:math';

import 'package:easy_chart/chart/core/chart_view.dart';
import 'package:easy_chart/chart/options/label.dart';
import 'package:easy_chart/chart/options/string_number.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:easy_chart/chart/utils/paint_util.dart';
import 'package:flutter/material.dart';

import 'funnel_series.dart';

/// 漏斗图
class FunnelChartView extends ViewGroup {
  final FunnelSeries series;
  late final double maxData;
  late final double minData;

  FunnelChartView(
    this.series, {
    double? maxData,
    double? minData,
    super.paint,
    super.zIndex,
  }) {
    //按照由小到大排序
    series.dataList.sort((a, b) {
      return a.data.compareTo(b.data);
    });

    if (series.dataList.isNotEmpty) {
      double tmp = series.dataList[0].data;
      double minTmp = series.dataList[0].data;
      for (var element in series.dataList) {
        if (element.data > tmp) {
          tmp = element.data;
        }
        if (element.data < minTmp) {
          minTmp = element.data;
        }
      }

      if (maxData != null) {
        this.maxData = max(tmp, maxData);
      } else {
        this.maxData = tmp;
      }

      if (minData != null) {
        this.minData = min(minTmp, minData);
      } else {
        this.minData = minTmp;
      }
    } else {
      this.maxData = 100;
      this.minData = 0;
    }

    for (int i = 0; i < series.dataList.length; i++) {
      FunnelData data = series.dataList[i];
      FunnelData? preData;
      if (i > 0) {
        preData = series.dataList[i - 1];
      }
      FunnelChildView childView = FunnelChildView(data, preData, series.gap,
          minData: this.minData,
          maxData: this.maxData,
          minSize: series.minSize,
          maxSize: series.maxSize,
          direction: series.direction,
          sortAsc: series.sortAsc,
          funnelAlign: series.funnelAlign,
          legendHoverLink: series.legendHoverLink,
          animator: series.animator,
          animatorDirection: series.animatorDirection);
      addView(childView);
    }
  }

  @override
  @mustCallSuper
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    if (series.dataList.length != children.length) {
      throw FlutterError('状态异常');
    }

    if (series.direction == Direction.horizontal) {
      _layoutHorizontal(left, top, right, bottom);
    } else {
      _layoutVertical(left, top, right, bottom);
    }
  }

  void _layoutVertical(double left, double top, double right, double bottom) {
    double gapAllHeight = (series.dataList.length - 1) * series.gap;
    double itemHeight = (height - gapAllHeight) / series.dataList.length;
    double offsetY = series.sortAsc ? 0 : height;
    for (int i = 0; i < children.length; i++) {
      FunnelChildView view = children[i] as FunnelChildView;
      if (series.sortAsc) {
        view.measure(width, itemHeight);
        view.layout(0, offsetY, width, offsetY + itemHeight);
        offsetY += itemHeight;
        offsetY += series.gap;
      } else {
        view.measure(width, itemHeight);
        view.layout(0, offsetY - itemHeight, width, offsetY);
        offsetY -= itemHeight;
        offsetY -= series.gap;
      }
    }
  }

  void _layoutHorizontal(double left, double top, double right, double bottom) {
    double gapAllWidth = (series.dataList.length - 1) * series.gap;
    double itemWidth = (width - gapAllWidth) / series.dataList.length;
    double offsetX = series.sortAsc ? 0 : width;
    for (int i = 0; i < children.length; i++) {
      FunnelChildView view = children[i] as FunnelChildView;
      if (series.sortAsc) {
        view.measure(itemWidth, height);
        view.layout(offsetX, 0, offsetX + itemWidth, height);
        offsetX += itemWidth;
        offsetX += series.gap;
      } else {
        view.measure(itemWidth, height);
        view.layout(offsetX - itemWidth, 0, offsetX, height);
        offsetX -= itemWidth;
        offsetX -= series.gap;
      }
    }
  }
}

class FunnelChildView extends View {
  final FunnelData data;
  final FunnelData? preData;
  final bool animator;
  final AnimatorDirection animatorDirection;
  final double gap;
  final double minData;
  final double maxData;
  final SNumber minSize;
  final SNumber maxSize;
  final Direction direction;
  final bool sortAsc;
  final Align2 funnelAlign;
  final bool legendHoverLink;
  final Path _path = Path();
  final List<Offset> _pointList = []; //采用点来表示视图  从而可以更方便的实现动画

  TextPainter? _textPainter;

  double curWidth = 0;
  double? preWidth;
  double curHeight = 0;
  double? preHeight;

  FunnelChildView(
    this.data,
    this.preData,
    this.gap, {
    required this.minData,
    required this.maxData,
    required this.minSize,
    required this.maxSize,
    required this.direction,
    required this.sortAsc,
    required this.funnelAlign,
    required this.legendHoverLink,
    required this.animator,
    required this.animatorDirection,
    super.paint,
  }) {
    if (data.label.show) {
      String s = data.data.toInt().toString();
      if (data.labelText != null && data.labelText!.isNotEmpty) {
        s = data.labelText!;
      }
      TextSpan span = TextSpan(text: s, style: data.label.textStyle);
      _textPainter = TextPainter(
          text: span, textDirection: TextDirection.ltr, maxLines: 1, ellipsis: data.label.ellipsis, textAlign: TextAlign.center);
    }
  }

  @override
  @mustCallSuper
  void onLayout(double left, double top, double right, double bottom) {
    super.onLayout(left, top, right, bottom);
    _computePoint();
    _path.reset();
    if (_pointList.isNotEmpty) {
      _path.moveTo(_pointList[0].dx, _pointList[0].dy);
      for (Offset offset in _pointList) {
        _path.lineTo(offset.dx, offset.dy);
      }
    }
  }

  void _computePoint() {
    _pointList.clear();
    _path.reset();

    Align2 align2 = funnelAlign;
    if (align2 == Align2.auto) {
      align2 = Align2.center;
    }

    double minWidth;
    if (minSize.percent) {
      minWidth = minSize.percentRatio() * width;
    } else {
      minWidth = minSize.number;
    }
    double minHeight;
    if (minSize.percent) {
      minHeight = minSize.percentRatio() * height;
    } else {
      minHeight = minSize.number;
    }

    if (preData == null) {
      if (direction == Direction.horizontal) {
        double totalHeight = maxSize.convert(height) - minHeight;
        if (totalHeight > height) {
          totalHeight = height;
        }
        double dataHeight = totalHeight * data.data / maxData;
        curHeight = dataHeight;
        if (sortAsc) {
          if (align2 == Align2.start) {
            _pointList.add(Offset.zero);
            _pointList.add(Offset.zero);
            _pointList.add(Offset(width, 0));
            _pointList.add(Offset(width, dataHeight));
            return;
          }
          if (align2 == Align2.center) {
            _pointList.add(Offset(0, centerY));
            _pointList.add(Offset(0, centerY));
            _pointList.add(Offset(width, centerY - dataHeight / 2));
            _pointList.add(Offset(width, centerY + dataHeight / 2));
            return;
          }
          if (align2 == Align2.end) {
            _pointList.add(Offset(0, height));
            _pointList.add(Offset(0, height));
            _pointList.add(Offset(width, height));
            _pointList.add(Offset(width, height - dataHeight));
          }
          return;
        }

        // sortDesc;
        if (align2 == Align2.start) {
          _pointList.add(Offset(width, 0));
          _pointList.add(Offset(width, 0));
          _pointList.add(const Offset(0, 0));
          _pointList.add(Offset(0, dataHeight));
          return;
        }
        if (align2 == Align2.center) {
          _pointList.add(Offset(width, centerY));
          _pointList.add(Offset(width, centerY));
          _pointList.add(Offset(0, centerY - dataHeight / 2));
          _pointList.add(Offset(0, centerY + dataHeight / 2));
          return;
        }
        if (align2 == Align2.end) {
          _pointList.add(Offset(width, height));
          _pointList.add(Offset(width, height));
          _pointList.add(Offset(0, height));
          _pointList.add(Offset(0, height - dataHeight));
        }
        return;
      }

      /// vertical
      double totalWidth = (maxSize.convert(width) - minWidth);
      if (totalWidth > width) {
        totalWidth = width;
      }
      double w = totalWidth * (data.data / maxData);
      curWidth = w;
      if (sortAsc) {
        if (align2 == Align2.start) {
          _pointList.add(Offset.zero);
          _pointList.add(Offset.zero);
          _pointList.add(Offset(w, height));
          _pointList.add(Offset(0, height));
          return;
        }
        if (align2 == Align2.center) {
          _pointList.add(Offset(centerX, 0));
          _pointList.add(Offset(centerX, 0));
          _pointList.add(Offset(centerX + w / 2, height));
          _pointList.add(Offset(centerX - w / 2, height));
          return;
        }
        if (align2 == Align2.end) {
          _pointList.add(Offset(width, 0));
          _pointList.add(Offset(width, 0));
          _pointList.add(Offset(width, height));
          _pointList.add(Offset(width - w, height));
        }
        return;
      }

      /// desc
      if (align2 == Align2.start) {
        _pointList.add(const Offset(0, 0));
        _pointList.add(const Offset(0, 0));
        _pointList.add(Offset(w, 0));
        _pointList.add(Offset(0, height));
        return;
      }
      if (align2 == Align2.center) {
        _pointList.add(Offset(centerX - w / 2, 0));
        _pointList.add(Offset(centerX - w / 2, 0));
        _pointList.add(Offset(centerX + w / 2, 0));
        _pointList.add(Offset(centerX, height));
        return;
      }
      if (align2 == Align2.end) {
        _pointList.add(Offset(width - w, 0));
        _pointList.add(Offset(width - w, 0));
        _pointList.add(Offset(width, 0));
        _pointList.add(Offset(width, height));
      }
      return;
    }

    /// 非第一个数据
    /// horizontal
    if (direction == Direction.horizontal) {
      double totalHeight = maxSize.convert(height) - minHeight;
      if (totalHeight > height) {
        totalHeight = height;
      }

      double h = totalHeight * (data.data / maxData);
      double preH = totalHeight * (preData!.data / maxData);
      curHeight = h;
      preHeight = preH;

      if (sortAsc) {
        if (align2 == Align2.start) {
          _pointList.add(Offset.zero);
          _pointList.add(Offset(width, 0));
          _pointList.add(Offset(width, h));
          _pointList.add(Offset(0, preH));
          return;
        }
        if (align2 == Align2.center) {
          _pointList.add(Offset(0, centerY - preH / 2));
          _pointList.add(Offset(width, centerY - h / 2));
          _pointList.add(Offset(width, centerY + h / 2));
          _pointList.add(Offset(0, centerY + preH / 2));
          return;
        }
        if (align2 == Align2.end) {
          _pointList.add(Offset(0, height - preH));
          _pointList.add(Offset(width, height - h));
          _pointList.add(Offset(width, height));
          _pointList.add(Offset(0, height));
        }
        return;
      }

      // sortDesc
      if (align2 == Align2.start) {
        _pointList.add(Offset.zero);
        _pointList.add(Offset(width, 0));
        _pointList.add(Offset(width, preH));
        _pointList.add(Offset(0, h));
        return;
      }
      if (align2 == Align2.center) {
        _pointList.add(Offset(0, centerY - h / 2));
        _pointList.add(Offset(width, centerY - preH / 2));
        _pointList.add(Offset(width, centerY + preH / 2));
        _pointList.add(Offset(0, centerY + h / 2));
        return;
      }
      if (align2 == Align2.end) {
        _pointList.add(Offset(0, height - h));
        _pointList.add(Offset(width, height - preH));
        _pointList.add(Offset(width, height));
        _pointList.add(Offset(0, height));
      }
      return;
    }

    /// vertical
    double totalWidth = (maxSize.convert(width) - minWidth);
    if (totalWidth > width) {
      totalWidth = width;
    }
    double w = totalWidth * (data.data / maxData);
    double preW = totalWidth * (preData!.data / maxData);

    curWidth = w;
    preWidth = preW;

    /// asc
    if (sortAsc) {
      if (align2 == Align2.start) {
        _pointList.add(Offset.zero);
        _pointList.add(Offset(preW, 0));
        _pointList.add(Offset(w, height));
        _pointList.add(Offset(0, height));
        return;
      }
      if (align2 == Align2.center) {
        _pointList.add(Offset(centerX - preW / 2, 0));
        _pointList.add(Offset(centerX + preW / 2, 0));
        _pointList.add(Offset(centerX + w / 2, height));
        _pointList.add(Offset(centerX - w / 2, height));
        return;
      }
      if (align2 == Align2.end) {
        _pointList.add(Offset(width - preW, 0));
        _pointList.add(Offset(width, 0));
        _pointList.add(Offset(width, height));
        _pointList.add(Offset(width - w, height));
      }
      return;
    }

    /// desc
    if (align2 == Align2.start) {
      _pointList.add(const Offset(0, 0));
      _pointList.add(Offset(w, 0));
      _pointList.add(Offset(preW, height));
      _pointList.add(Offset(0, height));
      return;
    }
    if (align2 == Align2.center) {
      _pointList.add(Offset(centerX - w / 2, 0));
      _pointList.add(Offset(centerX + w / 2, 0));
      _pointList.add(Offset(centerX + preW / 2, height));
      _pointList.add(Offset(centerX - preW / 2, height));
      return;
    }
    if (align2 == Align2.end) {
      _pointList.add(Offset(width - w, 0));
      _pointList.add(Offset(width, 0));
      _pointList.add(Offset(width, height));
      _pointList.add(Offset(width - preW, height));
    }
  }

  @override
  void onDraw(Canvas canvas, double animatorPercent) {
    paint.reset();
    data.style.fillPaint(paint);
    if (animator) {
      if (direction == Direction.vertical) {
        if (animatorDirection == AnimatorDirection.ste) {
          canvas.clipRect(Rect.fromLTWH(0, 0, width, height * animatorPercent));
        } else {
          canvas.clipRect(Rect.fromLTRB(0, height * (1 - animatorPercent), width, height));
        }
      } else {
        if (animatorDirection == AnimatorDirection.ste) {
          canvas.clipRect(Rect.fromLTWH(0, 0, width * animatorPercent, height));
        } else {
          canvas.clipRect(Rect.fromLTRB(width * (1 - animatorPercent), 0, width, height));
        }
      }
    }
    canvas.drawPath(_path, paint);
    if (data.border != null) {
      paint.reset();
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = data.border!.width;
      paint.color = data.border!.color;
      canvas.drawPath(_path, paint);
    }
    _drawText(canvas);
  }

  void _drawText(Canvas canvas) {
    if (_textPainter == null) {
      return;
    }
    _textPainter!.layout(maxWidth: width);
    double textWidth = _textPainter!.width * 1.2;
    double textHeight = _textPainter!.height;
    paint.reset();
    Offset offset = _computeTextOffset(textWidth, textHeight);
    //绘制连接线并修正数据
    ChartLabel label = data.label;
    if (label.drawLabelLine && (label.align.name.startsWith('left') || label.align.name.startsWith("right"))) {
      LineStyle? lineStyle = label.labelLineStyle;
      lineStyle ??= LineStyle(color: label.textStyle.color ?? Colors.blue, width: 1);
      lineStyle.fillPaint(paint);
      //修正位置
      double length = label.labelLineLength;
      if (length <= 0) {
        length = 10;
      }
      EdgeInsets margin = label.lineMargin;
      if (data.label.align.name.startsWith('left')) {
        canvas.drawLine(
          Offset(offset.dx + textWidth - length - margin.right, offset.dy + textHeight / length),
          Offset(offset.dx + textWidth - margin.right, offset.dy + textHeight / 2),
          paint,
        );
        offset = Offset(offset.dx - length - margin.right - margin.left, offset.dy);
      } else {
        canvas.drawLine(
          Offset(offset.dx + margin.left, offset.dy + textHeight / 2),
          Offset(offset.dx + margin.left + length, offset.dy + textHeight / 2),
          paint,
        );
        offset = Offset(offset.dx + length + margin.horizontal, offset.dy);
      }
    }
    _textPainter!.paint(canvas, offset);
  }

  Offset _computeTextOffset(double textWidth, double textHeight) {
    Offset p0 = _pointList[0];
    Offset p1 = _pointList[1];
    Offset p2 = _pointList[2];
    Offset p3 = _pointList[3];
    ChartAlign align = data.label.align;

    if (align == ChartAlign.leftTop) {
      return Offset(p0.dx - textWidth, 0);
    }
    if (align == ChartAlign.leftCenter) {
      return Offset((p0.dx + p3.dx) / 2 - textWidth, (p0.dy + p3.dy) / 2 - textHeight / 2);
    }
    if (align == ChartAlign.leftBottom) {
      return Offset(p3.dx - textWidth, p3.dy - textHeight);
    }
    if (align == ChartAlign.rightTop) {
      return Offset(p1.dx, 0);
    }
    if (align == ChartAlign.rightCenter) {
      return Offset((p1.dx + p2.dx) / 2, centerY - textHeight / 2);
    }
    if (align == ChartAlign.rightBottom) {
      return Offset(p2.dx, p2.dy - textHeight);
    }
    if (align == ChartAlign.insideLeftTop) {
      return Offset((p0.dx), 0);
    }
    if (align == ChartAlign.insideLeftCenter) {
      return Offset((p0.dx + p3.dx) / 2, (p0.dy + p3.dy) / 2 - textHeight / 2);
    }
    if (align == ChartAlign.insideLeftBottom) {
      return Offset(p3.dx, p3.dy - textHeight);
    }
    if (align == ChartAlign.insideRightTop) {
      return Offset(p1.dx - textWidth, 0);
    }
    if (align == ChartAlign.insideRightCenter) {
      return Offset((p1.dx + p2.dx) / 2 - textWidth, (p1.dy + p2.dy) / 2 - textHeight / 2);
    }
    if (align == ChartAlign.insideRightBottom) {
      return Offset(p2.dx - textWidth, p2.dy - textHeight);
    }
    if (align == ChartAlign.topLeft) {
      return Offset(p0.dx, p0.dy - textHeight);
    }
    if (align == ChartAlign.topCenter) {
      return Offset((p0.dx + p1.dx) / 2 - textWidth / 2, (p0.dy + p1.dy) / 2 - textHeight);
    }
    if (align == ChartAlign.topRight) {
      return Offset(p1.dx - textWidth, p1.dy - textHeight);
    }
    if (align == ChartAlign.bottomLeft) {
      return Offset(p3.dx - textWidth / 2, p3.dy);
    }
    if (align == ChartAlign.bottomCenter) {
      return Offset((p3.dx + p2.dx) / 2 - textWidth / 2, (p3.dy + p2.dy) / 2);
    }
    if (align == ChartAlign.bottomRight) {
      return Offset(p2.dx - textWidth, p2.dy);
    }
    if (align == ChartAlign.insideTopLeft) {
      return Offset(p0.dx, p0.dy);
    }
    if (align == ChartAlign.insideTopCenter) {
      return Offset((p0.dx + p1.dx) / 2 - textWidth / 2, (p0.dy + p1.dy) / 2);
    }
    if (align == ChartAlign.insideTopRight) {
      return Offset(p1.dx - textWidth, p1.dy);
    }
    if (align == ChartAlign.insideBottomLeft) {
      return Offset(p3.dx, p3.dy - textHeight);
    }
    if (align == ChartAlign.insideBottomCenter) {
      return Offset((p3.dx + p2.dx) / 2 - textWidth / 2, (p3.dy + p2.dy) / 2 - textHeight);
    }
    if (align == ChartAlign.insideBottomRight) {
      return Offset(p2.dx - textWidth, p2.dy - textHeight);
    }

    return Offset(centerX - textWidth / 2, centerY - textHeight / 2);
  }

}
