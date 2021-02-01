import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:window_paint/src/draw/draw_object.dart';

mixin DragHandleMixin on DrawObject {
  var _dragHandleOffset = Offset.zero;
  Offset? _dragHandleFocalPoint;

  Offset? _paintedDragHandleOffset;
  Offset? _paintedDragHandleFocalPoint;

  /// Must be called in [shouldRepaint()].
  @protected
  bool shouldRepaintDragHandle() =>
      _dragHandleFocalPoint != _paintedDragHandleFocalPoint ||
      _dragHandleOffset != _paintedDragHandleOffset;

  /// Prepares the canvas with the current drag handle offset.
  ///
  /// Must be called at the start of [paint()].
  @protected
  @mustCallSuper
  void prePaintDragHandle(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(_dragHandleOffset.dx, _dragHandleOffset.dy);
  }

  /// Restores the canvas and saves the [shouldRepaint()] variables.
  ///
  /// Must be called at the end of [paint()].
  @protected
  @mustCallSuper
  void postPaintDragHandle(Canvas canvas, Size size) {
    canvas.restore();
    _paintedDragHandleFocalPoint = _dragHandleFocalPoint;
    _paintedDragHandleOffset = _dragHandleOffset;
  }

  /// Sets the drag handle focal point needed for subsequent calculations with
  /// the drag handle offset.
  ///
  /// Should not be called again before [finalizeDragHandle()] has been called.
  void prepareDragHandle(Offset focalPoint) {
    _dragHandleFocalPoint = focalPoint;
  }

  /// Updates the drag handle offset.
  ///
  /// Must call [prepareDragHandle()] first.
  ///
  /// Cannot be called after [finalizeDragHandle()] has been called.
  void updateDragHandle(Offset focalPoint) {
    _dragHandleOffset = focalPoint - _dragHandleFocalPoint!;
  }

  /// Bakes the drag handle offset into this object's points and saves
  /// the [shouldRepaint()] variables.
  @mustCallSuper
  void finalizeDragHandle() {
    finalizeDragHandlePoints(_dragHandleOffset);
    _dragHandleFocalPoint = null;
    _dragHandleOffset = Offset.zero;
  }

  /// Bakes the drag handle offset into this object's points.
  ///
  /// Example:
  /// ```
  /// for (var i = 0; i < points.length; i++) {
  ///   final point = points[i];
  ///   points[i] = point.copyWith(
  ///     offset: point.offset + offset,
  ///   );
  /// }
  /// ```
  @protected
  void finalizeDragHandlePoints(Offset offset);
}
