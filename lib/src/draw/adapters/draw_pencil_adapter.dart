import 'dart:ui';

import 'package:window_paint/src/draw/draw_object_adapter.dart';
import 'package:window_paint/src/draw/draw_point.dart';
import 'package:window_paint/src/draw/objects/draw_pencil.dart';

class DrawPencilAdapter extends DrawObjectAdapter<DrawPencil> {
  const DrawPencilAdapter();

  @override
  DrawPencil start(Offset focalPoint, Color color) {
    final point = _createPoint(focalPoint, color);
    return DrawPencil(
      points: [point],
    );
  }

  @override
  bool update(DrawPencil object, Offset focalPoint, Color color) {
    final point = _createPoint(focalPoint, color);
    object.addPoint(point);
    return true;
  }

  @override
  bool end(DrawPencil object, Color color) {
    object.simplify();
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
