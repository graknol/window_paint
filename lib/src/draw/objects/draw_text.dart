import 'dart:ui';

import 'package:window_paint/src/draw/draw_object.dart';
import 'package:window_paint/src/draw/draw_point.dart';

class DrawText extends DrawObject {
  DrawText({
    required this.anchor,
    this.text = '',
    ParagraphStyle? paragraphStyle,
  }) : paragraphStyle = paragraphStyle ?? ParagraphStyle();

  final DrawPoint anchor;
  final ParagraphStyle paragraphStyle;

  String text;
  String? _lastPaintedText;

  TextStyle get textStyle => TextStyle(
        color: anchor.paint.color,
      );
  Paragraph get paragraph => (ParagraphBuilder(paragraphStyle)
        ..pushStyle(textStyle)
        ..addText(text))
      .build();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawParagraph(paragraph, anchor.offset);
    _lastPaintedText = text;
  }

  @override
  bool shouldRepaint() => text != _lastPaintedText;

  @override
  void finalize() {}
}
