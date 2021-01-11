import 'dart:ui';

import 'package:window_paint/draw/draw_object_adapter.dart';
import 'package:window_paint/draw/draw_point.dart';
import 'package:window_paint/draw/objects/draw_rectangle.dart';

class DrawRectangleAdapter extends DrawObjectAdapter<DrawRectangle> {
  const DrawRectangleAdapter();

  @override
  DrawRectangle start(Offset focalPoint, Color color) {
    final point = _createPoint(focalPoint, color);
    return DrawRectangle(
      anchor: point,
    );
  }

  @override
  bool update(DrawRectangle object, Offset focalPoint, Color color) {
    object.endpoint = focalPoint;
    return true;
  }

  @override
  bool end(DrawRectangle object, Color color) {
    return true;
  }

  DrawPoint _createPoint(Offset offset, Color color) {
    return DrawPoint(
      offset: offset,
      paint: Paint()
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }
}
