import 'package:flutter/widgets.dart';

class DrawPoint {
  final Offset offset;
  final double scale;

  const DrawPoint({
    required this.offset,
    required this.scale,
  });

  factory DrawPoint.fromJSON(Map<String, dynamic> encoded) {
    return DrawPoint(
      offset: Offset(encoded['x'] as double, encoded['y'] as double),
      scale: encoded['s'] as double,
    );
  }

  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'x': offset.dx,
      'y': offset.dy,
      's': scale,
    };
  }
}
