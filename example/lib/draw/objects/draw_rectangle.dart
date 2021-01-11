import 'dart:ui';

import 'package:example/draw/draw_object.dart';
import 'package:example/draw/draw_point.dart';
import 'package:flutter/foundation.dart';

class DrawRectangle extends DrawObject {
  final DrawPoint anchor;
  Offset _endpoint;

  DrawRectangle({
    @required this.anchor,
  }) : assert(anchor != null);

  Offset _lastPaintedEndpoint;

  set endpoint(Offset endpoint) {
    _endpoint = endpoint;
  }

  Rect get rect => Rect.fromPoints(anchor.offset, _endpoint ?? anchor.offset);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(rect, anchor.paint);
    _lastPaintedEndpoint = _endpoint;
  }

  @override
  bool shouldRepaint() => _endpoint != _lastPaintedEndpoint;

  @override
  void finalize() {}
}
