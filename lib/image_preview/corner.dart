import 'package:flutter/material.dart';

class Corner {
  final double _fontSize;
  final double _radius;
  final double scaleRatio;
  final IconData icon;
  final Color fontColor;
  final Color bgColor;

  Offset loc = const Offset(0, 0);

  Corner(
      {required this.icon,
      required this.scaleRatio,
      required this.fontColor,
      required this.bgColor})
      : _fontSize = 20.0 * scaleRatio,
        _radius = 15.0 * scaleRatio;

  void paint(Canvas canvas) {
    final Paint _painter = Paint()
      ..style = PaintingStyle.fill
      ..color = bgColor;

    canvas.drawCircle(loc, _radius, _painter);
    final TextPainter textPainter =
        TextPainter(textDirection: TextDirection.ltr);

    textPainter.text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
            fontSize: _fontSize,
            fontFamily: icon.fontFamily,
            color: fontColor));

    textPainter.layout();
    textPainter.paint(canvas, loc - Offset(_fontSize / 2, _fontSize / 2));
  }

  bool acceptEvent(Offset eventLoc) {
    final double tolerance = _radius + 10 * scaleRatio;
    if ((eventLoc.dx - loc.dx).abs() <= tolerance &&
        (eventLoc.dy - loc.dy).abs() <= tolerance) {
      return true;
    }
    return false;
  }
}
