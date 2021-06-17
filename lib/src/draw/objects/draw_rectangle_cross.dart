import 'dart:ui';

import 'package:window_paint/src/draw/draw_object.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';
import 'package:window_paint/src/draw/draw_point.dart';
import 'package:window_paint/src/draw/objects/draw_rectangle.dart';
import 'package:window_paint/src/geometry/line.dart';
import 'package:window_paint/src/utils/draw_object_serialization.dart';

class DrawRectangleCross extends DrawRectangle {
  DrawRectangleCross({
    required DrawObjectAdapter<DrawRectangleCross> adapter,
    required String id,
    required Color color,
    required double strokeWidth,
    required DrawPoint anchor,
    double hitboxExtent = 5.0,
    bool debugHitboxes = false,
  }) : super(
          adapter: adapter,
          id: id,
          color: color,
          strokeWidth: strokeWidth,
          anchor: anchor,
          hitboxExtent: hitboxExtent,
          debugHitboxes: debugHitboxes,
        );

  @override
  DrawObjectAdapter<DrawRectangleCross> get adapter =>
      super.adapter as DrawObjectAdapter<DrawRectangleCross>;

  Iterable<Line> getInnerHitboxes(Size size) sync* {
    final a = anchor.offset;
    final e = effectiveEndpoint;
    // top-left -> bottom-right
    yield Line(
      start: a,
      end: e,
      extent: hitboxExtent / anchor.scale / size.shortestSide,
    );
    // bottom-left -> top-right
    yield Line(
      start: Offset(a.dx, e.dy),
      end: Offset(e.dx, a.dy),
      extent: hitboxExtent / anchor.scale / size.shortestSide,
    );
  }

  @override
  void paint(Canvas canvas, Size size, Denormalize denormalize) {
    super.paint(canvas, size, denormalize);
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final dnRect = Rect.fromPoints(
      denormalize(rect.topLeft),
      denormalize(rect.bottomRight),
    );
    prePaintDragHandle(canvas, size, denormalize);
    canvas.drawRect(dnRect, paint);
    canvas.drawLine(dnRect.topLeft, dnRect.bottomRight, paint);
    canvas.drawLine(dnRect.bottomLeft, dnRect.topRight, paint);
    postPaintDragHandle(canvas, size);
  }

  @override
  void paintHitboxes(Canvas canvas, Size size, Denormalize denormalize) {
    super.paintHitboxes(canvas, size, denormalize);
    final paint = Paint()
      ..color = Color(0x8A000000)
      ..strokeWidth = 1.0 / anchor.scale
      ..style = PaintingStyle.stroke;
    for (final hitbox in getInnerHitboxes(size)) {
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

  factory DrawRectangleCross.fromJSON(
    DrawObjectAdapter<DrawRectangleCross> adapter,
    Map encoded,
  ) {
    return DrawRectangleCross(
      adapter: adapter,
      id: encoded['id'] as String,
      color: Color(encoded['color'] as int),
      strokeWidth: encoded['strokeWidth'] as double,
      anchor: DrawPoint.fromJSON(encoded['anchor'] as Map),
      hitboxExtent: encoded['hitboxExtent'] as double,
      debugHitboxes: encoded['debugHitboxes'] as bool,
    )..endpoint = offsetFromJSON(encoded['endpoint']);
  }

  @override
  DrawRectangleCross clone() {
    return DrawRectangleCross(
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
