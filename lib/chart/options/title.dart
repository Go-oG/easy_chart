import 'package:flutter/material.dart';

import 'style.dart';

class ChartTitle {
  String? id;
  bool show = false;
  ChartAlign position=ChartAlign.topLeft;
  String text = '';
  TextStyle textStyle = const TextStyle();
  VoidCallback? textClick;
  String subText = '';
  TextStyle subTextStyle = const TextStyle();
  VoidCallback? subTextClick;
  num itemGap = 10;
  bool triggerEvent = false;

  Align2 textAlign = Align2.auto;
  Align2 textVerticalAlign = Align2.auto;

  EdgeInsetsGeometry padding = const EdgeInsets.all(5);
  EdgeInsetsGeometry margin = EdgeInsets.zero;
  Decoration decoration = const BoxDecoration();

  Widget? obtainWidget({BoxConstraints? constraints}) {
    if (!show) {
      return null;
    }
    if (text.isEmpty || subText.isEmpty) {
      return null;
    }
    List<Widget> wl = [];
    if (text.isNotEmpty) {
      Widget child = Text(text, style: textStyle);
      if (textClick != null && triggerEvent) {
        child = GestureDetector(
          onTap: textClick,
          child: child,
        );
      }
      wl.add(child);
    }
    if (itemGap > 0) {
      wl.add(SizedBox(height: itemGap.toDouble()));
    }
    if (subText.isNotEmpty) {
      Widget child = Text(subText, style: subTextStyle);
      if (subTextClick != null && triggerEvent) {
        child = GestureDetector(
          onTap: subTextClick,
          child: child,
        );
      }
      wl.add(child);
    }
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start;
    CrossAxisAlignment crossAxisAlignment=CrossAxisAlignment.start;

    if(textAlign==Align2.start){
      crossAxisAlignment=CrossAxisAlignment.start;
    }else if(textAlign==Align2.center){
      crossAxisAlignment=CrossAxisAlignment.center;
    }else if(textAlign==Align2.end){
      crossAxisAlignment=CrossAxisAlignment.end;
    }

    if(textVerticalAlign==Align2.start){
      mainAxisAlignment=MainAxisAlignment.start;
    }else if(textVerticalAlign==Align2.center){
      mainAxisAlignment=MainAxisAlignment.center;
    }else if(textVerticalAlign==Align2.end){
      mainAxisAlignment=MainAxisAlignment.end;
    }

    return Container(
      constraints: constraints,
      decoration: decoration,
      margin: margin,
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: wl,
      ),
    );
  }

}
