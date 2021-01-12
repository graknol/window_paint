import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';
import 'package:window_paint/src/draw/objects/draw_noop.dart';

class PanZoomAdapter extends DrawObjectAdapter<DrawNoop> {
  const PanZoomAdapter();

  @override
  FutureOr<DrawNoop?> start(
      BuildContext context, Offset focalPoint, Color color) {
    return DrawNoop();
  }

  @override
  bool update(DrawNoop object, Offset focalPoint, Color color) => false;

  @override
  bool end(DrawNoop object, Color color) {
    return false;
  }

  @override
  bool get panEnabled => true;
  @override
  bool get scaleEnabled => true;
}
