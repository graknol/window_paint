import 'package:flutter/widgets.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';

abstract class DrawObject {
  const DrawObject();

  void paint(Canvas canvas, Size size);
  bool shouldRepaint();

  DrawObjectAdapter get adapter;

  String get id;

  /// Used primarily for updating [WindowPaintController.color] when selected.
  Color get primaryColor;

  /// Returns a representation of this object as a JSON object.
  ///
  /// If [normalizeToSize] is not [null], then the coordinates output should be
  /// normalized according to it (usually used to map them to the range [0-1]).
  Map<String, dynamic> toJSON({Size? normalizeToSize});
}
