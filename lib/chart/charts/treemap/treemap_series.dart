import 'package:easy_chart/chart/options/label.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:easy_chart/chart/utils/assert_check.dart';
import 'package:flutter/material.dart';

///树图
class TreeMapSeries {
  final List<TreeMapData> dataList;
  final ChartLabel label;
  final TreemapLayoutAlgorithm algorithm;

  TreeMapSeries(this.dataList, {this.label = const ChartLabel(), this.algorithm = TreemapLayoutAlgorithm.square});
}

class TreeMapData {
  late final double _data;
  final List<TreeMapData> childrenList;
  final ItemStyle style;
  final String? label;
  final ChartLabel? labelStyle;

  double? _childrenData;

  TreeMapData(
    num data,
    this.childrenList, {
    this.style = const ItemStyle(BoxDecoration(), color: Colors.blue),
    this.label,
    this.labelStyle,
  }) {
    assertCheck(data > 0.0, msg: '数据必需大于0 current:$data');
    _data = data.toDouble();
  }

  /// 获取自身代表的权重值
  /// 如果没有子节点则返回自身否则返回所有子节点值的和
  double get data {
    if (childrenList.isNotEmpty) {
      if (_childrenData == null) {
        double tmp = 0;
        for (var element in childrenList) {
          tmp += element.data;
        }
        _childrenData = tmp;
      }
      return _childrenData!;
    }
    return _data;
  }
}

enum TreemapLayoutAlgorithm { dice, slice, sliceDice, binary, square }
