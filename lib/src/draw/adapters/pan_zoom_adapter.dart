import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';
import 'package:window_paint/src/draw/objects/draw_noop.dart';

class PanZoomAdapter extends DrawObjectAdapter<DrawNoop> {
  const PanZoomAdapter();

  @override
  bool get panScaleEnabled => true;

  @override
  bool get selectEnabled => true;

  /// Used to generate unique IDs for each [DrawNoop].
  final _uuid = const Uuid();

  @override
  String get typeId => 'pan_zoom';

  @override
  FutureOr<DrawNoop?> start(
    BuildContext context,
    Offset focalPoint,
    Color color,
    Matrix4 transform,
    Size size,
  ) {
    return DrawNoop(
      adapter: this,
      id: _uuid.v4(),
    );
  }

  @override
  bool update(
    DrawNoop object,
    Offset focalPoint,
    Color color,
    Matrix4 transform,
    Size size,
  ) {
    return false;
  }

  @override
  bool end(
    DrawNoop object,
    Color color,
    Size size,
  ) {
    return false;
  }

  @override
  bool querySelect(
    DrawNoop object,
    Offset focalPoint,
    Matrix4 transform,
    Size size,
  ) {
    return false;
  }

  @override
  void select(DrawNoop object) {}

  @override
  void cancelSelect(DrawNoop object) {}

  @override
  bool selectedStart(
    DrawNoop object,
    Offset focalPoint,
    Matrix4 transform,
    Size size,
  ) {
    return false;
  }

  @override
  bool selectedUpdate(
    DrawNoop object,
    Offset focalPoint,
    Matrix4 transform,
    Size size,
  ) {
    return false;
  }

  @override
  bool selectedEnd(DrawNoop object) => false;

  @override
  void selectUpdateColor(DrawNoop object, Color color) {}

  @override
  DrawNoop fromJSON(Map encoded) => DrawNoop.fromJSON(this, encoded);
}
