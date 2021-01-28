import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:window_paint/src/draw/draw_object.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';
import 'package:window_paint/src/draw/draw_point.dart';

class DrawRectangle extends DrawObject {
  DrawRectangle({
    required this.adapter,
    required this.color,
    required this.strokeWidth,
    required this.anchor,
    this.hitboxExtent = 5.0,
    this.debugHitboxes = false,
  });

  @override
  final DrawObjectAdapter<DrawRectangle> adapter;

  Color color;
  final double strokeWidth;
  final DrawPoint anchor;
  final double hitboxExtent;
  final bool debugHitboxes;

  bool selected = false;

  Offset? _endpoint;

  Color? _paintedColor;
  Offset? _paintedEndpoint;
  bool _paintedSelected = false;

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
    canvas.drawRect(rect, paint);
    if (selected) {
      _paintOutline(canvas, size);
    }
    if (!kReleaseMode && debugHitboxes) {
      paintHitboxes(canvas, size);
    }
    _paintedColor = color;
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
      color != _paintedColor ||
      _endpoint != _paintedEndpoint ||
      selected != _paintedSelected;

  @override
  void finalize() {}

  factory DrawRectangle.fromJSON(
    DrawObjectAdapter<DrawRectangle> adapter,
    Map<String, dynamic> encoded,
  ) {
    return DrawRectangle(
      adapter: adapter,
      color: Color(encoded['color'] as int),
      strokeWidth: encoded['strokeWidth'] as double,
      anchor: DrawPoint.fromJSON(encoded['anchor']),
      hitboxExtent: encoded['hitboxExtent'] as double,
      debugHitboxes: encoded['debugHitboxes'] as bool,
    );
  }

  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'color': color.value,
      'strokeWidth': strokeWidth,
      'anchor': anchor.toJSON(),
      'hitboxExtent': hitboxExtent,
      'debugHitboxes': debugHitboxes,
    };
  }
}
