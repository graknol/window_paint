import 'dart:ui';

import 'package:window_paint/src/draw/draw_object.dart';

class DrawNoop extends DrawObject {
  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint() => false;

  @override
  void finalize() {}
}
