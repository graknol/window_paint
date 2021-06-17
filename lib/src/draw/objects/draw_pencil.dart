import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:window_paint/src/draw/draw_object.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';
import 'package:window_paint/src/draw/draw_point.dart';
import 'package:window_paint/src/draw/rect_paint.dart';
import 'package:window_paint/src/geometry/line.dart';
import 'package:window_paint/src/mixins/drag_handle_mixin.dart';
import 'package:window_paint/src/mixins/select_outline_mixin.dart';
import 'package:window_paint/src/utils/simplify_utils.dart';

class DrawPencil extends DrawObject with SelectOutlineMixin, DragHandleMixin {
  DrawPencil({
    required this.adapter,
    required this.id,
    required this.color,
    required this.strokeWidth,
    List<DrawPoint>? points,
    this.hitboxExtent = 5.0,
    this.debugHitboxes = false,
  }) : points = points ?? [];

  @override
  final DrawObjectAdapter<DrawPencil> adapter;

  @override
  final String id;

  Color color;
  final double strokeWidth;
  final List<DrawPoint> points;
  final double hitboxExtent;
  final bool debugHitboxes;

  var selected = false;

  Color? _paintedColor;
  int? _paintedCount;
  bool? _paintedSelected;

  double get _scale => points.isNotEmpty ? points.first.scale : 1.0;

  Rect get rect {
    var minX = double.infinity;
    var minY = double.infinity;
    var maxX = double.negativeInfinity;
    var maxY = double.negativeInfinity;
    for (final point in points) {
      if (point.offset.dx < minX) {
        minX = point.offset.dx;
      }
      if (point.offset.dy < minY) {
        minY = point.offset.dy;
      }
      if (point.offset.dx > maxX) {
        maxX = point.offset.dx;
      }
      if (point.offset.dy > maxY) {
        maxY = point.offset.dy;
      }
    }
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  Iterable<Line> getHitboxes(Size size) sync* {
    for (var i = 0; i < points.length - 1; i++) {
      final from = points[i];
      final to = points[i + 1];
      final diff = to.offset - from.offset;
      final extent = Vector2(diff.dx, diff.dy)
        ..normalize()
        ..scale(hitboxExtent / _scale / size.shortestSide);
      yield Line(
        start: from.offset.translate(-extent.x, -extent.y),
        end: to.offset.translate(extent.x, extent.y),
        extent: hitboxExtent / _scale / size.shortestSide,
      );
    }
  }

  @override
  Color get primaryColor => color;

  @override
  RectPaint getSelectOutline(Size size) => RectPaint(
        rect: rect.inflate(hitboxExtent / _scale / size.shortestSide),
        paint: Paint()
          ..color = Color(0x8A000000)
          ..strokeWidth = 1.0 / _scale
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
    for (var i = 0; i < points.length - 1; i++) {
      final from = points[i];
      final to = points[i + 1];
      canvas.drawLine(
        denormalize(from.offset),
        denormalize(to.offset),
        paint,
      );
    }
    if (!kReleaseMode && debugHitboxes) {
      _paintHitboxes(canvas, size, denormalize);
    }
    paintSelectOutline(canvas, size, denormalize);
    postPaintDragHandle(canvas, size);
    _paintedColor = color;
    _paintedCount = points.length;
    _paintedSelected = selected;
  }

  /// Useful for debugging hitboxes.
  void _paintHitboxes(Canvas canvas, Size size, Denormalize denormalize) {
    final paint = Paint()
      ..color = Color(0x8A000000)
      ..strokeWidth = 1.0 / _scale
      ..style = PaintingStyle.stroke;
    for (final hitbox in getHitboxes(size)) {
      final a = Offset(hitbox.a.x, hitbox.a.y);
      final b = Offset(hitbox.b.x, hitbox.b.y);
      final c = Offset(hitbox.c.x, hitbox.c.y);
      final d = Offset(hitbox.d.x, hitbox.d.y);
      canvas.drawLine(denormalize(a), denormalize(b), paint);
      canvas.drawLine(denormalize(b), denormalize(c), paint);
      canvas.drawLine(denormalize(c), denormalize(d), paint);
      canvas.drawLine(denormalize(d), denormalize(a), paint);
    }
  }

  @override
  bool shouldRepaint() =>
      shouldRepaintSelectOutline() ||
      shouldRepaintDragHandle() ||
      color != _paintedColor ||
      points.length != _paintedCount ||
      selected != _paintedSelected;

  @override
  @protected
  void finalizeDragHandlePoints(Offset offset) {
    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      points[i] = point.copyWith(
        offset: point.offset + offset,
      );
    }
  }

  void addPoint(DrawPoint point) {
    points.add(point);
  }

  void simplify(Size size) {
    final simplified = simplifyPoints(
      points,
      tolerance: 1.0 / _scale / size.shortestSide,
    );
    points.clear();
    points.addAll(simplified);
  }

  factory DrawPencil.fromJSON(
      DrawObjectAdapter<DrawPencil> adapter, Map encoded) {
    return DrawPencil(
      adapter: adapter,
      id: encoded['id'] as String,
      color: Color(encoded['color'] as int),
      strokeWidth: encoded['strokeWidth'] as double,
      points: (encoded['points'] as List)
          .map((p) => DrawPoint.fromJSON(p as Map))
          .toList(),
      hitboxExtent: encoded['hitboxExtent'] as double,
      debugHitboxes: encoded['debugHitboxes'] as bool,
    );
  }

  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'id': id,
      'color': color.value,
      'strokeWidth': strokeWidth,
      'points': points.map((p) => p.toJSON()).toList(),
      'hitboxExtent': hitboxExtent,
      'debugHitboxes': debugHitboxes,
    };
  }

  @override
  DrawPencil clone() {
    return DrawPencil(
      adapter: adapter,
      id: id,
      color: Color(color.value),
      strokeWidth: strokeWidth,
      points: points.map((p) => p.clone()).toList(),
      hitboxExtent: hitboxExtent,
      debugHitboxes: debugHitboxes,
    );
  }
}
