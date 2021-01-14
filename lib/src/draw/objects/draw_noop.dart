import 'dart:ui';

import 'package:window_paint/src/draw/draw_object.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';

class DrawNoop extends DrawObject {
  const DrawNoop({
    required this.adapter,
  });

  @override
  final DrawObjectAdapter<DrawObject> adapter;

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint() => false;

  @override
  void finalize() {}

  @override
  Color get primaryColor => Color(0xFF000000);
}
