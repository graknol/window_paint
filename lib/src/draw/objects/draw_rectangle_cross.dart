import 'dart:ui';

import 'package:window_paint/src/draw/adapters/draw_rectangle_cross_adapter.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';
import 'package:window_paint/src/draw/draw_point.dart';
import 'package:window_paint/src/draw/objects/draw_rectangle.dart';
import 'package:window_paint/src/geometry/line.dart';

class DrawRectangleCross extends DrawRectangle {
  DrawRectangleCross({
    required DrawPoint anchor,
    bool debugHitboxes = false,
  }) : super(
          anchor: anchor,
          debugHitboxes: debugHitboxes,
        );

  Iterable<Line> get innerHitboxes sync* {
    final a = anchor.offset;
    final e = effectiveEndpoint;
    // top-left -> bottom-right
    yield Line(
      start: a,
      end: e,
      width: 5.0,
    );
    // bottom-left -> top-right
    yield Line(
      start: Offset(a.dx, e.dy),
      end: Offset(e.dx, a.dy),
      width: 5.0,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);
    canvas.drawRect(rect, anchor.paint);
    canvas.drawLine(rect.topLeft, rect.bottomRight, anchor.paint);
    canvas.drawLine(rect.bottomLeft, rect.topRight, anchor.paint);
  }

  @override
  void paintHitboxes(Canvas canvas, Size size) {
    super.paintHitboxes(canvas, size);
    final paint = Paint()
      ..color = Color(0x8A000000)
      ..strokeWidth = 1
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

  @override
  DrawObjectAdapter<DrawRectangleCross> get adapter =>
      const DrawRectangleCrossAdapter();
}
