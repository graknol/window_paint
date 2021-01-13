import 'dart:ui';

import 'package:window_paint/src/draw/adapters/pan_zoom_adapter.dart';
import 'package:window_paint/src/draw/draw_object.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';

class DrawNoop extends DrawObject {
  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint() => false;

  @override
  void finalize() {}

  @override
  DrawObjectAdapter<DrawObject> get adapter => const PanZoomAdapter();

  @override
  Color get primaryColor => Color(0xFF000000);
}
