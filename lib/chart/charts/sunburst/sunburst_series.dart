import 'package:easy_chart/chart/options/label.dart';
import 'package:easy_chart/chart/options/string_number.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:flutter/material.dart';

/// 旭日图
class SunburstSeries {
  final List<SNumber> center;
  final List<SunburstData> dataList;
  final SNumber innerRadius; //内圆半径(<=0时为圆)
  final SNumber outerRadius; //外圆最大半径(<=0时为圆)
  final double offsetAngle; // 偏移角度
  final double radiusGap;
  final double angleGap;
  final bool adjustData;
  final double corner;
  final ChartLabel label;

  SunburstSeries(
    this.dataList, {
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    this.innerRadius = const SNumber.number(0),
    this.outerRadius = const SNumber.percent(80),
    this.offsetAngle = 0,
    this.corner = 0,
    this.radiusGap = 0,
    this.angleGap = 0,
    this.adjustData = true,
    this.label = const ChartLabel(),
  });
}

/// 旭日图数据
class SunburstData {
  final double data;
  final SunburstData? parent;
  final ItemStyle style;
  final double? radiusDiff; //指定当前层圆环半径的差值 如果有些有，有些没有则全层都取相同的（>0时有效）
  final String? label;
  final Shader? shader;
  final List<SunburstData>? childrenList;

  double? _allData;

  SunburstData(
    this.data,
    this.parent,
    this.style, {
    this.shader,
    this.label,
    this.radiusDiff,
    this.childrenList,
  });

  /// 这里计算出所有的子类数据量
  /// 当总数据比当前数据小时应返回当前的数据
  double computeAllData({bool adjustData = true}) {
    if (childrenList == null || childrenList!.isEmpty) {
      return data;
    }

    if (_allData == null) {
      double tmp = 0;
      childrenList?.forEach((element) {
        tmp += element.computeAllData();
      });
      _allData = tmp;
    }
    if (adjustData && _allData! < data) {
      return data;
    }
    return _allData!;
  }
}
