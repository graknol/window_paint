import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:window_paint/src/draw/draw_object.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';
import 'package:window_paint/src/draw/draw_point.dart';
import 'package:window_paint/src/draw/rect_paint.dart';
import 'package:window_paint/src/mixins/drag_handle_mixin.dart';
import 'package:window_paint/src/mixins/select_outline_mixin.dart';

class DrawText extends DrawObject with SelectOutlineMixin, DragHandleMixin {
  DrawText({
    required this.adapter,
    required this.id,
    required this.color,
    required this.anchor,
    this.text = '',
    this.fontSize = 16,
  });

  @override
  final DrawObjectAdapter<DrawText> adapter;

  @override
  final String id;

  Color color;
  DrawPoint anchor;
  String text;
  double fontSize;

  Color? _paintedColor;
  DrawPoint? _paintedAnchor;
  String? _paintedText;
  Size? _paintedNormalizedSize;

  Rect get rect => Rect.fromLTWH(
        anchor.offset.dx,
        anchor.offset.dy,
        _paintedNormalizedSize?.width ?? 0.0,
        _paintedNormalizedSize?.height ?? 0.0,
      );

  Iterable<Rect> getHitboxes(Size size) sync* {
    if (_paintedNormalizedSize != null) {
      yield rect.inflate(5.0 / anchor.scale / size.shortestSide);
    }
  }

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
  RectPaint getSelectOutline(Size size) => RectPaint(
        rect: rect.inflate(5.0 / anchor.scale / size.shortestSide),
        paint: Paint()
          ..color = Color(0x8A000000)
          ..strokeWidth = 1.0 / anchor.scale
          ..style = PaintingStyle.stroke,
      );

  @override
  void paint(Canvas canvas, Size size, Denormalize denormalize) {
    final dnAnchorOffset = denormalize(anchor.offset);
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    )..layout(
        maxWidth: size.width - dnAnchorOffset.dx,
      );
    prePaintDragHandle(canvas, size, denormalize);
    textPainter.paint(canvas, dnAnchorOffset);
    paintSelectOutline(canvas, size, denormalize);
    postPaintDragHandle(canvas, size);
    _paintedColor = color;
    _paintedAnchor = anchor;
    _paintedText = text;
    _paintedNormalizedSize = textPainter.size / size.shortestSide;
  }

  @override
  bool shouldRepaint() =>
      shouldRepaintSelectOutline() ||
      shouldRepaintDragHandle() ||
      color != _paintedColor ||
      anchor != _paintedAnchor ||
      text != _paintedText;

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
      id: encoded['id'] as String,
      color: Color(encoded['color'] as int),
      anchor: DrawPoint.fromJSON(encoded['anchor'] as Map),
      text: encoded['text'] as String,
      fontSize: encoded['fontSize'] as double,
    );
  }

  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'id': id,
      'color': color.value,
      'anchor': anchor.toJSON(),
      'text': text,
      'fontSize': fontSize,
    };
  }

  @override
  DrawText clone() {
    return DrawText(
      adapter: adapter,
      id: id,
      color: Color(color.value),
      anchor: anchor.clone(),
    );
  }
}
