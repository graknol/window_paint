import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';
import 'package:window_paint/src/draw/draw_point.dart';
import 'package:window_paint/src/draw/objects/draw_pencil.dart';

class DrawPencilAdapter extends DrawObjectAdapter<DrawPencil> {
  const DrawPencilAdapter({
    this.width = 1.0,
    this.hitboxExtent = 5.0,
    this.debugHitboxes = false,
  });

  /// The width of a pencil-stroke.
  final double width;

  /// Half the width of the hitboxes.
  ///
  /// The hitboxes are laid out along the lines of the pencil-stroke.
  /// Their width is equal to `2 * hitboxExtent` and length equal
  /// to `length + (2 * hitboxExtent)`.
  final double hitboxExtent;

  /// Render the areas that would cause that object to be selected.
  final bool debugHitboxes;

  @override
  FutureOr<DrawPencil?> start(
      BuildContext context, Offset focalPoint, Color color, Matrix4 transform) {
    final point = _createPoint(focalPoint, color, transform);
    return DrawPencil(
      adapter: this,
      points: [point],
      hitboxExtent: hitboxExtent,
      debugHitboxes: debugHitboxes,
    );
  }

  @override
  bool update(
      DrawPencil object, Offset focalPoint, Color color, Matrix4 transform) {
    final point = _createPoint(focalPoint, color, transform);
    object.addPoint(point);
    return true;
  }

  @override
  bool end(DrawPencil object, Color color) {
    object.simplify();
    return true;
  }

  @override
  bool querySelect(DrawPencil object, Offset focalPoint, Matrix4 transform) {
    return object.hitboxes.any((hitbox) => hitbox.contains(focalPoint));
  }

  @override
  void select(DrawPencil object) {
    object.selected = true;
  }

  @override
  void cancelSelect(DrawPencil object) {
    object.selected = false;
  }

  @override
  bool selectedStart(DrawPencil object, Offset focalPoint, Matrix4 transform) {
    return object.hitboxes.any((hitbox) => hitbox.contains(focalPoint));
  }

  @override
  bool selectedUpdate(DrawPencil object, Offset focalPoint, Matrix4 transform) {
    return false;
  }

  @override
  bool selectedEnd(DrawPencil object) {
    return true;
  }

  @override
  void selectUpdateColor(DrawPencil object, Color color) {
    for (final point in object.points) {
      point.paint.color = color;
    }
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
