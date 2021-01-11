import 'package:window_paint/draw/draw_object.dart';
import 'dart:ui';

import 'package:window_paint/draw/draw_object_adapter.dart';
import 'package:window_paint/draw/objects/draw_noop.dart';

class PanZoomAdapter extends DrawObjectAdapter {
  const PanZoomAdapter();

  @override
  DrawObject start(Offset focalPoint, Color color) {
    return DrawNoop();
  }

  @override
  bool update(DrawObject object, Offset focalPoint, Color color) => false;

  @override
  bool end(DrawObject object, Color color) {
    return false;
  }

  @override
  bool get panEnabled => true;
  @override
  bool get scaleEnabled => true;
}
