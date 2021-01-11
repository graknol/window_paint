import 'dart:ui';

import 'package:window_paint/draw/draw_object_adapter.dart';
import 'package:window_paint/draw/draw_point.dart';
import 'package:window_paint/draw/objects/draw_rectangle_cross.dart';

class DrawRectangleCrossAdapter extends DrawObjectAdapter<DrawRectangleCross> {
  const DrawRectangleCrossAdapter();

  @override
  DrawRectangleCross start(Offset focalPoint, Color color) {
    final point = _createPoint(focalPoint, color);
    return DrawRectangleCross(
      anchor: point,
    );
  }

  @override
  bool update(DrawRectangleCross object, Offset focalPoint, Color color) {
    object.endpoint = focalPoint;
    return true;
  }

  @override
  bool end(DrawRectangleCross object, Color color) {
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
