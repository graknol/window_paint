import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:window_paint/src/v2/domain/interfaces/drawable_object.dart';
import 'package:window_paint/src/v2/data/models/simple_drawable_object_data.dart';

/// Concrete implementation of a pencil/freehand drawing object.
/// 
/// This demonstrates the new architecture's separation between data and behavior.
class PencilDrawableObject implements IDrawableObject {
  PencilDrawableObject({
    required this.data,
    this.isSelected = false,
    this.isDragging = false,
  });

  final DrawableObjectData data;
  
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
    final points = _getPoints();
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = data.strokeWidth
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(
        denormalize(points[i]),
        denormalize(points[i + 1]),
        paint,
      );
    }

    if (isSelected) {
      _renderSelectionOutline(canvas, size, denormalize);
    }
  }

  List<Offset> _getPoints() {
    final pointsData = data.data['points'] as List<dynamic>? ?? [];
    return pointsData.map((p) => Offset(p['x'] as double, p['y'] as double)).toList();
  }

  void _renderSelectionOutline(Canvas canvas, Size size, Offset Function(Offset) denormalize) {
    final bounds = getBounds();
    if (bounds == Rect.zero) return;

    final padding = 5.0 / size.shortestSide;
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
    const hitboxRadius = 10.0;
    final points = _getPoints();

    for (final dataPoint in points) {
      final distance = (dataPoint - point).distance;
      final normalizedRadius = hitboxRadius / size.shortestSide;
      
      if (distance <= normalizedRadius) {
        return true;
      }
    }
    return false;
  }

  @override
  Rect getBounds() {
    final points = _getPoints();
    if (points.isEmpty) return Rect.zero;

    double minX = points.first.dx, maxX = points.first.dx;
    double minY = points.first.dy, maxY = points.first.dy;

    for (final point in points) {
      minX = minX < point.dx ? minX : point.dx;
      maxX = maxX > point.dx ? maxX : point.dx;
      minY = minY < point.dy ? minY : point.dy;
      maxY = maxY > point.dy ? maxY : point.dy;
    }

    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  @override
  IDrawableObject clone() {
    return PencilDrawableObject(
      data: DrawableObjectData(
        id: data.id,
        toolType: data.toolType,
        color: data.color,
        strokeWidth: data.strokeWidth,
        data: Map<String, dynamic>.from(data.data),
        metadata: Map<String, dynamic>.from(data.metadata),
      ),
      isSelected: isSelected,
      isDragging: isDragging,
    );
  }

  @override
  Map<String, dynamic> toJson() => data.toJson();

  @override
  bool shouldRepaint() => true;

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
    return 'PencilDrawableObject(id: $id, isSelected: $isSelected, isDragging: $isDragging)';
  }
}