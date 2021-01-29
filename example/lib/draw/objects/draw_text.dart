import 'dart:ui';

import 'package:flutter/painting.dart';
import 'package:window_paint/src/draw/draw_object.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';
import 'package:window_paint/src/draw/draw_point.dart';

class DrawText extends DrawObject {
  DrawText({
    required this.adapter,
    required this.color,
    required this.anchor,
    this.text = '',
    this.fontSize = 16,
  });

  @override
  final DrawObjectAdapter<DrawText> adapter;

  Color color;
  final DrawPoint anchor;

  String text;
  double fontSize;

  Color? _paintedColor;
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
        color: color,
        fontSize: fontSize,
      );
  TextSpan get textSpan => TextSpan(
        text: text,
        style: textStyle,
      );

  @override
  Color get primaryColor => color;

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
    _paintedColor = color;
    _paintedText = text;
    _paintedSize = textPainter.size;
  }

  @override
  bool shouldRepaint() => color != _paintedColor || text != _paintedText;

  @override
  void finalize() {}

  factory DrawText.fromJSON(
    DrawObjectAdapter<DrawText> adapter,
    Map<String, dynamic> encoded,
  ) {
    return DrawText(
      adapter: adapter,
      color: Color(encoded['color'] as int),
      anchor: DrawPoint.fromJSON(encoded['anchor']),
      text: encoded['text'] as String,
      fontSize: encoded['fontSize'] as double,
    );
  }

  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'color': color.value,
      'anchor': anchor.toJSON(),
      'text': text,
      'fontSize': fontSize,
    };
  }
}
