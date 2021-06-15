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
    DrawObjectAdapter<DrawRectangle> adapter,
    Map encoded, {
    Size? denormalizeFromSize,
  }) {
    final nx = denormalizeFromSize?.width ?? 1.0;
    final ny = denormalizeFromSize?.height ?? 1.0;
    return DrawRectangle(
      adapter: adapter,
      id: encoded['id'] as String,
      color: Color(encoded['color'] as int),
      strokeWidth: encoded['strokeWidth'] as double,
      anchor: DrawPoint.fromJSON(encoded['anchor'] as Map).scaleOffset(nx, ny),
      hitboxExtent: encoded['hitboxExtent'] as double,
      debugHitboxes: encoded['debugHitboxes'] as bool,
    )..endpoint = offsetFromJSON(encoded['endpoint']).scale(nx, ny);
  }

  @override
  Map<String, dynamic> toJSON({Size? normalizeToSize}) {
    final nx = 1.0 / (normalizeToSize?.width ?? 1.0);
    final ny = 1.0 / (normalizeToSize?.height ?? 1.0);
    return <String, dynamic>{
      'id': id,
      'color': color.value,
      'strokeWidth': strokeWidth,
      'anchor': anchor.scaleOffset(nx, ny).toJSON(),
      'endpoint': (effectiveEndpoint.scale(nx, ny)).toJSON(),
      'hitboxExtent': hitboxExtent,
      'debugHitboxes': debugHitboxes,
    };
  }
}
