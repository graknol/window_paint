import 'dart:ui';

import 'package:window_paint/draw/draw_object.dart';
import 'package:window_paint/draw/draw_point.dart';
import 'package:window_paint/utils/simplify_utils.dart';

class DrawPencil extends DrawObject {
  final List<DrawPoint> points;

  DrawPencil({
    List<DrawPoint> points,
  }) : this.points = points ?? [];

  int _lastPaintedCount;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < points.length - 1; i++) {
      final from = points[i];
      final to = points[i + 1];
      canvas.drawLine(from.offset, to.offset, from.paint);
    }
    _lastPaintedCount = points.length;
  }

  @override
  bool shouldRepaint() => points.length != _lastPaintedCount;

  @override
  void finalize() {
    simplify();
  }

  void addPoint(DrawPoint point) {
    points.add(point);
  }

  void simplify() {
    final simplified = simplifyPoints(points);
    points.clear();
    points.addAll(simplified);
  }
}
