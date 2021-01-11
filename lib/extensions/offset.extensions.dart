import 'dart:ui';

extension OffsetExtensions on Offset {
  double squaredDistanceTo(Offset other) => (other - this).distanceSquared;

  double squaredDistanceToLine(Offset lineStart, Offset lineEnd) {
    final px = this.dx;
    final py = this.dy;
    var x = lineStart.dx;
    var y = lineStart.dy;
    final dx = lineEnd.dx - x;
    final dy = lineEnd.dy - y;
    if (dx != 0 || dy != 0) {
      final t = ((px - x) * dx + (py - y) * dy) / (dx * dx + dy * dy);
      if (t > 1) {
        x = lineEnd.dx;
        y = lineEnd.dy;
      } else if (t > 0) {
        x += dx * t;
        y += dy * t;
      }
    }
    final rx = px - x;
    final ry = py - y;
    return rx * rx + ry * ry;
  }
}
