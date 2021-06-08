import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class BoundingRectItem {
  final double imageWidth;
  final double imageHeight;
  final Color innerRectColor;
  final double innerRectStrokeWidth;

  Rect rect;

  BoundingRectItem(
      {required this.imageWidth,
      required this.imageHeight,
      required double ratio,
      required this.innerRectColor,
      required double innerRectStrokeWidth})
      : rect = ui.Rect.fromLTRB(0, 0, 0, 0),
        innerRectStrokeWidth = innerRectStrokeWidth * ratio;

  void resize(Offset tl, Offset br) {
    double top = tl.dy;
    double left = tl.dx;
    double bottom = br.dy;
    double right = br.dx;

    if (br.dy < top) {
      final double temp = top;
      top = br.dy;
      bottom = temp;
    }

    if (br.dx < left) {
      final double temp = left;
      left = br.dx;
      right = temp;
    }

    /*
    * stkWidCenter ensure that the _boundingRect will not exceed the image bound
    * during onPaint() due to stroke width. 
    */

    final double stkWidCenter = innerRectStrokeWidth / 2;
    left = max(left, stkWidCenter);
    top = max(top, stkWidCenter);
    right = min(right, imageWidth - stkWidCenter);
    bottom = min(bottom, imageHeight - stkWidCenter);

    rect = ui.Rect.fromPoints(Offset(left, top), Offset(right, bottom));
  }

  void setPos(Offset tl) {
    if (!isReady()) return;

    final Offset br = tl + Offset(rect.width, rect.height);
    double left = tl.dx;
    double right = br.dx;
    double top = tl.dy;
    double bottom = br.dy;

    final double stkWidCenter = innerRectStrokeWidth / 2;
    if (tl.dx < stkWidCenter || br.dx > imageWidth - stkWidCenter) {
      left = rect.left;
      right = rect.right;
    }

    if (tl.dy < stkWidCenter || br.dy > imageHeight - stkWidCenter) {
      top = rect.top;
      bottom = rect.bottom;
    }

    rect = ui.Rect.fromPoints(Offset(left, top), Offset(right, bottom));
  }

  List<double>? toRegion() {
    if (!isReady()) return null;

    final double left = rect.left;
    final double top = rect.top;
    final double right = rect.right;
    final double bottom = rect.bottom;

    return [
      left / imageWidth,
      top / imageHeight,
      (right - left) / imageWidth,
      (bottom - top) / imageHeight
    ];
  }

  void paint(Canvas canvas) {
    final Paint _painter = Paint()
      ..color = innerRectColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = innerRectStrokeWidth;

    canvas.drawRect(rect, _painter);
  }

  void clear() => rect = ui.Rect.fromLTRB(0, 0, 0, 0);
  bool isReady() => !rect.isEmpty;
}
