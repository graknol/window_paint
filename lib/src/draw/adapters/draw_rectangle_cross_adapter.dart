import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';
import 'package:window_paint/src/draw/draw_point.dart';
import 'package:window_paint/src/draw/objects/draw_rectangle_cross.dart';

class DrawRectangleCrossAdapter extends DrawObjectAdapter<DrawRectangleCross> {
  const DrawRectangleCrossAdapter({
    this.debugHitboxes = false,
  });

  final bool debugHitboxes;

  @override
  FutureOr<DrawRectangleCross?> start(
      BuildContext context, Offset focalPoint, Color color, Matrix4 transform) {
    final point = _createPoint(focalPoint, color);
    return DrawRectangleCross(
      anchor: point,
      debugHitboxes: debugHitboxes,
    );
  }

  @override
  bool update(DrawRectangleCross object, Offset focalPoint, Color color,
      Matrix4 transform) {
    object.endpoint = focalPoint;
    return true;
  }

  @override
  bool end(DrawRectangleCross object, Color color) {
    return true;
  }

  @override
  bool querySelect(
      DrawRectangleCross object, Offset focalPoint, Matrix4 transform) {
    return object.hitboxes.any((hitbox) => hitbox.contains(focalPoint)) ||
        object.innerHitboxes.any((hitbox) => hitbox.contains(focalPoint));
  }

  @override
  void select(DrawRectangleCross object) {
    object.selected = true;
  }

  @override
  void cancelSelect(DrawRectangleCross object) {
    object.selected = false;
  }

  @override
  bool selectedStart(
      DrawRectangleCross object, Offset focalPoint, Matrix4 transform) {
    return object.hitboxes.any((hitbox) => hitbox.contains(focalPoint));
  }

  @override
  bool selectedUpdate(
      DrawRectangleCross object, Offset focalPoint, Matrix4 transform) {
    // TODO: implement selectedUpdate
    return true;
  }

  @override
  bool selectedEnd(DrawRectangleCross object) {
    // TODO: implement selectedEnd
    return true;
  }

  @override
  void selectUpdateColor(DrawRectangleCross object, Color color) {
    object.anchor.paint.color = color;
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
