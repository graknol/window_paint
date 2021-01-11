import 'package:window_paint/draw/draw_point.dart';
import 'package:window_paint/extensions/offset.extensions.dart';

extension DrawPointExtensions on DrawPoint {
  double squaredDistanceTo(DrawPoint other) =>
      offset.squaredDistanceTo(other.offset);

  double squaredDistanceToLine(DrawPoint lineStart, DrawPoint lineEnd) =>
      offset.squaredDistanceToLine(lineStart.offset, lineEnd.offset);
}
