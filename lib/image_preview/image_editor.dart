import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:simple_image_cropper/image_preview/corner_grabber.dart';
import 'package:simple_image_cropper/image_preview/image_editor_mode.dart';
import 'package:simple_image_cropper/simple_image_cropper.dart';

class ImageEditor extends ChangeNotifier implements CustomPainter {
  final CornerGrabber _cornerGrabber;

  /// Image to be cropped
  final ui.Image image;

  /// The offset from [SimpleImageCropper]
  final Offset imgOffset;

  /// The ratio from [SimpleImageCropper]
  final double scaleRatio;

  /// The callback from [SimpleImageCropper]
  final Function(Region)? onRegionSelected;

  /// The point where user tap
  Offset _panDownPt;

  /// Current ImageEditor's mode
  ImageEditorMode _mode;

  ImageEditor(
      {required this.image,
      required this.scaleRatio,
      required this.imgOffset,
      this.onRegionSelected,
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
        _panDownPt = const Offset(0, 0);

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
        _panDownPt = currPt - _cornerGrabber.region.topLeft;
        break;
      case ImageEditorMode.boudingRectReady:
      default:
        break;
    }
    notifyListeners();
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
        _panDownPt = currPt - _cornerGrabber.region.topLeft;
      }

      _mode = mode;
    }
    notifyListeners();
  }

  void onPanEnd() {
    if (_cornerGrabber.isReady()) {
      _panDownPt = _cornerGrabber.region.topLeft;
      _mode = ImageEditorMode.boudingRectReady;

      if (onRegionSelected != null) onRegionSelected!(region);
    }
    notifyListeners();
  }

  /// Convert global position [global] to local position
  Offset globalToLocalPt(Offset global) => (global - imgOffset) * scaleRatio;

  /// Get the region from corner grabber
  Region get region {
    return _cornerGrabber.region;
  }

  @override
  bool? hitTest(ui.Offset position) => null;

  @override
  SemanticsBuilderCallback? get semanticsBuilder => null;

  @override
  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) => false;
}
