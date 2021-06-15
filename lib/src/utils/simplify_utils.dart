import 'package:window_paint/src/draw/draw_point.dart';
import 'package:window_paint/src/extensions/draw_point_extensions.dart';

/// Credit goes to mourner for his awesome JavaScript library:
/// https://github.com/mourner/simplify-js/blob/6930f87d19f87a5b262becaf1fd3080102b0cb51/simplify.js#L1
///
/// The has been converted to Dart and adapted to fit this library's point system.
///
///
/// Copyright (c) 2017, Vladimir Agafonkin
/// All rights reserved.
///
/// Redistribution and use in source and binary forms, with or without modification, are
/// permitted provided that the following conditions are met:
///
///    1. Redistributions of source code must retain the above copyright notice, this list of
///       conditions and the following disclaimer.
///
///    2. Redistributions in binary form must reproduce the above copyright notice, this list
///       of conditions and the following disclaimer in the documentation and/or other materials
///       provided with the distribution.
///
/// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
/// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
/// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
/// COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
/// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
/// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
/// HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR
/// TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
/// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

// basic distance-based simplification
List<DrawPoint> _simplifyRadialDist(
  List<DrawPoint> points,
  double sqTolerance,
) {
  var point = points.first;
  var prevPoint = points.first;
  final newPoints = [prevPoint];

  for (var i = 1; i < points.length; i++) {
    point = points[i];
    if (point.squaredDistanceTo(prevPoint) > sqTolerance) {
      newPoints.add(point);
      prevPoint = point;
    }
  }
  if (prevPoint != point) {
    newPoints.add(point);
  }
  return newPoints;
}

void _simplifyDPStep(
  List<DrawPoint> points,
  int from,
  int to,
  double sqTolerance,
  List<DrawPoint> simplified,
) {
  var index = 0;
  var maxSqDist = sqTolerance;

  for (var i = from + 1; i < to; i++) {
    final point = points[i];
    final lineStart = points[from];
    final lineEnd = points[to];
    final sqDist = point.squaredDistanceToLine(lineStart, lineEnd);
    if (sqDist > maxSqDist) {
      index = i;
      maxSqDist = sqDist;
    }
  }

  if (maxSqDist > sqTolerance) {
    if (index - from > 1) {
      _simplifyDPStep(points, from, index, sqTolerance, simplified);
    }
    simplified.add(points[index]);
    if (to - index > 1) {
      _simplifyDPStep(points, index, to, sqTolerance, simplified);
    }
  }
}

// simplification using Ramer-Douglas-Peucker algorithm
List<DrawPoint> _simplifyDouglasPeucker(
  List<DrawPoint> points,
  double sqTolerance,
) {
  final simplified = [points.first];
  final from = 0;
  final to = points.length - 1;
  _simplifyDPStep(points, from, to, sqTolerance, simplified);
  simplified.add(points[to]);
  return simplified;
}

List<DrawPoint> simplifyPoints(
  List<DrawPoint> points, {
  double tolerance = 1.0,
  bool fastMode = false,
}) {
  if (points.length <= 2) {
    return points;
  }

  final sqTolerance = tolerance * tolerance;
  if (fastMode) {
    points = _simplifyRadialDist(points, sqTolerance);
  }
  points = _simplifyDouglasPeucker(points, sqTolerance);
  return points;
}
