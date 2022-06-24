import 'package:easy_chart/chart/core/data_group.dart';

class PointGroup extends DataGroup {
  final String? calendarAxisId;

  PointGroup(
    super.type,
    super.xAxisId,
    super.yAxisId,
    super.dataList, {
    this.calendarAxisId,
    super.id,
    super.polarAxisId,
    super.name,
    super.symbol,
    super.showAllSymbol = false,
    super.legendHoverLink = true,
    super.connectNulls = false,
    super.clip = true,
    super.label,
    super.labelSelect,
    super.endLabel,
    super.endLabelSelect,
    super.itemStyle,
    super.itemSelectStyle,
  });
}
