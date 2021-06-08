import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:simple_image_cropper/image_preview/corner_grabber.dart';
import 'package:simple_image_cropper/image_preview/image_editor_mode.dart';

class ImageEditor extends CustomPainter {
  final CornerGrabber _cornerGrabber;
  final ui.Image image;
  final Offset imgOffset;
  final double scaleRatio;

  Offset _panDownPt;
  ImageEditorMode _mode;

  ImageEditor(
      {required this.image,
      required this.scaleRatio,
      required this.imgOffset,
      required Color outerRectColor,
      required double outerRectStrokeWidth,
      required Color innerRectColor,
      required double innerRectStrokeWidth,
      required Color tlCornerBgColor,
      required Color tlCornerFontColor,
      required Color brCornerBgColor,
      required Color brCornerFontColor})
      : _cornerGrabber = CornerGrabber(
            outerRectColor: outerRectColor,
            outerRectStrokeWidth: outerRectStrokeWidth,
            innerRectColor: innerRectColor,
            innerRectStrokeWidth: innerRectStrokeWidth,
            brCornerFontColor: brCornerFontColor,
            brCornerBgColor: brCornerBgColor,
            tlCornerBgColor: tlCornerBgColor,
            tlCornerFontColor: tlCornerFontColor,
            imageWidth: image.width.toDouble(),
            imageHeight: image.height.toDouble(),
            scaleRatio: scaleRatio),
        _mode = ImageEditorMode.none,
        _panDownPt = Offset(0, 0);

  @override
  void paint(ui.Canvas canvas, ui.Size size) {
    canvas.drawImage(image, Offset.zero, Paint());
    _cornerGrabber.paint(canvas);
  }

  @override
  bool shouldRepaint(ImageEditor oldDelegate) {
    return true;
  }

  void onPanUpdate(Offset globalPt) {
    final Offset currPt = globalToLocalPt(globalPt);
    switch (_mode) {
      case ImageEditorMode.none:
        _cornerGrabber.resize(_panDownPt, currPt);
        break;
      case ImageEditorMode.resizing:
        _cornerGrabber.resize(_panDownPt, currPt - _cornerGrabber.margin);
        break;
      case ImageEditorMode.moving:
        _cornerGrabber.setPos(currPt - _panDownPt);
        _panDownPt = currPt - _cornerGrabber.boudingRectItem.topLeft;
        break;
      case ImageEditorMode.boudingRectReady:
      default:
        break;
    }
  }

  void onPanDown(Offset globalPt) {
    final Offset currPt = globalToLocalPt(globalPt);
    if (_mode == ImageEditorMode.none) {
      _panDownPt = currPt;
      _cornerGrabber.resize(currPt, currPt);
    } else if (_mode == ImageEditorMode.boudingRectReady) {
      final ImageEditorMode? mode = _cornerGrabber.handleEvent(currPt);

      if (mode == null) return;

      if (mode == ImageEditorMode.moving) {
        _panDownPt = currPt - _cornerGrabber.boudingRectItem.topLeft;
      }

      _mode = mode;
    }
  }

  void onPanEnd() {
    if (_cornerGrabber.isReady()) {
      _panDownPt = _cornerGrabber.boudingRectItem.topLeft;
      _mode = ImageEditorMode.boudingRectReady;
    }
  }

  Offset globalToLocalPt(Offset global) => (global - imgOffset) * scaleRatio;

  List<double>? get region {
    return _cornerGrabber.region;
  }
}
