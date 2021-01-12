import 'dart:ui';

import 'package:window_paint/src/draw/draw_object.dart';
import 'package:flutter/foundation.dart';

@immutable
abstract class DrawObjectAdapter<T extends DrawObject> {
  const DrawObjectAdapter();

  T start(Offset focalPoint, Color color);

  /// Returning [true] will trigger a re-paint.
  ///
  /// This is useful for things like pan/zoom
  /// where you don't paint anything.
  bool update(T object, Offset focalPoint, Color color);

  /// Returning [true] will keep the object,
  /// [false] will discard it.
  ///
  /// This is useful for things like pan/zoom
  /// where you want to fulfill the contract,
  /// but not draw anything.
  bool end(T object, Color color);

  bool get panEnabled => false;
  bool get scaleEnabled => false;
}
