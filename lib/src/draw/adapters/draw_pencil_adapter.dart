import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';
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

  /// Used to generate unique IDs for each [DrawPencil].
  final _uuid = const Uuid();

  @override
  String get typeId => 'pencil';

  @override
  FutureOr<DrawPencil?> start(
    BuildContext context,
    Offset focalPoint,
    Color color,
    Matrix4 transform,
    Size size,
  ) {
    final point = _createPoint(focalPoint, color, transform);
    return DrawPencil(
      adapter: this,
      id: _uuid.v4(),
      color: color,
      strokeWidth: width / transform.getMaxScaleOnAxis(),
      points: [point],
      hitboxExtent: hitboxExtent,
      debugHitboxes: debugHitboxes,
    );
  }

  @override
  bool update(
    DrawPencil object,
    Offset focalPoint,
    Color color,
    Matrix4 transform,
    Size size,
  ) {
    final point = _createPoint(focalPoint, color, transform);
    object.addPoint(point);
    return true;
  }

  @override
  bool end(
    DrawPencil object,
    Color color,
    Size size,
  ) {
    object.simplify(size);
    return true;
  }

  @override
  bool querySelect(
    DrawPencil object,
    Offset focalPoint,
    Matrix4 transform,
    Size size,
  ) {
    return object
        .getHitboxes(size)
        .any((hitbox) => hitbox.contains(focalPoint));
  }

  @override
  void select(DrawPencil object) {
    object.showSelectOutline();
  }

  @override
  void cancelSelect(DrawPencil object) {
    object.hideSelectOutline();
  }

  @override
  bool selectedStart(
    DrawPencil object,
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
    DrawPencil object,
    Offset focalPoint,
    Matrix4 transform,
    Size size,
  ) {
    object.updateDragHandle(focalPoint);
    return true;
  }

  @override
  bool selectedEnd(DrawPencil object) {
    object.finalizeDragHandle();
    return true;
  }

  @override
  void selectUpdateColor(DrawPencil object, Color color) {
    object.color = color;
  }

  @override
  DrawPencil fromJSON(Map encoded) => DrawPencil.fromJSON(this, encoded);

  DrawPoint _createPoint(Offset offset, Color color, Matrix4 transform) {
    return DrawPoint(
      offset: offset,
      scale: transform.getMaxScaleOnAxis(),
    );
  }
}
