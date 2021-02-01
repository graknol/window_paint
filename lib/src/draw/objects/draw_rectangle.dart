import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:window_paint/src/draw/draw_object.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';
import 'package:window_paint/src/draw/draw_point.dart';
import 'package:window_paint/src/mixins/drag_handle_mixin.dart';

class DrawRectangle extends DrawObject with DragHandleMixin {
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

  var selected = false;

  Offset? _endpoint;

  Color? _paintedColor;
  DrawPoint? _paintedAnchor;
  Offset? _paintedEndpoint;
  bool? _paintedSelected;

  set endpoint(Offset endpoint) {
    _endpoint = endpoint;
  }

  Offset get effectiveEndpoint => _endpoint ?? anchor.offset;

  Rect get rect => Rect.fromPoints(anchor.offset, effectiveEndpoint);

  Iterable<Rect> get hitboxes sync* {
    final a = anchor.offset;
    final e = effectiveEndpoint;
    // top
    yield Rect.fromLTRB(a.dx, a.dy, e.dx, a.dy)
        .inflate(hitboxExtent / anchor.scale);
    // right
    yield Rect.fromLTRB(e.dx, a.dy, e.dx, e.dy)
        .inflate(hitboxExtent / anchor.scale);
    // bottom
    yield Rect.fromLTRB(a.dx, e.dy, e.dx, e.dy)
        .inflate(hitboxExtent / anchor.scale);
    // left
    yield Rect.fromLTRB(a.dx, a.dy, a.dx, e.dy)
        .inflate(hitboxExtent / anchor.scale);
  }

  Rect get outline => rect.inflate(hitboxExtent / anchor.scale);

  @override
  Color get primaryColor => color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    prePaintDragHandle(canvas);
    canvas.drawRect(rect, paint);
    if (selected) {
      _paintOutline(canvas, size);
    }
    if (!kReleaseMode && debugHitboxes) {
      paintHitboxes(canvas, size);
    }
    postPaintDragHandle(canvas);
    _paintedColor = color;
    _paintedAnchor = anchor;
    _paintedEndpoint = _endpoint;
    _paintedSelected = selected;
  }

  void _paintOutline(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0x8A000000)
      ..strokeWidth = 1.0 / anchor.scale
      ..style = PaintingStyle.stroke;
    canvas.drawRect(outline, paint);
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
      super.shouldRepaint() ||
      color != _paintedColor ||
      anchor != _paintedAnchor ||
      _endpoint != _paintedEndpoint ||
      selected != _paintedSelected;

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
