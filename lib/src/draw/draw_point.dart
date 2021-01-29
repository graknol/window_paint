import 'package:flutter/widgets.dart';

class DrawPoint {
  final Offset offset;
  final double scale;

  const DrawPoint({
    required this.offset,
    required this.scale,
  });

  factory DrawPoint.fromJSON(Map encoded) {
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

  DrawPoint copyWith({
    Offset? offset,
    double? scale,
  }) {
    return DrawPoint(
      offset: offset ?? this.offset,
      scale: scale ?? this.scale,
    );
  }

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) return true;

    return o is DrawPoint && o.offset == offset && o.scale == scale;
  }

  @override
  int get hashCode => offset.hashCode ^ scale.hashCode;
}
