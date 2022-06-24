import 'package:flutter/material.dart';

///适用于极坐标系下的Chart基类
abstract class BasePolarChart extends ChangeNotifier implements CustomPainter {

  BasePolarChart();

  @override
  bool? hitTest(Offset position) {
    return false;
  }

  @override
  SemanticsBuilderCallback? get semanticsBuilder => null;

  @override
  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) {
    return false;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
