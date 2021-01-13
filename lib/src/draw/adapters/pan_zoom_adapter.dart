import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';
import 'package:window_paint/src/draw/objects/draw_noop.dart';

class PanZoomAdapter extends DrawObjectAdapter<DrawNoop> {
  const PanZoomAdapter();

  @override
  FutureOr<DrawNoop?> start(
      BuildContext context, Offset focalPoint, Color color, Matrix4 transform) {
    return DrawNoop();
  }

  @override
  bool update(
      DrawNoop object, Offset focalPoint, Color color, Matrix4 transform) {
    return false;
  }

  @override
  bool end(DrawNoop object, Color color) {
    return false;
  }

  @override
  bool querySelect(DrawNoop object, Offset focalPoint, Matrix4 transform) {
    return false;
  }

  @override
  void select(DrawNoop object) {
    // TODO: implement select
  }

  @override
  void cancelSelect(DrawNoop object) {
    // TODO: implement cancelSelect
  }

  @override
  bool selectedStart(DrawNoop object, Offset focalPoint, Matrix4 transform) {
    return false;
  }

  @override
  bool selectedUpdate(DrawNoop object, Offset focalPoint, Matrix4 transform) {
    return false;
  }

  @override
  bool selectedEnd(DrawNoop object) => false;

  @override
  void selectUpdateColor(DrawNoop object, Color color) {}

  @override
  bool get panScaleEnabled => true;
  @override
  bool get selectEnabled => true;
}
