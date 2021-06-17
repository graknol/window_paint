import 'package:flutter/widgets.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';

typedef Denormalize = Offset Function(Offset normalized);

abstract class DrawObject {
  const DrawObject();

  void paint(Canvas canvas, Size size, Denormalize denormalize);
  bool shouldRepaint();

  DrawObjectAdapter get adapter;

  String get id;

  /// Used primarily for updating [WindowPaintController.color] when selected.
  Color get primaryColor;

  /// Returns a representation of this object as a JSON object.
  Map<String, dynamic> toJSON();

  /// Returns a deep clone of this object.
  DrawObject clone();
}
