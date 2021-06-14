import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:window_paint/src/draw/draw_object.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class DrawObjectAdapter<T extends DrawObject> {
  const DrawObjectAdapter();

  /// Whether the canvas should pan and scale in response to touch events.
  bool get panScaleEnabled => false;

  /// Whether the canvas should attempt to select objects in response to
  /// touch events.
  bool get selectEnabled => false;

  /// The unique identifier of this.
  ///
  /// Used when transforming [DrawObject] to and from JSON. Identifies which
  /// [DrawObjectAdapter] is responsible for constructing the [DrawObject].
  ///
  /// Also used to match against [WindowPaintController.mode].
  String get typeId;

  /// Returning [null] will discard the object.
  ///
  /// Returning a [Future] will prevent [update()] and [end()] from
  /// being called. The reason for this is that there's no good way of delaying
  /// those events until the [Future] completes. The [Future] should complete
  /// with either a fully constructed [DrawObject] or [null] to discard it.
  FutureOr<T?> start(
      BuildContext context, Offset focalPoint, Color color, Matrix4 transform);

  /// Returning [true] will trigger a re-paint.
  ///
  /// Useful for pan/zoom where you don't paint anything.
  ///
  /// NOTE: Will not be called if [start()] returned a [Future].
  bool update(T object, Offset focalPoint, Color color, Matrix4 transform);

  /// Returning [true] will keep the object, [false] will discard it.
  ///
  /// Useful for pan/zoom where you want to fulfill the contract, but not
  /// draw anything.
  ///
  /// NOTE: Will not be called if [start()] returned a [Future].
  bool end(T object, Color color);

  /// Returning [true] will select the object.
  ///
  /// This is needed as the consumer can't know a DrawObject's size or position.
  bool querySelect(T object, Offset focalPoint, Matrix4 transform);

  /// The object has been chosen as the selected object. It should render its
  /// hitbox and interactive handles, if any.
  void select(T object);

  /// The object is no longer being selected. It should no longer render its
  /// hitbox and interactive handles.
  void cancelSelect(T object);

  /// Returning [false] will cancel the selection of the object, in which case
  /// [selectedUpdate()] and [selectedEnd()] will not be called for the
  /// same interaction.
  ///
  /// Useful for resize handles or moving the object.
  bool selectedStart(T object, Offset focalPoint, Matrix4 transform);

  /// Returning [true] will trigger a re-paint.
  ///
  /// Useful for interacting with resize handles or moving the object.
  bool selectedUpdate(T object, Offset focalPoint, Matrix4 transform);

  /// Returning [false] will cancel the selection of the object.
  bool selectedEnd(T object);

  /// Triggered by a change in [color] when an object is selected.
  void selectUpdateColor(T object, Color color);

  /// Creates an instance of [DrawObject] from a JSON object.
  ///
  /// If [denormalizeFromSize] is not [null], then the coordinates given
  /// in [encoded] should be denormalized according to it (usually used to map
  /// them from the range [0-1] to [m-n]).
  T fromJSON(Map encoded, {Size? denormalizeFromSize});
}
