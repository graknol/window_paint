import 'dart:ui';

import 'package:example/draw_point.dart';
import 'package:flutter/widgets.dart';

class WindowPaintPainter extends CustomPainter {
  final List<DrawPoint> points;
  final int _pointCount;

  WindowPaintPainter({
    this.points,
  })  : assert(points != null),
        _pointCount = points.length;

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < points.length - 1; i++) {
      final from = points[i];
      final to = points[i + 1];
      if (from != null && to != null) {
        canvas.drawLine(from.offset, to.offset, from.paint);
      } else if (from != null && to == null) {
        canvas.drawPoints(PointMode.points, [from.offset], from.paint);
      }
    }
  }

  @override
  bool shouldRepaint(WindowPaintPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate._pointCount != _pointCount;

  @override
  bool shouldRebuildSemantics(WindowPaintPainter oldDelegate) => false;
}
