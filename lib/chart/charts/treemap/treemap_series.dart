import 'package:easy_chart/chart/options/label.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:flutter/material.dart';

///树图
class TreeMapSeries {
  final List<TreeMapData> dataList;
  final ChartLabel label;

  TreeMapSeries(this.dataList, {this.label = const ChartLabel()});
}

class TreeMapData {
  final double data;
  final List<TreeMapData> childrenList;
  final ItemStyle style;
  final String? label;
  final ChartLabel? labelStyle;

  double? _childrenData;

  TreeMapData(
    this.data,
    this.childrenList, {
    this.style = const ItemStyle(BoxDecoration(), color: Colors.blue),
    this.label,
    this.labelStyle,
  });

  double computeChildrenData({bool adjustData = true}) {
    if (_childrenData == null) {
      double tmp = 0;
      for (var element in childrenList) {
        tmp += element.data;
      }
      _childrenData = tmp;
    }
    if (adjustData) {
      if (_childrenData! < data) {
        return data;
      }
    }
    return _childrenData!;
  }
}
