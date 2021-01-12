import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:window_paint/src/draw/draw_object.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class DrawObjectAdapter<T extends DrawObject> {
  const DrawObjectAdapter();

  /// Returning [null] will discard the object.
  ///
  /// Returning a [Future] will prevent [update] and [end] from being called.
  /// The reason for this is that there's no good way of delaying those events
  /// until the [Future] completes. The [Future] should complete with either
  /// a fully constructed [DrawObject], or [null] to discard it.
  FutureOr<T?> start(BuildContext context, Offset focalPoint, Color color);

  /// Returning [true] will trigger a re-paint.
  ///
  /// This is useful for things like pan/zoom
  /// where you don't paint anything.
  ///
  /// NOTE: Will not be called if [start] returned a [Future].
  bool update(T object, Offset focalPoint, Color color);

  /// Returning [true] will keep the object,
  /// [false] will discard it.
  ///
  /// This is useful for things like pan/zoom
  /// where you want to fulfill the contract,
  /// but not draw anything.
  ///
  /// NOTE: Will not be called if [start] returned a [Future].
  bool end(T object, Color color);

  bool get panEnabled => false;
  bool get scaleEnabled => false;
}
