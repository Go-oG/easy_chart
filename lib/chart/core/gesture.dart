import 'package:flutter/gestures.dart';

class GestureListener {
  void onTapDown(TapDownDetails details) {
    print('onTapDown:$details');
  }

  void onTapUp(TapUpDetails details) {
    print('onTapUp:$details');
  }

  void onTap() {
    print('onTap');
  }

  void onTapCancel() {
    print('onTapCancel');
  }

  void onSecondaryTap() {
    print('onSecondaryTap');
  }

  void onSecondaryTapDown(TapDownDetails details) {
    print('onSecondaryTapDown:$details');
  }

  void onSecondaryTapUp(TapUpDetails details) {
    print('onSecondaryTapUp:$details');
  }

  void onSecondaryTapCancel() {
    print('onSecondaryTapCancel');
  }

  void onTertiaryTapDown(TapDownDetails details) {
    print('onTertiaryTapDown:$details');
  }

  void onTertiaryTapUp(TapUpDetails details) {
    print('onTertiaryTapUp:$details');
  }

  void onTertiaryTapCancel() {
    print('onTertiaryTapCancel');
  }

  void onDoubleTapDown(TapDownDetails details) {
    print('onDoubleTapDown:$details');
  }

  void onDoubleTap() {
    print('onDoubleTap');
  }

  void onDoubleTapCancel() {
    print('onDoubleTapCancel');
  }

  void onLongPressDown(LongPressDownDetails details) {
    print('onLongPressDown:$details');
  }

  void onLongPressCancel() {
    print('onLongPressCancel');
  }

  void onLongPress() {
    print('onLongPress');
  }

  void onLongPressStart(LongPressStartDetails details) {
    print('onLongPressStart:$details');
  }

  void onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    print('onLongPressMoveUpdate:$details');
  }

  void onLongPressUp() {
    print('onLongPressUp');
  }

  void onLongPressEnd(LongPressEndDetails details) {
    print('onLongPressEnd:$details');
  }

  void onSecondaryLongPressDown(LongPressDownDetails details) {
    print('onSecondaryLongPressDown:$details');
  }

  void onSecondaryLongPressCancel() {
    print('onSecondaryLongPressCancel');
  }

  void onSecondaryLongPress() {
    print('onSecondaryLongPress');
  }

  void onSecondaryLongPressStart(LongPressStartDetails details) {
    print('onSecondaryLongPressStart:$details');
  }

  void onSecondaryLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    print('onSecondaryLongPressMoveUpdate:$details');
  }

  void onSecondaryLongPressUp() {
    print('onSecondaryLongPressUp');
  }

  void onSecondaryLongPressEnd(LongPressEndDetails details) {
    print('onSecondaryLongPressEnd:$details');
  }

  void onTertiaryLongPressDown(LongPressDownDetails details) {
    print('onTertiaryLongPressDown:$details');
  }

  void onTertiaryLongPressCancel() {
    print('onTertiaryLongPressCancel');
  }

  void onTertiaryLongPress() {
    print('onTertiaryLongPress');
  }

  void onTertiaryLongPressStart(LongPressStartDetails details) {
    print('onTertiaryLongPressStart:$details');
  }

  void onTertiaryLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    print('onTertiaryLongPressMoveUpdate:$details');
  }

  void onTertiaryLongPressUp() {
    print('onTertiaryLongPressUp');
  }

  void onTertiaryLongPressEnd(LongPressEndDetails details) {
    print('onTertiaryLongPressEnd:$details');
  }

  void onVerticalDragDown(DragDownDetails details) {
    print('onVerticalDragDown:$details');
  }

  void onVerticalDragStart(DragStartDetails details) {
    print('onVerticalDragStart:$details');
  }

  void onVerticalDragUpdate(DragUpdateDetails details) {
    print('onVerticalDragUpdate:$details');
  }

  void onVerticalDragEnd(DragEndDetails details) {
    print('onVerticalDragEnd:$details');
  }

  void onVerticalDragCancel() {
    print('onVerticalDragCancel');
  }

  void onHorizontalDragDown(DragDownDetails details) {
    print('onHorizontalDragDown:$details');
  }

  void onHorizontalDragStart(DragStartDetails details) {
    print('onHorizontalDragStart:$details');
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    print('onHorizontalDragUpdate:$details');
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    print('onHorizontalDragEnd:$details');
  }

  void onHorizontalDragCancel() {
    print('onHorizontalDragCancel');
  }

  void onPanDown(DragDownDetails details) {
    print('onPanDown:$details');
  }

  void onPanStart(DragStartDetails details) {
    print('onPanStart:$details');
  }

  void onPanUpdate(DragUpdateDetails details) {
    print('onPanUpdate:$details');
  }

  void onPanEnd(DragEndDetails details) {
    print('onPanEnd:$details');
  }

  void onPanCancel() {
    print('onPanCancel');
  }

  void onScaleStart(ScaleStartDetails details) {
    print('onScaleStart:$details');
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    print('onScaleUpdate:$details');
  }

  void onScaleEnd(ScaleEndDetails details) {
    print('onScaleEnd:$details');
  }

  void onForcePressStart(ForcePressDetails details) {
    print('onForcePressStart:$details');
  }

  void onForcePressPeak(ForcePressDetails details) {
    print('onForcePressPeak:$details');
  }

  void onForcePressUpdate(ForcePressDetails details) {
    print('onForcePressUpdate:$details');
  }

  void onForcePressEnd(ForcePressDetails details) {
    print('onForcePressEnd:$details');
  }

  //鼠标相关的事件
  void onMouseEnter(PointerEvent details) {
    print('onMouseEnter:$details');
  }

  void onMouseExit(PointerEvent details) {
    print('onMouseExit:$details');
  }

  void onMouseHover(PointerEvent details) {
    print('onMouseHover:$details');
  }

}
