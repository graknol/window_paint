import 'dart:ui';

import 'package:example/draw/adapters/draw_text_adapter.dart';
import 'package:flutter/painting.dart';
import 'package:window_paint/src/draw/draw_object.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';
import 'package:window_paint/src/draw/draw_point.dart';

class DrawText extends DrawObject {
  DrawText({
    required this.anchor,
    this.text = '',
    this.fontSize = 16,
  });

  final DrawPoint anchor;

  String text;
  double fontSize;

  String? _paintedText;
  Size? _paintedSize;

  Rect get rect => Rect.fromLTWH(
        anchor.offset.dx,
        anchor.offset.dy,
        _paintedSize?.width ?? 0.0,
        _paintedSize?.height ?? 0.0,
      );

  Iterable<Rect> get hitboxes sync* {
    if (_paintedSize != null) {
      yield rect.inflate(5.0 / anchor.scale);
    }
  }

  Rect get outline => rect.inflate(5.0 / anchor.scale);

  TextStyle get textStyle => TextStyle(
        color: anchor.paint.color,
        fontSize: fontSize,
      );
  TextSpan get textSpan => TextSpan(
        text: text,
        style: textStyle,
      );

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    )..layout(
        maxWidth: size.width - anchor.offset.dx,
      );
    textPainter.paint(canvas, anchor.offset);
    _paintedText = text;
    _paintedSize = textPainter.size;
  }

  @override
  bool shouldRepaint() => text != _paintedText;

  @override
  void finalize() {}

  @override
  DrawObjectAdapter<DrawObject> get adapter => const DrawTextAdapter();

  @override
  Color get primaryColor => anchor.paint.color;
}
