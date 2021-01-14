import 'package:flutter/widgets.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';

abstract class DrawObject {
  const DrawObject();

  void paint(Canvas canvas, Size size);
  bool shouldRepaint();
  void finalize();

  DrawObjectAdapter get adapter;

  /// Used primarily for updating [WindowPaintController.color] when selected.
  Color get primaryColor;
}
