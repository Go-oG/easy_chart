import 'package:flutter/animation.dart';

class ChartAnimation {
  bool enable = true;
  Duration duration = const Duration(milliseconds: 300);
  Duration reverseDuration = const Duration(milliseconds: 300);
  AnimationBehavior behavior = AnimationBehavior.normal;
  Curve curve = Curves.linear;

}
