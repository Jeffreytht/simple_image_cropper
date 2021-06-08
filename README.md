# Simple Image Cropper

[![pub package](https://img.shields.io/pub/v/simple_image_cropper.svg)](https://pub.dev/packages/simple_image_cropper)

A Flutter plugin for cropping images.

## Image

Crop your image by selecting the region.

![Demo](assets/images/demo.gif)

## Installation

To use this plugin, add `simple_image_cropper` as a dependency in the pubspec.yaml.

## Required parameters

- **image**: The image to be cropped
- **width**: The width of this widget
- **height**: The height of this widget
- **onRegionSelected**: A callback function to retrieve the selected region

## Customization

| Property | Description | Type |
| ----------------- |----------|:-----------:|
| `outerRectColor`  | Change the color of the outer rectangle. The default color is white color. | Color |
| `outerRectColor` | Change the color of the outer rectangle. The default color is white color. | Color |
| `innerRectColor` |  Change the color of the inner rectangle. The default color is red color. | Color |
| `outerRectStrokeWidth` |  Change the outer rectangle stroke width. The default value is 1.0. | double |
| `innerRectStrokeWidth` |  Change the inner rectangle stroke width. The default value is 3.0. | double |
| `tlConerBgColor` |  Change the cancel button background color. The default color is white color. | Color |
| `tlCornerFontColor` |  Change the cancel button font color. The default color is grey color. | Color |
| `brCornerBgColor` |  Change the resize button background color. The default color is blue color. | Color |
| `brCornerFontColor` |  Change the resize button font color. The default color is white color | Color |

## Example

```dart
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:flutter/material.dart';
import 'package:simple_image_cropper/simple_image_cropper.dart';
import 'dart:ui' as ui;


class Demo extends StatefulWidget {
  Demo({Key? key}) : super(key: key);

  @override
  _DemoState createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  ui.Image? _image;
  Region region = Region.fromLTRB(0, 0, 0, 0);

  @override
  void initState() {
    loadImages();
    super.initState();
  }

  Future<void> loadImages() async {
    final ByteData byteData = await rootBundle.load({YOUR IMAGE PATH}});
    final ui.Image image =
        await decodeImageFromList(byteData.buffer.asUint8List());
    setState(() => _image = image);
  }

  @override
  Widget build(BuildContext context) {
    if (_image == null) return CircularProgressIndicator();

    final Size size = MediaQuery.of(context).size;
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.crop),
          onPressed: () async {
            ui.Image? croppedImage = await SimpleImageCropper.cropImage(
                image: _image!, region: region);
            setState(() => _image = croppedImage);
          },
        ),
        body: Container(
            height: size.height,
            width: size.width,
            child: SimpleImageCropper(
              height: size.height,
              width: size.width,
              image: _image!,
              onRegionSelected: onRegionSelected,
            )));
  }

  void onRegionSelected(Region region) {
    this.region = region;
  }
}

```
