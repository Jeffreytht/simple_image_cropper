import 'package:flutter/material.dart';
import 'package:simple_image_cropper/image_preview/inner_rect_item.dart';
import 'package:simple_image_cropper/image_preview/corner.dart';
import 'package:simple_image_cropper/image_preview/image_editor_mode.dart';
import 'package:simple_image_cropper/simple_image_cropper.dart';

class CornerGrabber {
  /// Top left corner and bottom right corner.
  final List<Corner> _corners;

  /// The inner rectangle
  final InnerRectItem boundingRectItem;

  /// The margin of inner rectangle
  final Offset margin;

  /// The color of outer ractangle
  final Color outerRectColor;

  /// The stroke width of outer rectangle
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
      : boundingRectItem = InnerRectItem(
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

  /// Set the position of corner grabber
  void setPos(Offset loc) {
    boundingRectItem.setPos(loc);
    _updateCornersGrabber();
  }

  /// Resize the corner grabber
  void resize(Offset tl, Offset br) {
    boundingRectItem.resize(tl, br);
    _updateCornersGrabber();
  }

  /// Move the corner to the correct position
  void _updateCornersGrabber() {
    _corners[0].loc = boundingRectItem.region.topLeft - margin;
    _corners[1].loc = boundingRectItem.region.bottomRight + margin;
  }

  void paint(Canvas canvas) {
    if (!boundingRectItem.isReady()) return;
    boundingRectItem.paint(canvas);

    final rect = Rect.fromPoints(boundingRectItem.region.topLeft - margin,
        boundingRectItem.region.bottomRight + margin);

    final Paint _painter = Paint()
      ..color = outerRectColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = outerRectStrokeWidth;

    canvas.drawRect(rect, _painter);

    for (final Corner corner in _corners) {
      corner.paint(canvas);
    }
  }

  /// Check whether the corner grabber is drawn
  bool isReady() => boundingRectItem.isReady();

  /// Get the selected region
  Region get region => boundingRectItem.region;

  /// Handle the tap event
  ///
  /// Check if user tap on the corners or rectangle.
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
