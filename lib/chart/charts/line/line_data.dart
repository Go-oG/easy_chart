import 'package:easy_chart/chart/core/data_group.dart';
import 'package:easy_chart/chart/options/style.dart';

class LineGroup extends DataGroup {
  final bool roundCap;
  final List<int>? lineDash;
  final bool stack;
  final StackStrategy stackStrategy;
  final AreaStyle? areaStyle;
  final AreaStyle? areaSelectStyle;

  LineGroup(
    super.type,
    super.xAxisId,
    super.yAxisId,
    super.dataList, {
    this.stack = false,
    this.stackStrategy = StackStrategy.all,
    this.roundCap = false,
    this.lineDash,
    this.areaStyle,
    this.areaSelectStyle,
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
