import 'dart:ui';

import 'package:example/draw/draw_object.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class WindowPaintPainter extends CustomPainter {
  final List<DrawObject> objects;

  WindowPaintPainter({
    @required this.objects,
  }) : assert(objects != null);

  @override
  void paint(Canvas canvas, Size size) {
    for (final object in objects) {
      object.paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(WindowPaintPainter oldDelegate) =>
      objects.any((object) => object.shouldRepaint());

  @override
  bool shouldRebuildSemantics(WindowPaintPainter oldDelegate) => false;
}
