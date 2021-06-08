import 'package:flutter/material.dart';
import 'package:simple_image_cropper/image_preview/bounding_rect_item.dart';
import 'package:simple_image_cropper/image_preview/corner.dart';
import 'package:simple_image_cropper/image_preview/image_editor_mode.dart';

class CornerGrabber {
  final List<Corner> _corners;
  final BoundingRectItem boundingRectItem;
  final Offset margin;
  final Color outerRectColor;
  final double outerRectStrokeWidth;

  CornerGrabber(
      {required double imageWidth,
      required double imageHeight,
      required double scaleRatio,
      required this.outerRectColor,
      required double outerRectStrokeWidth,
      required Color innerRectColor,
      required double innerRectStrokeWidth,
      required Color tlCornerBgColor,
      required Color tlCornerFontColor,
      required Color brCornerBgColor,
      required Color brCornerFontColor})
      : boundingRectItem = BoundingRectItem(
            imageWidth: imageWidth,
            imageHeight: imageHeight,
            ratio: scaleRatio,
            innerRectColor: innerRectColor,
            innerRectStrokeWidth: innerRectStrokeWidth),
        margin = const Offset(15.0, 15.0) * scaleRatio,
        outerRectStrokeWidth = outerRectStrokeWidth * scaleRatio,
        _corners = List.unmodifiable([
          Corner(
              icon: Icons.clear,
              fontColor: tlCornerFontColor,
              bgColor: tlCornerBgColor,
              scaleRatio: scaleRatio),
          Corner(
              icon: Icons.sync,
              fontColor: brCornerFontColor,
              bgColor: brCornerBgColor,
              scaleRatio: scaleRatio)
        ]);

  void setPos(Offset loc) {
    boundingRectItem.setPos(loc);
    _updateCornersGrabber();
  }

  void resize(Offset tl, Offset br) {
    boundingRectItem.resize(tl, br);
    _updateCornersGrabber();
  }

  void _updateCornersGrabber() {
    _corners[0].loc = boundingRectItem.rect.topLeft - margin;
    _corners[1].loc = boundingRectItem.rect.bottomRight + margin;
  }

  void paint(Canvas canvas) {
    if (!boundingRectItem.isReady()) return;
    boundingRectItem.paint(canvas);

    final rect = Rect.fromPoints(boundingRectItem.rect.topLeft - margin,
        boundingRectItem.rect.bottomRight + margin);

    final Paint _painter = Paint()
      ..color = outerRectColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = outerRectStrokeWidth;

    canvas.drawRect(rect, _painter);

    for (final Corner corner in _corners) {
      corner.paint(canvas);
    }
  }

  bool isReady() => boundingRectItem.isReady();

  Rect get boudingRectItem => boundingRectItem.rect;

  List<double>? get region => boundingRectItem.toRegion();

  ImageEditorMode? handleEvent(Offset eventLoc) {
    if (_corners[0].acceptEvent(eventLoc)) {
      boundingRectItem.clear();
      return ImageEditorMode.none;
    }

    if (_corners[1].acceptEvent(eventLoc)) {
      return ImageEditorMode.resizing;
    }

    if (_corners[0].loc <= eventLoc && eventLoc <= _corners[1].loc) {
      return ImageEditorMode.moving;
    }

    return null;
  }
}
