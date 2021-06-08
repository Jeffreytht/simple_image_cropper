library image_cropper;

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_image_cropper/image_preview/image_editor.dart';
import 'dart:ui' as ui;

class Region {
  final int x1;
  final int y1;
  final int x2;
  final int y2;

  const Region(
      {required this.x1, required this.x2, required this.y1, required this.y2});

  factory Region.fromLTRB(int x1, int y1, int x2, int y2) {
    return Region(x1: x1, x2: x2, y1: y1, y2: y2);
  }

  int get width => max(x2 - x1, 0);
  int get height => max(y2 - y1, 0);
  bool get isEmpty => width * height <= 1;

  Offset get topLeft => Offset(x1.toDouble(), y1.toDouble());
  Offset get bottomRight => Offset(x2.toDouble(), y2.toDouble());
}

class SimpleImageCropper extends StatelessWidget {
  final Key? key;
  final ui.Image image;
  final double width;
  final double height;
  final Color outerRectColor;
  final double outerRectStrokeWidth;
  final Color innerRectColor;
  final double innerRectStrokeWidth;
  final Color tlCornerBgColor;
  final Color tlCornerFontColor;
  final Color brCornerBgColor;
  final Color brCornerFontColor;
  final double margin = 30.0;
  late final ImageEditor imageEditor;
  final Function(Region) onRegionSelected;

  SimpleImageCropper(
      {required this.image,
      required this.width,
      required this.height,
      required this.onRegionSelected,
      this.key,
      this.outerRectColor = Colors.white,
      this.innerRectColor = Colors.red,
      this.outerRectStrokeWidth = 1.0,
      this.innerRectStrokeWidth = 3.0,
      this.tlCornerBgColor = Colors.white,
      this.tlCornerFontColor = Colors.grey,
      this.brCornerBgColor = Colors.blue,
      this.brCornerFontColor = Colors.white})
      : super(key: key) {
    final Size imgSize = Size(image.width.toDouble(), image.height.toDouble());
    final Size editorSize = Size(width - margin * 2, height - margin * 2);

    imageEditor = ImageEditor(
      image: image,
      scaleRatio: _getRatio(editorSize, imgSize),
      imgOffset:
          _getOffset(editorSize, imgSize, _getRatio(editorSize, imgSize)) +
              Offset(margin, margin),
      onRegionSelected: onRegionSelected,
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

  static Future<ui.Image?> cropImage(
      {required ui.Image image,
      required Region region,
      int channel = 4}) async {
    if (region.isEmpty) return null;
    if (region.width > image.width || region.height > image.height) return null;

    final ByteData? imgData = await image.toByteData();
    if (imgData == null) return null;

    Completer<ui.Image> imgCompleter = Completer<ui.Image>();

    final Uint8List resImgList =
        Uint8List(region.width * region.height * channel);
    final Uint8List oriImageList = imgData.buffer.asUint8List();

    for (int row = region.y1, idx = 0; row < region.y2; row++) {
      for (int col = region.x1; col < region.x2; col++) {
        int rc = row * image.width * channel + col * channel;
        for (int k = 0; k < channel; k++, idx++) {
          resImgList[idx] = oriImageList[rc + k];
        }
      }
    }

    ui.decodeImageFromPixels(resImgList, region.width, region.height,
        ui.PixelFormat.rgba8888, imgCompleter.complete);

    return imgCompleter.future;
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
                        child: CustomPaint(painter: imageEditor))))));
  }

  void _onPanUpdate(DragUpdateDetails details) {
    imageEditor.onPanUpdate(details.localPosition);
  }

  void _onPanDown(DragDownDetails details) {
    imageEditor.onPanDown(details.localPosition);
  }

  void _onPanEnd(_) {
    imageEditor.onPanEnd();
  }

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
}
