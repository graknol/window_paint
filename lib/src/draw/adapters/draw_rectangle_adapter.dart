import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';
import 'package:window_paint/src/draw/draw_point.dart';
import 'package:window_paint/src/draw/objects/draw_rectangle.dart';

class DrawRectangleAdapter extends DrawObjectAdapter<DrawRectangle> {
  const DrawRectangleAdapter({
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

  /// Used to generate unique IDs for each [DrawRectangle].
  final _uuid = const Uuid();

  @override
  String get typeId => 'rectangle';

  @override
  FutureOr<DrawRectangle?> start(
    BuildContext context,
    Offset focalPoint,
    Color color,
    Matrix4 transform,
    Size size,
  ) {
    final point = _createPoint(focalPoint, color, transform);
    return DrawRectangle(
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
    DrawRectangle object,
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
    DrawRectangle object,
    Color color,
    Size size,
  ) {
    return true;
  }

  @override
  bool querySelect(
    DrawRectangle object,
    Offset focalPoint,
    Matrix4 transform,
    Size size,
  ) {
    return object
        .getHitboxes(size)
        .any((hitbox) => hitbox.contains(focalPoint));
  }

  @override
  void select(DrawRectangle object) {
    object.showSelectOutline();
  }

  @override
  void cancelSelect(DrawRectangle object) {
    object.hideSelectOutline();
  }

  @override
  bool selectedStart(
    DrawRectangle object,
    Offset focalPoint,
    Matrix4 transform,
    Size size,
  ) {
    if (object.getHitboxes(size).any((hitbox) => hitbox.contains(focalPoint))) {
      object.prepareDragHandle(focalPoint);
      return true;
    }
    return false;
  }

  @override
  bool selectedUpdate(
    DrawRectangle object,
    Offset focalPoint,
    Matrix4 transform,
    Size size,
  ) {
    object.updateDragHandle(focalPoint);
    return true;
  }

  @override
  bool selectedEnd(DrawRectangle object) {
    object.finalizeDragHandle();
    return true;
  }

  @override
  void selectUpdateColor(DrawRectangle object, Color color) {
    object.color = color;
  }

  @override
  DrawRectangle fromJSON(Map encoded) => DrawRectangle.fromJSON(this, encoded);

  DrawPoint _createPoint(Offset offset, Color color, Matrix4 transform) {
    return DrawPoint(
      offset: offset,
      scale: transform.getMaxScaleOnAxis(),
    );
  }
}
