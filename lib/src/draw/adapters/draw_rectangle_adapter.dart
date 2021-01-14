import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';
import 'package:window_paint/src/draw/draw_point.dart';
import 'package:window_paint/src/draw/objects/draw_rectangle.dart';

class DrawRectangleAdapter extends DrawObjectAdapter<DrawRectangle> {
  const DrawRectangleAdapter({
    this.width = 1.0,
    this.debugHitboxes = false,
  });

  /// The width of each line.
  final double width;

  /// Render the areas that would cause that object to be selected.
  final bool debugHitboxes;

  @override
  FutureOr<DrawRectangle?> start(
      BuildContext context, Offset focalPoint, Color color, Matrix4 transform) {
    final point = _createPoint(focalPoint, color, transform);
    return DrawRectangle(
      adapter: this,
      anchor: point,
      debugHitboxes: debugHitboxes,
    );
  }

  @override
  bool update(
      DrawRectangle object, Offset focalPoint, Color color, Matrix4 transform) {
    object.endpoint = focalPoint;
    return true;
  }

  @override
  bool end(DrawRectangle object, Color color) {
    return true;
  }

  @override
  bool querySelect(DrawRectangle object, Offset focalPoint, Matrix4 transform) {
    return object.hitboxes.any((hitbox) => hitbox.contains(focalPoint));
  }

  @override
  void select(DrawRectangle object) {
    object.selected = true;
  }

  @override
  void cancelSelect(DrawRectangle object) {
    object.selected = false;
  }

  @override
  bool selectedStart(
      DrawRectangle object, Offset focalPoint, Matrix4 transform) {
    return object.hitboxes.any((hitbox) => hitbox.contains(focalPoint));
  }

  @override
  bool selectedUpdate(
      DrawRectangle object, Offset focalPoint, Matrix4 transform) {
    return false;
  }

  @override
  bool selectedEnd(DrawRectangle object) {
    return true;
  }

  @override
  void selectUpdateColor(DrawRectangle object, Color color) {
    object.anchor.paint.color = color;
  }

  DrawPoint _createPoint(Offset offset, Color color, Matrix4 transform) {
    final scale = transform.getMaxScaleOnAxis();
    return DrawPoint(
      offset: offset,
      paint: Paint()
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width / scale,
      scale: scale,
    );
  }
}
