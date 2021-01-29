import 'dart:ui';

import 'package:vector_math/vector_math_64.dart';

class Line {
  Line({
    required this.start,
    required this.end,
    this.extent = 1.0,
  }) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    normal = Vector2(-dy, dx)
      ..normalize()
      ..scale(extent);

    final s = Vector2(start.dx, start.dy);
    final e = Vector2(end.dx, end.dy);
    a = s + normal;
    b = e + normal;
    c = e - normal;
    d = s - normal;
  }

  /// Start of this.
  final Offset start;

  /// End of this.
  final Offset end;

  /// Half the width of this.
  final double extent;

  /// The normal vector to this. Its magnitude is equal to [extent].
  late final Vector2 normal;

  /// The A corner.
  late final Vector2 a;

  /// The B corner.
  late final Vector2 b;

  /// The C corner.
  late final Vector2 c;

  /// The D corner.
  late final Vector2 d;

  bool contains(Offset offset) {
    final m = Vector2(offset.dx, offset.dy);

    final ab = b - a;
    final ad = d - a;
    final am = m - a;

    var dotAMAB = am.dot(ab);
    var dotABAB = ab.dot(ab);
    var dotAMAD = am.dot(ad);
    var dotADAD = ad.dot(ad);

    return 0 < dotAMAB && dotAMAB < dotABAB && 0 < dotAMAD && dotAMAD < dotADAD;
  }
}
