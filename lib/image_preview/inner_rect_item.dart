import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:simple_image_cropper/simple_image_cropper.dart';

class InnerRectItem {
  /// This image's width
  final double imageWidth;

  /// This image's height
  final double imageHeight;

  /// The color of inner rectangle
  final Color innerRectColor;

  /// The stroke width of inner rectangle
  final double innerRectStrokeWidth;

  /// Selected region
  Region region;

  InnerRectItem(
      {required this.imageWidth,
      required this.imageHeight,
      required double ratio,
      required this.innerRectColor,
      required double innerRectStrokeWidth})
      : region = Region.fromLTRB(0, 0, 0, 0),
        innerRectStrokeWidth = innerRectStrokeWidth * ratio;

  /// Resize this inner rect
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

    region = Region(
        x1: left.toInt(),
        y1: top.toInt(),
        x2: right.toInt(),
        y2: bottom.toInt());
  }

  /// Move this inner rect
  void setPos(Offset tl) {
    if (!isReady()) return;

    final Offset br =
        tl + Offset(region.width.toDouble(), region.height.toDouble());
    int left = tl.dx.toInt();
    int right = br.dx.toInt();
    int top = tl.dy.toInt();
    int bottom = br.dy.toInt();

    final int stkWidCenter = innerRectStrokeWidth ~/ 2;
    if (tl.dx < stkWidCenter || br.dx > imageWidth - stkWidCenter) {
      left = region.x1;
      right = region.x2;
    }

    if (tl.dy < stkWidCenter || br.dy > imageHeight - stkWidCenter) {
      top = region.y1;
      bottom = region.y2;
    }

    region = Region(
        x1: left.toInt(),
        y1: top.toInt(),
        x2: right.toInt(),
        y2: bottom.toInt());
  }

  void paint(Canvas canvas) {
    final Paint _painter = Paint()
      ..color = innerRectColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = innerRectStrokeWidth;

    final Rect innerRect = ui.Rect.fromLTRB(region.x1.toDouble(),
        region.y1.toDouble(), region.x2.toDouble(), region.y2.toDouble());
    canvas.drawRect(innerRect, _painter);
  }

  /// Clear the selected region
  void clear() => region = Region.fromLTRB(0, 0, 0, 0);

  /// Check if the region is drawn
  bool isReady() => !region.isEmpty;
}
