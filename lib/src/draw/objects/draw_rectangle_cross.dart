import 'dart:ui';

import 'package:window_paint/src/draw/draw_object_adapter.dart';
import 'package:window_paint/src/draw/draw_point.dart';
import 'package:window_paint/src/draw/objects/draw_rectangle.dart';
import 'package:window_paint/src/geometry/line.dart';

class DrawRectangleCross extends DrawRectangle {
  DrawRectangleCross({
    required DrawObjectAdapter<DrawRectangleCross> adapter,
    required Color color,
    required double strokeWidth,
    required DrawPoint anchor,
    double hitboxExtent = 5.0,
    bool debugHitboxes = false,
  }) : super(
          adapter: adapter,
          color: color,
          strokeWidth: strokeWidth,
          anchor: anchor,
          hitboxExtent: hitboxExtent,
          debugHitboxes: debugHitboxes,
        );

  @override
  DrawObjectAdapter<DrawRectangleCross> get adapter =>
      super.adapter as DrawObjectAdapter<DrawRectangleCross>;

  Iterable<Line> get innerHitboxes sync* {
    final a = anchor.offset;
    final e = effectiveEndpoint;
    // top-left -> bottom-right
    yield Line(
      start: a,
      end: e,
      extent: hitboxExtent / anchor.scale,
    );
    // bottom-left -> top-right
    yield Line(
      start: Offset(a.dx, e.dy),
      end: Offset(e.dx, a.dy),
      extent: hitboxExtent / anchor.scale,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawRect(rect, paint);
    canvas.drawLine(rect.topLeft, rect.bottomRight, paint);
    canvas.drawLine(rect.bottomLeft, rect.topRight, paint);
  }

  @override
  void paintHitboxes(Canvas canvas, Size size) {
    super.paintHitboxes(canvas, size);
    final paint = Paint()
      ..color = Color(0x8A000000)
      ..strokeWidth = 1.0 / anchor.scale
      ..style = PaintingStyle.stroke;
    for (final hitbox in innerHitboxes) {
      final a = Offset(hitbox.a.x, hitbox.a.y);
      final b = Offset(hitbox.b.x, hitbox.b.y);
      final c = Offset(hitbox.c.x, hitbox.c.y);
      final d = Offset(hitbox.d.x, hitbox.d.y);
      canvas.drawLine(a, b, paint);
      canvas.drawLine(b, c, paint);
      canvas.drawLine(c, d, paint);
      canvas.drawLine(d, a, paint);
    }
  }

  factory DrawRectangleCross.fromJSON(
    DrawObjectAdapter<DrawRectangleCross> adapter,
    Map<String, dynamic> encoded,
  ) {
    return DrawRectangleCross(
      adapter: adapter,
      color: Color(encoded['color'] as int),
      strokeWidth: encoded['strokeWidth'] as double,
      anchor: DrawPoint.fromJSON(encoded['anchor']),
      hitboxExtent: encoded['hitboxExtent'] as double,
      debugHitboxes: encoded['debugHitboxes'] as bool,
    );
  }
}
