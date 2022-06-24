import 'package:easy_chart/chart/core/data_group.dart';
import 'package:easy_chart/chart/options/string_number.dart';

class PieGroup extends DataGroup {
  final bool clockwise;
  final double startAngle;
  final double minAngle;
  final double minShowLabelAngle;
  final bool roseType;
  final bool avoidLabelOverlap;
  final bool stillShowZeroSum;
  final bool showEmptyCircle;
  final List<SNumber> center; // 圆心点坐标 参数大小必须为2
  final List<SNumber> radius; // 半径表示 参数大小为1-2 如果为2 则分别表示内半径和外半径
  final bool silent;

  PieGroup(
    super.type,
    super.xAxisId,
    super.yAxisId,
    super.dataList, {
    this.clockwise = true,
    this.startAngle = 90,
    this.minAngle = 0,
    this.minShowLabelAngle = 0,
    this.roseType = false,
    this.avoidLabelOverlap = true,
    this.stillShowZeroSum = true,
    this.showEmptyCircle = true,
    this.center = const [SNumber.percent(50), SNumber.percent(50)],
    this.radius = const [SNumber.percent(0), SNumber.percent(75)],
    this.silent = false,
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
