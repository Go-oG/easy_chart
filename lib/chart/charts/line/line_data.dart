import 'package:easy_chart/chart/core/data_group.dart';
import 'package:easy_chart/chart/options/style.dart';

class LineGroup extends DataGroup {
  final bool roundCap;
  final List<int>? lineDash;
  final String stackGroup;//用于实现不同的分组,如果为空则为单独的一族
  final StackStrategy stackStrategy;
  final LineStyle lineStyle;
  final AreaStyle? areaStyle;
  final AreaStyle? areaSelectStyle;

  LineGroup(super.type,
      super.xAxisId,
      super.yAxisId,
      super.dataList, {
        this.stackGroup = '',
        this.stackStrategy = StackStrategy.all,
        this.roundCap = false,
        this.lineDash,
        this.lineStyle =const LineStyle(),
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
