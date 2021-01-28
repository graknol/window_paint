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
  Color get primaryColor => Color(0xFF000000);

  @override
  void paint(Canvas canvas, Size size) {}

  @override
  bool shouldRepaint() => false;

  @override
  void finalize() {}

  factory DrawNoop.fromJSON(
    DrawObjectAdapter<DrawNoop> adapter,
    Map<String, dynamic> encoded,
  ) {
    return DrawNoop(
      adapter: adapter,
    );
  }

  @override
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{};
  }
}
