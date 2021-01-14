import 'package:flutter/widgets.dart';

class DrawPoint {
  final Offset offset;
  final Paint paint;
  final double scale;

  const DrawPoint({
    required this.offset,
    required this.paint,
    required this.scale,
  });
}
