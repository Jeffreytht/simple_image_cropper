import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:simple_image_cropper/simple_image_cropper.dart';

class BoundingRectItem {
  final double imageWidth;
  final double imageHeight;
  final Color innerRectColor;
  final double innerRectStrokeWidth;

  Region rect;

  BoundingRectItem(
      {required this.imageWidth,
      required this.imageHeight,
      required double ratio,
      required this.innerRectColor,
      required double innerRectStrokeWidth})
      : rect = Region.fromLTRB(0, 0, 0, 0),
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

    rect = Region(
        x1: left.toInt(),
        y1: top.toInt(),
        x2: right.toInt(),
        y2: bottom.toInt());
  }

  void setPos(Offset tl) {
    if (!isReady()) return;

    final Offset br =
        tl + Offset(rect.width.toDouble(), rect.height.toDouble());
    int left = tl.dx.toInt();
    int right = br.dx.toInt();
    int top = tl.dy.toInt();
    int bottom = br.dy.toInt();

    final int stkWidCenter = innerRectStrokeWidth ~/ 2;
    if (tl.dx < stkWidCenter || br.dx > imageWidth - stkWidCenter) {
      left = rect.x1;
      right = rect.x2;
    }

    if (tl.dy < stkWidCenter || br.dy > imageHeight - stkWidCenter) {
      top = rect.y1;
      bottom = rect.y2;
    }

    rect = Region(
        x1: left.toInt(),
        y1: top.toInt(),
        x2: right.toInt(),
        y2: bottom.toInt());
  }

  Region get region => rect;

  void paint(Canvas canvas) {
    final Paint _painter = Paint()
      ..color = innerRectColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = innerRectStrokeWidth;

    final Rect innerRect = ui.Rect.fromLTRB(rect.x1.toDouble(),
        rect.y1.toDouble(), rect.x2.toDouble(), rect.y2.toDouble());
    canvas.drawRect(innerRect, _painter);
  }

  void clear() => rect = Region.fromLTRB(0, 0, 0, 0);
  bool isReady() => !rect.isEmpty;
}
