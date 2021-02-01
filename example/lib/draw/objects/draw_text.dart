import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:window_paint/src/draw/draw_object.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';
import 'package:window_paint/src/draw/draw_point.dart';
import 'package:window_paint/src/mixins/drag_handle_mixin.dart';

class DrawText extends DrawObject with DragHandleMixin {
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
  DrawPoint anchor;
  String text;
  double fontSize;

  var selected = false;

  Color? _paintedColor;
  DrawPoint? _paintedAnchor;
  String? _paintedText;
  Size? _paintedSize;
  bool? _paintedSelected;

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
    prePaintDragHandle(canvas);
    textPainter.paint(canvas, anchor.offset);
    if (selected) {
      _paintOutline(canvas, size);
    }
    postPaintDragHandle(canvas);
    _paintedColor = color;
    _paintedAnchor = anchor;
    _paintedText = text;
    _paintedSize = textPainter.size;
    _paintedSelected = selected;
  }

  void _paintOutline(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0x8A000000)
      ..strokeWidth = 1.0 / anchor.scale
      ..style = PaintingStyle.stroke;
    canvas.drawRect(outline, paint);
  }

  @override
  bool shouldRepaint() =>
      super.shouldRepaint() ||
      color != _paintedColor ||
      anchor != _paintedAnchor ||
      text != _paintedText ||
      selected != _paintedSelected;

  @override
  @protected
  void finalizeDragHandlePoints(Offset offset) {
    anchor = anchor.copyWith(
      offset: anchor.offset + offset,
    );
  }

  factory DrawText.fromJSON(DrawObjectAdapter<DrawText> adapter, Map encoded) {
    return DrawText(
      adapter: adapter,
      color: Color(encoded['color'] as int),
      anchor: DrawPoint.fromJSON(encoded['anchor'] as Map),
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
