import 'dart:ui';
import 'package:window_paint/src/v2/domain/interfaces/drawable_object.dart';
import 'package:window_paint/src/v2/data/models/drawable_object_data.dart';
import 'package:window_paint/src/v2/data/models/draw_point_data.dart';

/// Concrete implementation of a rectangle drawable object.
/// 
/// This demonstrates how to create custom drawable objects in the v2 architecture.
class RectangleDrawableObject implements IDrawableObject {
  RectangleDrawableObject({
    required this.data,
    this.isSelected = false,
    this.isDragging = false,
  });

  /// The underlying data model
  final RectangleObjectData data;
  
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

  /// Gets the rectangle bounds
  Rect get bounds => Rect.fromPoints(
    data.startPoint.toOffset(),
    data.endPoint.toOffset(),
  );

  @override
  void render(Canvas canvas, Size size, Offset Function(Offset) denormalize) {
    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = data.strokeWidth
      ..style = data.filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..isAntiAlias = true;

    // Draw the rectangle
    final rect = Rect.fromPoints(
      denormalize(data.startPoint.toOffset()),
      denormalize(data.endPoint.toOffset()),
    );
    
    canvas.drawRect(rect, paint);

    // Draw selection outline if selected
    if (isSelected) {
      _renderSelectionOutline(canvas, size, denormalize);
    }
  }

  void _renderSelectionOutline(Canvas canvas, Size size, Offset Function(Offset) denormalize) {
    const padding = 5.0; // Pixel padding for selection outline
    
    final rect = Rect.fromPoints(
      denormalize(data.startPoint.toOffset()),
      denormalize(data.endPoint.toOffset()),
    );
    
    final selectionRect = rect.inflate(padding);

    final selectionPaint = Paint()
      ..color = const Color(0x8A000000)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawRect(selectionRect, selectionPaint);
    
    // Draw corner handles
    const handleSize = 8.0;
    final handlePaint = Paint()
      ..color = const Color(0xFF000000)
      ..style = PaintingStyle.fill;

    // Top-left handle
    canvas.drawRect(
      Rect.fromLTWH(
        selectionRect.left - handleSize / 2,
        selectionRect.top - handleSize / 2,
        handleSize,
        handleSize,
      ),
      handlePaint,
    );

    // Top-right handle
    canvas.drawRect(
      Rect.fromLTWH(
        selectionRect.right - handleSize / 2,
        selectionRect.top - handleSize / 2,
        handleSize,
        handleSize,
      ),
      handlePaint,
    );

    // Bottom-left handle
    canvas.drawRect(
      Rect.fromLTWH(
        selectionRect.left - handleSize / 2,
        selectionRect.bottom - handleSize / 2,
        handleSize,
        handleSize,
      ),
      handlePaint,
    );

    // Bottom-right handle
    canvas.drawRect(
      Rect.fromLTWH(
        selectionRect.right - handleSize / 2,
        selectionRect.bottom - handleSize / 2,
        handleSize,
        handleSize,
      ),
      handlePaint,
    );
  }

  @override
  bool containsPoint(Offset point, Size size) {
    const hitboxPadding = 5.0; // Pixels

    // Convert pixel padding to normalized coordinates
    final normalizedPadding = hitboxPadding / size.shortestSide;
    
    // Check if point is within the rectangle bounds (with padding)
    final expandedBounds = bounds.inflate(normalizedPadding);
    
    if (data.filled) {
      // For filled rectangles, check if point is inside
      return expandedBounds.contains(point);
    } else {
      // For stroke rectangles, check if point is near the border
      return expandedBounds.contains(point) && !bounds.deflate(normalizedPadding).contains(point);
    }
  }

  @override
  Rect getBounds() => bounds;

  @override
  IDrawableObject clone() {
    final clonedData = RectangleObjectData(
      id: data.id,
      color: data.color,
      strokeWidth: data.strokeWidth,
      startPoint: DrawPointData(
        x: data.startPoint.x,
        y: data.startPoint.y,
        scale: data.startPoint.scale,
        pressure: data.startPoint.pressure,
        timestamp: data.startPoint.timestamp,
      ),
      endPoint: DrawPointData(
        x: data.endPoint.x,
        y: data.endPoint.y,
        scale: data.endPoint.scale,
        pressure: data.endPoint.pressure,
        timestamp: data.endPoint.timestamp,
      ),
      filled: data.filled,
      metadata: Map<String, dynamic>.from(data.metadata),
    );

    return RectangleDrawableObject(
      data: clonedData,
      isSelected: isSelected,
      isDragging: isDragging,
    );
  }

  @override
  Map<String, dynamic> toJson() => data.toJson();

  @override
  bool shouldRepaint() {
    // Rectangle objects need repainting when:
    // - Selection state changes
    // - Color or stroke width changes
    // - Position changes
    return true; // Simplified for now
  }

  /// Updates the end point of the rectangle (used during drawing)
  void updateEndPoint(DrawPointData newEndPoint) {
    // Note: In a proper immutable implementation, this would create a new object
    // For this demonstration, we're showing the concept but not full immutability
    // Consider using state management patterns like Riverpod or Bloc for production
  }

  /// Updates the color of this rectangle
  void updateColor(Color newColor) {
    // Note: This is a simplified mutable approach for demonstration
    // In production, consider using proper state management patterns
  }

  /// Moves this rectangle by the given offset
  void move(Offset offset) {
    // Note: This is a simplified mutable approach for demonstration
    // In production, consider using proper state management patterns
  }

  /// Resizes the rectangle by updating the end point
  void resize(Offset newEndPoint) {
    // Note: This is a simplified mutable approach for demonstration
    // In production, consider using proper state management patterns
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RectangleDrawableObject &&
        other.data == data &&
        other.isSelected == isSelected &&
        other.isDragging == isDragging;
  }

  @override
  int get hashCode => Object.hash(data, isSelected, isDragging);

  @override
  String toString() {
    return 'RectangleDrawableObject(id: $id, bounds: $bounds, '
        'filled: ${data.filled}, isSelected: $isSelected, isDragging: $isDragging)';
  }
}