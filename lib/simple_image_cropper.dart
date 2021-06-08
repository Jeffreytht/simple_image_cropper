library image_cropper;

import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:simple_image_cropper/image_preview/image_editor.dart';

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

class SimpleImageCropperState extends State<SimpleImageCropper> {
  ImageEditor? imageEditor;
  ImageStream? _imageStream;
  ImageInfo? _imageInfo;
  final double margin = 30.0;

  @override
  Widget build(BuildContext context) {
    if (_imageInfo == null) {
      return Container(
          alignment: Alignment.center,
          child: const CircularProgressIndicator());
    }

    final double imgWidth = _imageInfo!.image.width.toDouble();
    final double imgHeight = _imageInfo!.image.height.toDouble();

    final Size imgSize = Size(imgWidth, imgHeight);
    final Size editorSize =
        Size(widget.width - margin * 2, widget.height - margin * 2);

    imageEditor = ImageEditor(
      image: _imageInfo!.image,
      scaleRatio: _getRatio(editorSize, imgSize),
      imgOffset:
          _getOffset(editorSize, imgSize, _getRatio(editorSize, imgSize)) +
              Offset(margin, margin),
      onRegionSelected: widget.onRegionSelected,
      outerRectColor: widget.outerRectColor,
      outerRectStrokeWidth: widget.outerRectStrokeWidth,
      innerRectStrokeWidth: widget.innerRectStrokeWidth,
      innerRectColor: widget.innerRectColor,
      tlCornerBgColor: widget.tlCornerBgColor,
      tlCornerFontColor: widget.tlCornerFontColor,
      brCornerBgColor: widget.brCornerBgColor,
      brCornerFontColor: widget.brCornerFontColor,
    );

    return GestureDetector(
        onPanDown: _onPanDown,
        onPanUpdate: _onPanUpdate,
        onPanEnd: _onPanEnd,
        child: Container(
            color: Colors.black,
            alignment: Alignment.center,
            child: SizedBox(
                height: widget.height - margin * 2,
                width: widget.width - margin * 2,
                child: FittedBox(
                    child: SizedBox(
                        height: imgHeight,
                        width: imgWidth,
                        child: CustomPaint(painter: imageEditor))))));
  }

  void _onPanUpdate(DragUpdateDetails details) {
    imageEditor!.onPanUpdate(details.localPosition);
  }

  void _onPanDown(DragDownDetails details) {
    imageEditor!.onPanDown(details.localPosition);
  }

  void _onPanEnd(_) {
    imageEditor!.onPanEnd();
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _getImage();
  }

  @override
  void didUpdateWidget(SimpleImageCropper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.image != oldWidget.image) _getImage();
  }

  void _getImage() {
    final ImageStream? oldImageStream = _imageStream;
    _imageStream = widget.image.resolve(createLocalImageConfiguration(context));
    if (_imageStream!.key != oldImageStream?.key) {
      final ImageStreamListener listener = ImageStreamListener(_updateImage);
      oldImageStream?.removeListener(listener);
      _imageStream!.addListener(listener);
    }
  }

  void _updateImage(ImageInfo imageInfo, bool synchronousCall) {
    setState(() {
      _imageInfo?.dispose();
      _imageInfo = imageInfo;
    });
  }

  @override
  void dispose() {
    _imageStream?.removeListener(ImageStreamListener(_updateImage));
    _imageInfo?.dispose();
    _imageInfo = null;
    super.dispose();
  }

  Future<Image?> cropImage() async {
    if (imageEditor == null) return null;
    final ui.Image image = _imageInfo!.image;
    final Completer<Image?> imgCompleter = Completer();
    final Region region = imageEditor!.region;

    if (region.isEmpty) return null;
    if (region.width > image.width || region.height > image.height) return null;

    final ByteData? imgData = await image.toByteData();
    if (imgData == null) return null;

    const int channel = 4;
    final Uint8List resImgList =
        Uint8List(region.width * region.height * channel);
    final Uint8List oriImageList = imgData.buffer.asUint8List();

    for (int row = region.y1, idx = 0; row < region.y2; row++) {
      for (int col = region.x1; col < region.x2; col++) {
        final int rc = row * image.width * channel + col * channel;
        for (int k = 0; k < channel; k++, idx++) {
          resImgList[idx] = oriImageList[rc + k];
        }
      }
    }

    ui.decodeImageFromPixels(
        resImgList, region.width, region.height, ui.PixelFormat.rgba8888,
        (image) async {
      final ByteData? byte =
          await image.toByteData(format: ui.ImageByteFormat.png);
      imgCompleter.complete(Image.memory(byte!.buffer.asUint8List()));
    });

    return imgCompleter.future;
  }
}

class SimpleImageCropper extends StatefulWidget {
  final ImageProvider image;
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
  final Function(Region)? onRegionSelected;

  const SimpleImageCropper(
      {required this.image,
      required this.width,
      required this.height,
      this.onRegionSelected,
      GlobalKey? key,
      this.outerRectColor = Colors.white,
      this.innerRectColor = Colors.red,
      this.outerRectStrokeWidth = 1.0,
      this.innerRectStrokeWidth = 3.0,
      this.tlCornerBgColor = Colors.white,
      this.tlCornerFontColor = Colors.grey,
      this.brCornerBgColor = Colors.blue,
      this.brCornerFontColor = Colors.white})
      : super(key: key);

  @override
  SimpleImageCropperState createState() => SimpleImageCropperState();
}
