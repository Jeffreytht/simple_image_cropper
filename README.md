# Simple Image Cropper
[![Software License](https://img.shields.io/github/license/Jeffreytht/simple_image_cropper)](LICENSE)<br>
A simple Flutter plugin for Android and IOS supports cropping images.
## Introduction 
The plugin comes with a `ImageCropper` Widget.
This project strives to give the simple and user friendly image cropping experience possible.
## Installation
Add `simple_image_cropper` [![simple_image_cropper](https://img.shields.io/badge/pub-v.0.0.1-brightgreen)](https://pub.dev/packages/simple_image_cropper) as [a dependency in `pubspec.yaml`](https://flutter.io/using-packages/#managing-package-dependencies--versions).
## Usage
Required parameters
- **image**: the image data in `ui.Image` type.
- **width**: the whole width of the screen.
- **height**: the whole height of the screen.

Optional parameters
- **outerRectColor**: change the color of the outer rectangle. The default color is white color.
- **innerRectColor**: change the color of the inner rectangle. The default color is red color.
- **outerRectStrokeWidth**: change the outer rectangle stroke width. The default value is 1.0.
- **innerRectStrokeWidth**: change the inner rectangle stroke width. The default value is 3.0.
- **tlConerBgColor**: change the cancel button background color. The default color is white color.
- **tlCornerFontColor**: change the cancel button font color. The default color is grey color.
- **brCornerBgColor**: change the resize button background color. The default color is blue color.
- **brCornerFontColor**: change the resize button font color. The default color is white color. 

## Example
````dart

import 'package:simple_image_cropper/simple_image_cropper.dart';

Widget build(BuildContext context) {
    if (_imageCropper == null) return Container();

    final Size size = MediaQuery.of(context).size;
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.crop),
          onPressed: () async {
            final ui.Image? image = await _imageCropper!.getCroppedImage();
            if (image == null) return;

            setState(() {
              _imageCropper = ImageCropper(
                image: image,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                outerRectColor: Colors.cyan,
                outerRectStrokeWidth: 5,
                innerRectStrokeWidth: 1,
                innerRectColor: Colors.purple,
                tlCornerBgColor: Colors.red,
                brCornerBgColor: Colors.pink,
                tlCornerFontColor: Colors.orange,
                brCornerFontColor: Colors.lightGreenAccent
              );
            });
          },
        ),
        body: Container(
            alignment: Alignment.center,
            color: Colors.black,
            height: size.height,
            width: size.width,
            child: _imageCropper));
  }    
````

## Credits
* Developed by [Tan Hoe Theng](https://github.com/Jeffreytht) & [Lau Kuan Sin](https://github.com/laukuansin)
