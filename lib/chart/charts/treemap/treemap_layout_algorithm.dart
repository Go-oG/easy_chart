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

abstract class LayoutAlgorithm {
  final TreeMapData data;
  final double width;
  final double height;

  LayoutAlgorithm(this.data, this.width, this.height);

  List<TreeNode> layout(double left, double top, double right, double bottom);
}

class BinaryLayout extends LayoutAlgorithm {
  BinaryLayout(super.data, super.width, super.height);

  @override
  List<TreeNode> layout(double left, double top, double right, double bottom) {
    // TODO: implement layout
    throw UnimplementedError();
  }
}

class DiceLayout extends LayoutAlgorithm {
  DiceLayout(super.data, super.width, super.height);

  @override
  List<TreeNode> layout(double left, double top, double right, double bottom) {
    // TODO: implement layout
    throw UnimplementedError();
  }
}

class SliceLayout extends LayoutAlgorithm {
  SliceLayout(super.data, super.width, super.height);

  @override
  List<TreeNode> layout(double left, double top, double right, double bottom) {
    // TODO: implement layout
    throw UnimplementedError();
  }
}

class SliceDiceLayout extends LayoutAlgorithm {
  SliceDiceLayout(
    super.data,
    super.width,
    super.height,
  );

  @override
  List<TreeNode> layout(double left, double top, double right, double bottom) {
    // TODO: implement layout
    throw UnimplementedError();
  }
}

class SquarifiedLayout extends LayoutAlgorithm {
  final bool upToDown; //是否从上往下

  SquarifiedLayout(super.data, super.width, super.height, {this.upToDown = false});

  @override
  List<TreeNode> layout(double left, double top, double right, double bottom) {
    if (data.childrenList.isEmpty) {
      return [];
    }

    if (data.childrenList.length == 1) {
      TreeNode treeNode = TreeNode(data.childrenList.first, 1);
      treeNode.rect = Rect.fromLTWH(0, 0, width, height);
      return [treeNode];
    }

    List<TreeMapData> dataList = List.from(data.childrenList);
    dataList.sort((a, b) {
      return b.computeChildrenData().compareTo(a.computeChildrenData());
    });
    // 计算每个矩形需要占据的面积及其百分比
    double all = 0;
    for (var element in dataList) {
      all += element.computeChildrenData();
    }
    List<TreeNode> nodeList = [];
    double area = width * height;
    for (var element in dataList) {
      TreeNode node = TreeNode(element, element.computeChildrenData() / all);
      node.area = area * node.areaPercent;
      nodeList.add(node);
    }

    // 开始布局
    List<TreeNode> resultList = []; //存储结果

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
          double rectWidth = node.area / remainRect.height;
          node.rect = Rect.fromLTWH(remainRect.left, remainRect.top, rectWidth, remainRect.height);
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

  /// 计算给定数据占用的总面积
  double _computeChildrenFillArea(List<TreeNode> list) {
    double area = 0;
    for (var element in list) {
      area += element.area;
    }
    return area;
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

class ResquarifyLayout extends LayoutAlgorithm {
  ResquarifyLayout(super.data, super.width, super.height);

  @override
  List<TreeNode> layout(double left, double top, double right, double bottom) {
    // TODO: implement layout
    throw UnimplementedError();
  }
}
