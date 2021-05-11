import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:window_paint/src/draw/draw_object.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';
import 'package:window_paint/src/draw/draw_point.dart';
import 'package:window_paint/src/draw/rect_paint.dart';
import 'package:window_paint/src/mixins/drag_handle_mixin.dart';
import 'package:window_paint/src/mixins/select_outline_mixin.dart';

class DrawRectangle extends DrawObject
    with SelectOutlineMixin, DragHandleMixin {
  DrawRectangle({
    required this.adapter,
    required this.color,
    required this.anchor,
    required this.strokeWidth,
    this.hitboxExtent = 5.0,
    this.debugHitboxes = false,
  });

  @override
  final DrawObjectAdapter<DrawRectangle> adapter;

  Color color;
  DrawPoint anchor;
  final double strokeWidth;
  final double hitboxExtent;
  final bool debugHitboxes;

  Offset? _endpoint;

  Color? _paintedColor;
  DrawPoint? _paintedAnchor;
  Offset? _paintedEndpoint;

  set endpoint(Offset endpoint) {
    _endpoint = endpoint;
  }

  Offset get effectiveEndpoint => _endpoint ?? anchor.offset;

  Rect get rect => Rect.fromPoints(anchor.offset, effectiveEndpoint);

  Iterable<Rect> get hitboxes sync* {
    final a = anchor.offset;
    final e = effectiveEndpoint;
    // top
    yield Rect.fromPoints(Offset(a.dx, a.dy), Offset(e.dx, a.dy))
        .inflate(hitboxExtent / anchor.scale);
    // right
    yield Rect.fromPoints(Offset(e.dx, a.dy), Offset(e.dx, e.dy))
        .inflate(hitboxExtent / anchor.scale);
    // bottom
    yield Rect.fromPoints(Offset(a.dx, e.dy), Offset(e.dx, e.dy))
        .inflate(hitboxExtent / anchor.scale);
    // left
    yield Rect.fromPoints(Offset(a.dx, a.dy), Offset(a.dx, e.dy))
        .inflate(hitboxExtent / anchor.scale);
  }

  @override
  Color get primaryColor => color;

  @override
  RectPaint get selectOutline => RectPaint(
        rect: rect.inflate(hitboxExtent / anchor.scale),
        paint: Paint()
          ..color = Color(0x8A000000)
          ..strokeWidth = 1.0 / anchor.scale
          ..style = PaintingStyle.stroke,
      );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    prePaintDragHandle(canvas, size);
    canvas.drawRect(rect, paint);
    if (!kReleaseMode && debugHitboxes) {
      paintHitboxes(canvas, size);
    }
    paintSelectOutline(canvas, size);
    postPaintDragHandle(canvas, size);
    _paintedColor = color;
    _paintedAnchor = anchor;
    _paintedEndpoint = _endpoint;
  }

  /// Useful for debugging hitboxes.
  @protected
  void paintHitboxes(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0x8A000000)
      ..strokeWidth = 1.0 / anchor.scale
      ..style = PaintingStyle.stroke;
    for (final hitbox in hitboxes) {
      canvas.drawRect(hitbox, paint);
    }
  }

  @override
  bool shouldRepaint() =>
      shouldRepaintSelectOutline() ||
      shouldRepaintDragHandle() ||
      color != _paintedColor ||
      anchor != _paintedAnchor ||
      _endpoint != _paintedEndpoint;

  @override
  @protected
  void finalizeDragHandlePoints(Offset offset) {
    anchor = anchor.copyWith(
      offset: anchor.offset + offset,
    );
    if (_endpoint != null) {
      _endpoint = _endpoint! + offset;
    }
  }

  factory DrawRectangle.fromJSON(
      DrawObjectAdapter<DrawRectangle> adapter, Map encoded) {
    return DrawRectangle(
      adapter: adapter,
      color: Color(encoded['color'] as int),
      strokeWidth: encoded['strokeWidth'] as double,
      anchor: DrawPoint.fromJSON(encoded['anchor'] as Map),
      hitboxExtent: encoded['hitboxExtent'] as double,
      debugHitboxes: encoded['debugHitboxes'] as bool,
    )..endpoint = Offset(
        encoded['endpointX'] as double,
        encoded['endpointY'] as double,
      );
  }

  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'color': color.value,
      'strokeWidth': strokeWidth,
      'anchor': anchor.toJSON(),
      'endpointX': effectiveEndpoint.dx,
      'endpointY': effectiveEndpoint.dy,
      'hitboxExtent': hitboxExtent,
      'debugHitboxes': debugHitboxes,
    };
  }
}
