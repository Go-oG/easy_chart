import 'package:easy_chart/chart/charts/treemap/treemap_series.dart';
import 'package:easy_chart/chart/options/style.dart';
import 'package:flutter/material.dart';

class TreeNode {
  final TreeMapData data;
  final double areaPercent;
  double area = 0;
  Rect rect = Rect.zero;

  TreeNode(this.data, this.areaPercent);

  //计算长宽比
  double ratio() {
    return computeRatio(rect.width, rect.height);
  }

  @override
  String toString() {
    return '[Rect:${rect.left.toInt()} ${rect.top.toInt()} ${rect.right.toInt()} ${rect.bottom.toInt()} area:${area.toInt()} areaPercent:${areaPercent.toStringAsFixed(2)}]';
  }

  static double computeRatio(double width, double height) {
    if (width >= height) {
      return width / height;
    } else {
      return height / width;
    }
  }
}

class Optimal {
  final Direction direction;
  final double ratio;

  Optimal(this.direction, this.ratio);
}

abstract class TreemapLayout {
  final TreeMapData data;
  final double width;
  final double height;

  TreemapLayout(this.data, this.width, this.height);

  List<TreeNode> layout(double left, double top, double right, double bottom) {
    if (data.childrenList.isEmpty) {
      return [];
    }
    if (data.childrenList.length == 1) {
      TreeNode treeNode = TreeNode(data.childrenList.first, 1);
      treeNode.rect = Rect.fromLTWH(0, 0, width, height);
      return [treeNode];
    }
    return [];
  }
}

class BinaryNode {
  final TreeMapData data;
  Rect rect = Rect.zero;
  BinaryNode? left;
  BinaryNode? right;

  BinaryNode(
    this.data,
  );
}

/// 近似平衡二叉树排列
/// 为宽矩形选择水平分区，为高矩形选择垂直分区的布局方式。
/// 由于权重只能为int 因此内部会进行相关的double->int的转换
class BinaryLayout extends TreemapLayout {
  BinaryLayout(super.data, super.width, super.height);

  @override
  List<TreeNode> layout(double left, double top, double right, double bottom) {
    if (data.childrenList.length <= 1) {
      return super.layout(left, top, right, bottom);
    }
    List<BinaryNode> list = _buildBinaryTree();
    List<TreeNode> treeNodeList = [];
    for (var element in list) {
      TreeNode treeNode = TreeNode(element.data, 1);
      treeNode.rect = element.rect;
      treeNodeList.add(treeNode);
    }
    return treeNodeList;
  }

  //构建树
  List<BinaryNode> _buildBinaryTree() {
    List<BinaryNode> nodeList = [];
    for (var element in data.childrenList) {
      BinaryNode node = BinaryNode(element);
      nodeList.add(node);
    }
    List<int> sumList = [0];
    for (var element in nodeList) {
      sumList.add(element.data.data.toInt() + sumList.last);
    }
    partition(sumList, nodeList, 0, nodeList.length, data.data.toInt(), 0, 0, width, height);
    return nodeList;
  }

  void partition(
    List<int> sums,
    List<BinaryNode> nodes,
    int start,
    int end,
    int value,
    double x0,
    double y0,
    double x1,
    double y1,
  ) {
    //无法再分割直接返回
    if (start >= end - 1) {
      BinaryNode node = nodes[start];
      node.rect = Rect.fromLTRB(x0, y0, x1, y1);
      return;
    }

    int valueOffset = sums[start];
    double valueTarget = (value / 2) + valueOffset;
    int k = start + 1;
    int hi = end - 1;

    while (k < hi) {
      int mid = k + hi >>> 1;
      if (sums[mid] < valueTarget) {
        k = mid + 1;
      } else {
        hi = mid;
      }
    }

    if ((valueTarget - sums[k - 1]) < (sums[k] - valueTarget) && start + 1 < k) {
      --k;
    }

    int valueLeft = sums[k] - valueOffset;
    int valueRight = value - valueLeft;

    if ((x1 - x0) > (y1 - y0)) {
      //宽矩形水平分割
      var xk = (x0 * valueRight + x1 * valueLeft) / value;
      partition(sums, nodes, start, k, valueLeft, x0, y0, xk, y1);
      partition(sums, nodes, k, end, valueRight, xk, y0, x1, y1);
    } else {
      // 高矩形垂直分割
      var yk = (y0 * valueRight + y1 * valueLeft) / value;
      partition(sums, nodes, start, k, valueLeft, x0, y0, x1, yk);
      partition(sums, nodes, k, end, valueRight, x0, yk, x1, y1);
    }
  }
}

class DiceLayout extends TreemapLayout {
  DiceLayout(super.data, super.width, super.height);

  @override
  List<TreeNode> layout(double left, double top, double right, double bottom) {
    if (data.childrenList.length <= 1) {
      return super.layout(left, top, right, bottom);
    }
    List<TreeNode> nodeList = _convertDataToNode(width, height, data.childrenList);
    double leftOffset = 0;
    for (var element in nodeList) {
      Rect rect = Rect.fromLTWH(leftOffset, 0, width * element.areaPercent, height);
      leftOffset += rect.width;
      element.rect = rect;
    }
    return nodeList;
  }
}

class SliceLayout extends TreemapLayout {
  SliceLayout(super.data, super.width, super.height);

  @override
  List<TreeNode> layout(double left, double top, double right, double bottom) {
    if (data.childrenList.length <= 1) {
      return super.layout(left, top, right, bottom);
    }

    List<TreeNode> nodeList = _convertDataToNode(width, height, data.childrenList);
    double topOffset = 0;
    for (var element in nodeList) {
      Rect rect = Rect.fromLTWH(0, topOffset, width, height * element.areaPercent);
      topOffset += rect.height;
      element.rect = rect;
    }
    return nodeList;
  }
}

class SliceDiceLayout extends TreemapLayout {
  final int deepLevel; //深度
  SliceDiceLayout(
    super.data,
    super.width,
    super.height,
    this.deepLevel,
  );

  @override
  List<TreeNode> layout(double left, double top, double right, double bottom) {
    if (deepLevel % 2 == 0) {
      return DiceLayout(data, width, height).layout(left, top, right, bottom);
    } else {
      return SliceLayout(data, width, height).layout(left, top, right, bottom);
    }
  }
}

class SquareLayout extends TreemapLayout {
  final bool upToDown; //是否从上往下

  SquareLayout(super.data, super.width, super.height, {this.upToDown = true});

  @override
  List<TreeNode> layout(double left, double top, double right, double bottom) {
    if (data.childrenList.length <= 1) {
      return super.layout(left, top, right, bottom);
    }
    List<TreeMapData> dataList = data.childrenList;
    dataList.sort((a, b) {
      return b.data.compareTo(a.data);
    });

    // 计算每个矩形需要占据的面积及其百分比
    List<TreeNode> nodeList = _convertDataToNode(width, height, dataList);
    List<TreeNode> resultList = []; //存储结果
    // 开始布局
    //记录剩余可用范围边界
    Rect remainRect = Rect.fromLTWH(0, 0, width, height);
    List<TreeNode> nodeStack = [];
    Direction? direction;
    int i = 0;
    while (i < nodeList.length) {
      if (direction == null && nodeStack.isNotEmpty) {
        throw FlutterError('内部状态错误');
      }
      TreeNode node = nodeList[i];
      if (nodeStack.isEmpty) {
        Optimal optimal = _computeOptimalRadioAndDirection(node.area, remainRect.width, remainRect.height);
        if (optimal.direction == Direction.vertical) {
          // 竖直放置
          node.rect = Rect.fromLTWH(remainRect.left, remainRect.top, node.area / remainRect.height, remainRect.height);
          remainRect = Rect.fromLTWH(node.rect.right, remainRect.top, remainRect.width - node.rect.width, remainRect.height);
        } else {
          // 横向放置
          if (upToDown) {
            node.rect = Rect.fromLTWH(remainRect.left, remainRect.top, remainRect.width, node.area / remainRect.width);
            remainRect = Rect.fromLTWH(remainRect.left, node.rect.bottom, remainRect.width, remainRect.height - node.rect.height);
          } else {
            node.rect = Rect.fromLTWH(
                remainRect.left, remainRect.bottom - node.area / remainRect.width, remainRect.width, node.area / remainRect.width);
            remainRect = Rect.fromLTWH(remainRect.left, remainRect.top, remainRect.width, remainRect.height - node.rect.height);
          }
        }
        nodeStack.add(node);
        direction = optimal.direction;
        i++;
        continue;
      }
      if (direction == null) {
        throw FlutterError('内部布局状态异常');
      }

      double preFillAllArea = _computeChildrenFillArea(nodeStack); //计算前面占用的面积
      double nowFillAllArea = preFillAllArea + node.area;

      if (direction == Direction.vertical) {
        // 计算假设在当前列上排列时需要的宽度和其长宽比(即竖直放置)
        double widthTmp = nowFillAllArea / remainRect.height;
        double ratio2 = TreeNode.computeRatio(widthTmp, node.area / widthTmp);
        // 计算假设新开一列时需要的宽度和其长宽比（横向放置）
        Optimal optimal = _computeOptimalRadioAndDirection(node.area, remainRect.width, remainRect.height);
        if (ratio2 <= optimal.ratio) {
          //在当前列进行排列
          //满足条件后重新计算所有的节点数据
          nodeStack.add(node);
          _readjustChildForAlightHeight(nodeStack, nodeStack.first.rect.left, remainRect.top, remainRect.height);
          //更新剩余可用区域
          TreeNode last = nodeStack.last;
          remainRect = Rect.fromLTWH(last.rect.right, remainRect.top, width - last.rect.right, remainRect.height);
          i++;
        } else {
          //不满足条件 需要新开一列
          //这里i 没有进行自增，而是放到了下一次
          resultList.addAll(nodeStack);
          nodeStack.clear();
          direction = null;
        }
      } else {
        // 计算假设在当前行上排列时需要的高度和其长宽比(即横向放置)
        double heightTmp = nowFillAllArea / remainRect.width;
        double ratio2 = TreeNode.computeRatio(node.area / heightTmp, heightTmp);

        // 计算假设新开一列时需要的宽度和其长宽比（纵向或横向放置）
        Optimal optimal = _computeOptimalRadioAndDirection(node.area, remainRect.width, remainRect.height);
        if (ratio2 <= optimal.ratio) {
          //在当前行进行排列
          nodeStack.add(node);
          if (upToDown) {
            _readjustChildForAlightWidth(nodeStack, nodeStack.first.rect.left, nodeStack.first.rect.top, remainRect.width);
          } else {
            _readjustChildForAlightWidth2(nodeStack, nodeStack.first.rect.left, nodeStack.first.rect.bottom, remainRect.width);
          }
          //更新剩余可用区域
          TreeNode last = nodeStack.last;
          if (upToDown) {
            remainRect = Rect.fromLTWH(remainRect.left, last.rect.bottom, remainRect.width, remainRect.bottom - last.rect.bottom);
          } else {
            remainRect = Rect.fromLTRB(remainRect.left, remainRect.top, remainRect.right, last.rect.top);
          }
          i++;
        } else {
          //不满足条件 需要新开一列或者行
          //这里i 没有进行自增，而是放到了下一次
          resultList.addAll(nodeStack);
          nodeStack.clear();
          direction = null;
        }
      }
    }

    if (nodeStack.isNotEmpty) {
      resultList.addAll(nodeStack);
    }
    return resultList;
  }

  //针对按照高度方向布局，进行重新调整所有给定数据的矩形范围
  void _readjustChildForAlightHeight(List<TreeNode> list, double left, double top, double remainHeight) {
    double allArea = _computeChildrenFillArea(list);
    double tmpWidth = allArea / remainHeight;
    double topOffset = top;
    for (var element in list) {
      element.rect = Rect.fromLTWH(left, topOffset, tmpWidth, element.area / tmpWidth);
      topOffset += element.rect.height;
    }
  }

  //针对按照宽度方向布局，进行重新调整所有给定数据的矩形范围
  void _readjustChildForAlightWidth(List<TreeNode> list, double left, double top, double remainWidth) {
    double allArea = _computeChildrenFillArea(list);
    double tmpHeight = allArea / remainWidth;
    double leftOffset = left;
    for (var element in list) {
      element.rect = Rect.fromLTWH(leftOffset, top, element.area / tmpHeight, tmpHeight);
      leftOffset += element.rect.width;
    }
  }

  void _readjustChildForAlightWidth2(List<TreeNode> list, double left, double bottom, double remainWidth) {
    double allArea = _computeChildrenFillArea(list);
    double tmpHeight = allArea / remainWidth;
    double leftOffset = left;
    double top = bottom - tmpHeight;
    for (var element in list) {
      element.rect = Rect.fromLTWH(leftOffset, top, element.area / tmpHeight, tmpHeight);
      leftOffset += element.rect.width;
    }
  }

  ///给定一个矩形宽高和给定面积计算最优的布局方向和布局后的长宽比
  Optimal _computeOptimalRadioAndDirection(double area, double width, double height) {
    double ratio;
    Direction direction;
    if (width > height) {
      direction = Direction.vertical;
      double tmp = area / height;
      ratio = TreeNode.computeRatio(tmp, height);
    } else {
      direction = Direction.horizontal;
      double tmp = area / width;
      ratio = TreeNode.computeRatio(width, tmp);
    }
    return Optimal(direction, ratio);
  }
}

/// 计算给定数据占用的总面积
double _computeChildrenFillArea(List<TreeNode> list) {
  double area = 0;
  for (var element in list) {
    area += element.area;
  }
  return area;
}

double _computeDataSum(List<TreeMapData> dataList, {bool adjustData = true}) {
  double all = 0;
  for (var element in dataList) {
    all += element.data;
  }
  return all;
}

List<TreeNode> _convertDataToNode(double width, double height, List<TreeMapData> dataList) {
  double dataSum = _computeDataSum(dataList);
  List<TreeNode> nodeList = [];
  double area = width * height;
  for (var element in dataList) {
    double areaPercent = element.data / dataSum;
    TreeNode node = TreeNode(element, areaPercent);
    node.area = area * areaPercent;
    nodeList.add(node);
  }
  return nodeList;
}
