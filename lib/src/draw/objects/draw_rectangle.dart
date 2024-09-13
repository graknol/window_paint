import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:window_paint/src/draw/draw_object.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';
import 'package:window_paint/src/draw/draw_point.dart';
import 'package:window_paint/src/draw/rect_paint.dart';
import 'package:window_paint/src/mixins/drag_handle_mixin.dart';
import 'package:window_paint/src/mixins/select_outline_mixin.dart';
import 'package:window_paint/src/extensions/offset_extensions.dart';
import 'package:window_paint/src/utils/draw_object_serialization.dart';

class DrawRectangle extends DrawObject
    with SelectOutlineMixin, DragHandleMixin {
  DrawRectangle({
    required this.adapter,
    required this.id,
    required this.color,
    required this.anchor,
    required this.strokeWidth,
    this.hitboxExtent = 5.0,
    this.debugHitboxes = false,
  });

  @override
  final DrawObjectAdapter<DrawRectangle> adapter;

  @override
  final String id;

  Color color;
  DrawPoint anchor;
  final double strokeWidth;
  final double hitboxExtent;
  final bool debugHitboxes;

  Offset? _endpoint;

  Color? _paintedColor;
  DrawPoint? _paintedAnchor;
  Offset? _paintedEndpoint;

  set endpoint(Offset? endpoint) {
    _endpoint = endpoint;
  }

  Offset get effectiveEndpoint => _endpoint ?? anchor.offset;

  Rect get rect => Rect.fromPoints(anchor.offset, effectiveEndpoint);

  Iterable<Rect> getHitboxes(Size size) sync* {
    final a = anchor.offset;
    final e = effectiveEndpoint;
    // top
    yield Rect.fromPoints(Offset(a.dx, a.dy), Offset(e.dx, a.dy))
        .inflate(hitboxExtent / anchor.scale / size.shortestSide);
    // right
    yield Rect.fromPoints(Offset(e.dx, a.dy), Offset(e.dx, e.dy))
        .inflate(hitboxExtent / anchor.scale / size.shortestSide);
    // bottom
    yield Rect.fromPoints(Offset(a.dx, e.dy), Offset(e.dx, e.dy))
        .inflate(hitboxExtent / anchor.scale / size.shortestSide);
    // left
    yield Rect.fromPoints(Offset(a.dx, a.dy), Offset(a.dx, e.dy))
        .inflate(hitboxExtent / anchor.scale / size.shortestSide);
  }

  @override
  Color get primaryColor => color;

  @override
  RectPaint getSelectOutline(Size size) => RectPaint(
        rect: rect.inflate(hitboxExtent / anchor.scale / size.shortestSide),
        paint: Paint()
          ..color = Color(0x8A000000)
          ..strokeWidth = 1.0 / anchor.scale
          ..style = PaintingStyle.stroke,
      );

  @override
  void paint(Canvas canvas, Size size, Denormalize denormalize) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    prePaintDragHandle(canvas, size, denormalize);
    final dnRect = Rect.fromPoints(
      denormalize(rect.topLeft),
      denormalize(rect.bottomRight),
    );
    canvas.drawRect(dnRect, paint);
    if (!kReleaseMode && debugHitboxes) {
      paintHitboxes(canvas, size, denormalize);
    }
    paintSelectOutline(canvas, size, denormalize);
    postPaintDragHandle(canvas, size);
    _paintedColor = color;
    _paintedAnchor = anchor;
    _paintedEndpoint = _endpoint;
  }

  /// Useful for debugging hitboxes.
  @protected
  void paintHitboxes(Canvas canvas, Size size, Denormalize denormalize) {
    final paint = Paint()
      ..color = Color(0x8A000000)
      ..strokeWidth = 1.0 / anchor.scale
      ..style = PaintingStyle.stroke;
    for (final hitbox in getHitboxes(size)) {
      final rect = Rect.fromPoints(
        denormalize(hitbox.topLeft),
        denormalize(hitbox.bottomRight),
      );
      canvas.drawRect(rect, paint);
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
    DrawObjectAdapter<DrawRectangle> adapter,
    Map encoded,
  ) {
    return DrawRectangle(
      adapter: adapter,
      id: encoded['id'] as String,
      color: Color(encoded['color'] as int),
      strokeWidth: encoded['strokeWidth'] as double,
      anchor: DrawPoint.fromJSON(encoded['anchor'] as Map),
      hitboxExtent: encoded['hitboxExtent'] ?? 5.0,
      debugHitboxes: encoded['debugHitboxes'] ?? false,
    )..endpoint = encoded['endpoint'] != null
        ? offsetFromJSON(encoded['endpoint'])
        : null;
  }

  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'id': id,
      'color': color.value,
      'strokeWidth': strokeWidth,
      'anchor': anchor.toJSON(),
      'endpoint': effectiveEndpoint.toJSON(),
      'hitboxExtent': hitboxExtent,
      'debugHitboxes': debugHitboxes,
    };
  }

  @override
  DrawRectangle clone() {
    return DrawRectangle(
      adapter: adapter,
      id: id,
      color: Color(color.value),
      anchor: anchor.clone(),
      strokeWidth: strokeWidth,
      hitboxExtent: hitboxExtent,
      debugHitboxes: debugHitboxes,
    )..endpoint = Offset(effectiveEndpoint.dx, effectiveEndpoint.dy);
  }
}
