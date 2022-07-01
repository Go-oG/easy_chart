import 'package:flutter/animation.dart';

class ChartAnimation {
  bool enable = true;
  final Duration duration;
  final Duration reverseDuration;
  final AnimationBehavior behavior;
  final Curve curve;

  ChartAnimation(
      {this.enable = true,
      this.duration = const Duration(milliseconds: 800),
      this.reverseDuration = const Duration(milliseconds: 800),
      this.behavior = AnimationBehavior.normal,
      this.curve = Curves.easeInOut});
}
