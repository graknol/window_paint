import 'dart:ui';

import 'package:window_paint/src/draw/draw_object.dart';
import 'package:flutter/widgets.dart';

class WindowPaintPainter extends CustomPainter {
  final DrawObject object;

  WindowPaintPainter({
    required this.object,
  });

  @override
  void paint(Canvas canvas, Size size) {
    object.paint(
      canvas,
      size,
      (offset) => offset.scale(size.width, size.height),
    );
  }

  @override
  bool shouldRepaint(WindowPaintPainter oldDelegate) => object.shouldRepaint();

  @override
  bool shouldRebuildSemantics(WindowPaintPainter oldDelegate) => false;
}
