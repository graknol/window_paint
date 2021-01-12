import 'dart:ui';

import 'package:window_paint/src/draw/draw_point.dart';
import 'package:window_paint/src/draw/objects/draw_rectangle.dart';

class DrawRectangleCross extends DrawRectangle {
  DrawRectangleCross({
    required DrawPoint anchor,
  }) : super(
          anchor: anchor,
        );

  @override
  void paint(Canvas canvas, Size size) {
    super.paint(canvas, size);
    canvas.drawRect(rect, anchor.paint);
    canvas.drawLine(rect.topLeft, rect.bottomRight, anchor.paint);
    canvas.drawLine(rect.bottomLeft, rect.topRight, anchor.paint);
  }
}
