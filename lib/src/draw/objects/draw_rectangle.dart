import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:window_paint/src/draw/draw_object.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';
import 'package:window_paint/src/draw/draw_point.dart';

class DrawRectangle extends DrawObject {
  DrawRectangle({
    required this.adapter,
    required this.anchor,
    this.debugHitboxes = false,
  });

  @override
  final DrawObjectAdapter<DrawRectangle> adapter;

  final DrawPoint anchor;
  final bool debugHitboxes;

  bool selected = false;

  Offset? _endpoint;

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
    yield Rect.fromLTRB(a.dx, a.dy, e.dx, a.dy).inflate(5.0 / anchor.scale);
    // right
    yield Rect.fromLTRB(e.dx, a.dy, e.dx, e.dy).inflate(5.0 / anchor.scale);
    // bottom
    yield Rect.fromLTRB(a.dx, e.dy, e.dx, e.dy).inflate(5.0 / anchor.scale);
    // left
    yield Rect.fromLTRB(a.dx, a.dy, a.dx, e.dy).inflate(5.0 / anchor.scale);
  }

  Rect get outline => rect.inflate(5.0 / anchor.scale);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(rect, anchor.paint);
    if (selected) {
      _paintOutline(canvas, size);
    }
    if (!kReleaseMode && debugHitboxes) {
      paintHitboxes(canvas, size);
    }
    _paintedEndpoint = _endpoint;
    _paintedSelected = selected;
  }

  void _paintOutline(Canvas canvas, Sizesize) {
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
      _endpoint != _paintedEndpoint || selected != _paintedSelected;

  @override
  void finalize() {}

  @override
  Color get primaryColor => anchor.paint.color;
}
