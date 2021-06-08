library image_cropper;

import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_image_cropper/image_preview/image_editor.dart';
import 'dart:ui' as ui;

class ImageCropper extends StatelessWidget {
  final ui.Image image;
  final double width;
  final double height;
  final double margin = 30;
  final GlobalKey _imageEditorKey = GlobalKey();
  ImageEditor? _imageEditor;

  ImageCropper(
      {required this.image,
      required this.width,
      required this.height,
      Color outerRectColor = Colors.white,
      Color innerRectColor = Colors.red,
      double outerRectStrokeWidth = 1.0,
      double innerRectStrokeWidth = 3.0,
      Color tlCornerBgColor = Colors.white,
      Color tlCornerFontColor = Colors.grey,
      Color brCornerBgColor = Colors.blue,
      Color brCornerFontColor = Colors.white}) {
    final Size imgSize = Size(image.width.toDouble(), image.height.toDouble());

    final Size editorSize = Size(width - margin * 2, height - margin * 2);

    _imageEditor = ImageEditor(
      image: image,
      scaleRatio: _getRatio(editorSize, imgSize),
      imgOffset:
          _getOffset(editorSize, imgSize, _getRatio(editorSize, imgSize)) +
              Offset(margin, margin),
      outerRectColor: outerRectColor,
      outerRectStrokeWidth: outerRectStrokeWidth,
      innerRectStrokeWidth: innerRectStrokeWidth,
      innerRectColor: innerRectColor,
      tlCornerBgColor: tlCornerBgColor,
      tlCornerFontColor: tlCornerFontColor,
      brCornerBgColor: brCornerBgColor,
      brCornerFontColor: brCornerFontColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onPanDown: _onPanDown,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: SizedBox(
                height: height - margin * 2,
                width: width - margin * 2,
                child: FittedBox(
                    child: SizedBox(
                        height: image.height.toDouble(),
                        width: image.width.toDouble(),
                        child: CustomPaint(
                            key: _imageEditorKey, painter: _imageEditor))))));
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _imageEditor!.onPanUpdate(details.localPosition);
    repaintImageEditor();
  }

  void _onPanDown(DragDownDetails details) {
    _imageEditor!.onPanDown(details.localPosition);
    repaintImageEditor();
  }

  void _onPanEnd(_) {
    _imageEditor!.onPanEnd();
    repaintImageEditor();
  }

  void repaintImageEditor() =>
      _imageEditorKey.currentContext?.findRenderObject()?.markNeedsPaint();

  double _getRatio(Size widgetSize, Size imageSize) {
    final double widgetWidth = widgetSize.width;
    final double widgetHeight = widgetSize.height;

    final double ratioX = imageSize.width / widgetWidth;
    final double ratioY = imageSize.height / widgetHeight;

    if (imageSize.height / ratioX > widgetHeight) return ratioY;
    return ratioX;
  }

  Offset _getOffset(Size widgetSize, Size imageSize, double scaleRatio) {
    final imgWidth = imageSize.width / scaleRatio;
    final imgHeight = imageSize.height / scaleRatio;

    final double offsetX = (widgetSize.width - imgWidth) / 2;
    final double offsetY = (widgetSize.height - imgHeight) / 2;
    return Offset(offsetX, offsetY);
  }

  List<double>? getRegion() => _imageEditor?.region;

  Future<ui.Image?> getCroppedImage() async {
    List<double>? region = getRegion();
    if (region == null) return null;

    final ByteData? imgData = await image.toByteData();
    if (imgData == null) return null;

    final int x = (region[0] * image.width).toInt();
    final int y = (region[1] * image.height).toInt();
    final int width = (region[2] * image.width).toInt();
    final int height = (region[3] * image.height).toInt();

    Completer<ui.Image> completer = Completer<ui.Image>();
    final int totalChannel = 4;
    final Uint8List finalImageList = Uint8List(width * height * totalChannel);
    final Uint8List oriImageList = imgData.buffer.asUint8List();

    for (int row = y, idx = 0; row < y + height; row++) {
      for (int col = x; col < x + width; col++) {
        int rc = row * image.width * totalChannel + col * totalChannel;
        for (int k = 0; k < totalChannel; k++, idx++) {
          finalImageList[idx] = oriImageList[rc + k];
        }
      }
    }

    ui.decodeImageFromPixels(finalImageList, width, height,
        ui.PixelFormat.rgba8888, completer.complete);

    return completer.future;
  }
}
