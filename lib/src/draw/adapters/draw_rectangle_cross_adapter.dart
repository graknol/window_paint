import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';
import 'package:window_paint/src/draw/draw_point.dart';
import 'package:window_paint/src/draw/objects/draw_rectangle_cross.dart';

class DrawRectangleCrossAdapter extends DrawObjectAdapter<DrawRectangleCross> {
  const DrawRectangleCrossAdapter({
    this.width = 1.0,
    this.hitboxExtent = 5.0,
    this.debugHitboxes = false,
  });

  /// The width of each line.
  final double width;

  /// Half the width of the hitboxes.
  ///
  /// The hitboxes are laid out along the lines of the rectangle.
  /// Their width is equal to `2 * hitboxExtent` and length equal
  /// to `length + (2 * hitboxExtent)`.
  final double hitboxExtent;

  /// Render the areas that would cause that object to be selected.
  final bool debugHitboxes;

  /// Used to generate unique IDs for each [DrawRectangleCross].
  final _uuid = const Uuid();

  @override
  String get typeId => 'rectangle_cross';

  @override
  FutureOr<DrawRectangleCross?> start(
    BuildContext context,
    Offset focalPoint,
    Color color,
    Matrix4 transform,
    Size size,
  ) {
    final point = _createPoint(focalPoint, color, transform);
    return DrawRectangleCross(
      adapter: this,
      id: _uuid.v4(),
      color: color,
      strokeWidth: width / transform.getMaxScaleOnAxis(),
      anchor: point,
      hitboxExtent: hitboxExtent,
      debugHitboxes: debugHitboxes,
    );
  }

  @override
  bool update(
    DrawRectangleCross object,
    Offset focalPoint,
    Color color,
    Matrix4 transform,
    Size size,
  ) {
    object.endpoint = focalPoint;
    return true;
  }

  @override
  bool end(
    DrawRectangleCross object,
    Color color,
    Size size,
  ) {
    return true;
  }

  @override
  bool querySelect(
    DrawRectangleCross object,
    Offset focalPoint,
    Matrix4 transform,
    Size size,
  ) {
    return object
            .getHitboxes(size)
            .any((hitbox) => hitbox.contains(focalPoint)) ||
        object
            .getInnerHitboxes(size)
            .any((hitbox) => hitbox.contains(focalPoint));
  }

  @override
  void select(DrawRectangleCross object) {
    object.showSelectOutline();
  }

  @override
  void cancelSelect(DrawRectangleCross object) {
    object.hideSelectOutline();
  }

  @override
  bool selectedStart(
    DrawRectangleCross object,
    Offset focalPoint,
    Matrix4 transform,
    Size size,
  ) {
    if (object.getHitboxes(size).any((hitbox) => hitbox.contains(focalPoint)) ||
        object
            .getInnerHitboxes(size)
            .any((hitbox) => hitbox.contains(focalPoint))) {
      object.prepareDragHandle(focalPoint);
      return true;
    }
    return false;
  }

  @override
  bool selectedUpdate(
    DrawRectangleCross object,
    Offset focalPoint,
    Matrix4 transform,
    Size size,
  ) {
    object.updateDragHandle(focalPoint);
    return true;
  }

  @override
  bool selectedEnd(DrawRectangleCross object) {
    object.finalizeDragHandle();
    return true;
  }

  @override
  void selectUpdateColor(DrawRectangleCross object, Color color) {
    object.color = color;
  }

  @override
  DrawRectangleCross fromJSON(Map encoded) =>
      DrawRectangleCross.fromJSON(this, encoded);

  DrawPoint _createPoint(Offset offset, Color color, Matrix4 transform) {
    final scale = transform.getMaxScaleOnAxis();
    return DrawPoint(
      offset: offset,
      scale: scale,
    );
  }
}
