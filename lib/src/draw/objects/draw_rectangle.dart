import 'dart:ui';

import 'package:window_paint/src/draw/draw_object.dart';
import 'package:window_paint/src/draw/draw_point.dart';

class DrawRectangle extends DrawObject {
  final DrawPoint anchor;
  Offset? _endpoint;

  DrawRectangle({
    required this.anchor,
  });

  Offset? _lastPaintedEndpoint;

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
