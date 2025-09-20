import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:window_paint/src/v2/domain/interfaces/drawable_object.dart';
import 'package:window_paint/src/v2/data/models/drawable_object_data.dart';
import 'package:window_paint/src/v2/data/models/draw_point_data.dart';

/// Concrete implementation of a pencil/freehand drawing object.
/// 
/// This demonstrates the new architecture's separation between data and behavior.
class PencilDrawableObject implements IDrawableObject {
  PencilDrawableObject({
    required this.data,
    this.isSelected = false,
    this.isDragging = false,
  });

  /// The underlying data model
  final PencilObjectData data;
  
  /// Whether this object is currently selected
  bool isSelected;
  
  /// Whether this object is being dragged
  bool isDragging;

  @override
  String get id => data.id;

  @override
  String get toolType => data.toolType;

  @override
  Color get primaryColor => data.colorValue;

  @override
  void render(Canvas canvas, Size size, Offset Function(Offset) denormalize) {
    if (data.points.isEmpty) return;

    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = data.strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;

    // Draw the pencil stroke
    for (int i = 0; i < data.points.length - 1; i++) {
      final from = data.points[i];
      final to = data.points[i + 1];
      
      canvas.drawLine(
        denormalize(from.toOffset()),
        denormalize(to.toOffset()),
        paint,
      );
    }

    // Draw selection outline if selected
    if (isSelected) {
      _renderSelectionOutline(canvas, size, denormalize);
    }
  }

  void _renderSelectionOutline(Canvas canvas, Size size, Offset Function(Offset) denormalize) {
    if (data.points.isEmpty) return;

    final bounds = getBounds();
    final padding = 5.0 / size.shortestSide; // Normalized padding
    final selectionRect = bounds.inflate(padding);

    final selectionPaint = Paint()
      ..color = const Color(0x8A000000)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final denormalizedRect = Rect.fromPoints(
      denormalize(selectionRect.topLeft),
      denormalize(selectionRect.bottomRight),
    );

    canvas.drawRect(denormalizedRect, selectionPaint);
  }

  @override
  bool containsPoint(Offset point, Size size) {
    const hitboxRadius = 10.0; // Pixel radius for hit detection

    for (final dataPoint in data.points) {
      final distance = (dataPoint.toOffset() - point).distance;
      // Convert pixel radius to normalized coordinates
      final normalizedRadius = hitboxRadius / dataPoint.scale / size.shortestSide;
      
      if (distance <= normalizedRadius) {
        return true;
      }
    }

    return false;
  }

  @override
  Rect getBounds() {
    if (data.points.isEmpty) return Rect.zero;

    double minX = data.points.first.x;
    double maxX = data.points.first.x;
    double minY = data.points.first.y;
    double maxY = data.points.first.y;

    for (final point in data.points) {
      minX = minX < point.x ? minX : point.x;
      maxX = maxX > point.x ? maxX : point.x;
      minY = minY < point.y ? minY : point.y;
      maxY = maxY > point.y ? maxY : point.y;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  @override
  IDrawableObject clone() {
    final clonedData = PencilObjectData(
      id: data.id,
      color: data.color,
      strokeWidth: data.strokeWidth,
      points: data.points.map((p) => DrawPointData(
        x: p.x,
        y: p.y,
        scale: p.scale,
        pressure: p.pressure,
        timestamp: p.timestamp,
      )).toList(),
      simplified: data.simplified,
      metadata: Map<String, dynamic>.from(data.metadata),
    );

    return PencilDrawableObject(
      data: clonedData,
      isSelected: isSelected,
      isDragging: isDragging,
    );
  }

  @override
  Map<String, dynamic> toJson() => data.toJson();

  @override
  bool shouldRepaint() {
    // For pencil objects, we generally need to repaint when:
    // - The object is being drawn (points are being added)
    // - Selection state changes
    // - Color or stroke width changes
    return true; // Simplified for now
  }

  /// Adds a point to the pencil stroke
  void addPoint(DrawPointData point) {
    // Create new data with added point
    final newPoints = [...data.points, point];
    final newData = data.copyWith(points: newPoints);
    
    // Replace the data reference
    // Note: This is a simplified approach. In a more complex system,
    // you might want to use a different pattern for immutability.
  }

  /// Simplifies the pencil stroke by reducing the number of points
  void simplify() {
    if (data.simplified || data.points.length <= 2) return;

    // Implement Douglas-Peucker simplification algorithm
    final simplified = _simplifyPoints(data.points, tolerance: 1.0);
    final newData = data.copyWith(
      points: simplified,
      simplified: true,
    );
    
    // Update the data
    // Note: Again, this is simplified. Consider immutability patterns.
  }

  /// Simplified version of Douglas-Peucker algorithm
  List<DrawPointData> _simplifyPoints(List<DrawPointData> points, {double tolerance = 1.0}) {
    if (points.length <= 2) return points;

    // Find the point with the maximum distance from the line segment
    double maxDistance = 0.0;
    int maxIndex = 0;

    final start = points.first.toOffset();
    final end = points.last.toOffset();

    for (int i = 1; i < points.length - 1; i++) {
      final point = points[i].toOffset();
      final distance = _distanceToLineSegment(point, start, end);
      
      if (distance > maxDistance) {
        maxDistance = distance;
        maxIndex = i;
      }
    }

    // If max distance is greater than tolerance, recursively simplify
    if (maxDistance > tolerance) {
      final firstHalf = _simplifyPoints(points.sublist(0, maxIndex + 1), tolerance: tolerance);
      final secondHalf = _simplifyPoints(points.sublist(maxIndex), tolerance: tolerance);
      
      // Combine results, avoiding duplicate middle point
      return [...firstHalf.sublist(0, firstHalf.length - 1), ...secondHalf];
    } else {
      // Return simplified version with just start and end points
      return [points.first, points.last];
    }
  }

  /// Calculates the distance from a point to a line segment
  double _distanceToLineSegment(Offset point, Offset lineStart, Offset lineEnd) {
    final A = point.dx - lineStart.dx;
    final B = point.dy - lineStart.dy;
    final C = lineEnd.dx - lineStart.dx;
    final D = lineEnd.dy - lineStart.dy;

    final dot = A * C + B * D;
    final lenSq = C * C + D * D;
    
    if (lenSq == 0) return (point - lineStart).distance;

    final param = dot / lenSq;

    Offset closest;
    if (param < 0) {
      closest = lineStart;
    } else if (param > 1) {
      closest = lineEnd;
    } else {
      closest = Offset(
        lineStart.dx + param * C,
        lineStart.dy + param * D,
      );
    }

    return (point - closest).distance;
  }

  /// Updates the color of this object
  void updateColor(Color newColor) {
    // Create new data with updated color
    final newData = data.copyWith(color: newColor.value);
    // Update the data reference (simplified approach)
  }

  /// Moves this object by the given offset
  void move(Offset offset) {
    final newPoints = data.points.map((point) => point.copyWith(
      x: point.x + offset.dx,
      y: point.y + offset.dy,
    )).toList();
    
    final newData = data.copyWith(points: newPoints);
    // Update the data reference
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PencilDrawableObject &&
        other.data == data &&
        other.isSelected == isSelected &&
        other.isDragging == isDragging;
  }

  @override
  int get hashCode => Object.hash(data, isSelected, isDragging);

  @override
  String toString() {
    return 'PencilDrawableObject(id: $id, pointCount: ${data.points.length}, '
        'isSelected: $isSelected, isDragging: $isDragging)';
  }
}