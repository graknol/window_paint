import 'dart:ui';

import 'package:window_paint/src/draw/draw_object.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';

class DrawNoop extends DrawObject {
  const DrawNoop({
    required this.adapter,
    required this.id,
  });

  @override
  final DrawObjectAdapter<DrawObject> adapter;

  @override
  final String id;

  @override
  Color get primaryColor => Color(0xFF000000);

  @override
  void paint(Canvas canvas, Size size, Denormalize denormalize) {}

  @override
  bool shouldRepaint() => false;

  factory DrawNoop.fromJSON(
    DrawObjectAdapter<DrawNoop> adapter,
    Map encoded, {
    Size? denormalizeFromSize,
  }) {
    return DrawNoop(
      adapter: adapter,
      id: encoded['id'] as String,
    );
  }

  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'id': id,
    };
  }

  @override
  DrawNoop clone() {
    return DrawNoop(
      adapter: adapter,
      id: id,
    );
  }
}
