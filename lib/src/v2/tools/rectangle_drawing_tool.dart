import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:window_paint/src/v2/domain/entities/draw_tool_type.dart';
import 'package:window_paint/src/v2/domain/interfaces/drawable_object.dart';
import 'package:window_paint/src/v2/domain/interfaces/drawing_tool.dart';
import 'package:window_paint/src/v2/domain/entities/rectangle_drawable_object.dart';
import 'package:window_paint/src/v2/data/models/drawable_object_data.dart';
import 'package:window_paint/src/v2/data/models/draw_point_data.dart';

/// Implementation of the rectangle drawing tool using the new architecture.
/// 
/// This demonstrates how to create drawing tools that support both drawing
/// and selection/manipulation in the v2 system.
class RectangleDrawingTool implements ISelectableTool {
  RectangleDrawingTool({
    this.defaultStrokeWidth = 2.0,
    this.filled = false,
    this.minSize = 5.0,
  });

  final double defaultStrokeWidth;
  final bool filled;
  final double minSize; // Minimum size in pixels to keep rectangle
  
  static const _uuid = Uuid();

  @override
  DrawToolType get toolType => DrawToolType.rectangle;

  @override
  bool get supportsPanZoom => false;

  @override
  bool get supportsSelection => true;

  @override
  Future<IDrawableObject?> startDrawing({
    required BuildContext context,
    required Offset startPoint,
    required Color color,
    required Matrix4 transform,
    required Size canvasSize,
    Map<String, dynamic>? options,
  }) async {
    final strokeWidth = options?['strokeWidth'] as double? ?? defaultStrokeWidth;
    final isFilled = options?['filled'] as bool? ?? filled;
    final scale = transform.getMaxScaleOnAxis();
    
    final startPointData = DrawPointData.fromOffset(
      startPoint,
      scale,
      timestamp: DateTime.now(),
    );

    final data = RectangleObjectData(
      id: _uuid.v4(),
      color: color.value,
      strokeWidth: strokeWidth,
      startPoint: startPointData,
      endPoint: startPointData, // Same as start point initially
      filled: isFilled,
    );

    return RectangleDrawableObject(data: data);
  }

  @override
  bool updateDrawing({
    required IDrawableObject object,
    required Offset currentPoint,
    required Color color,
    required Matrix4 transform,
    required Size canvasSize,
  }) {
    if (object is! RectangleDrawableObject) return false;

    final scale = transform.getMaxScaleOnAxis();
    final endPointData = DrawPointData.fromOffset(
      currentPoint,
      scale,
      timestamp: DateTime.now(),
    );

    // Update the end point of the rectangle
    object.updateEndPoint(endPointData);
    
    return true; // Request repaint
  }

  @override
  bool endDrawing({
    required IDrawableObject object,
    required Color color,
    required Size canvasSize,
  }) {
    if (object is! RectangleDrawableObject) return false;

    // Check if the rectangle is large enough to keep
    final bounds = object.bounds;
    final width = (bounds.width * canvasSize.width).abs();
    final height = (bounds.height * canvasSize.height).abs();

    // Only keep the rectangle if it's larger than the minimum size
    return width >= minSize && height >= minSize;
  }

  @override
  bool canSelect({
    required IDrawableObject object,
    required Offset point,
    required Matrix4 transform,
    required Size canvasSize,
  }) {
    if (object is! RectangleDrawableObject) return false;
    
    return object.containsPoint(point, canvasSize);
  }

  @override
  bool startManipulation({
    required IDrawableObject object,
    required Offset startPoint,
    required Matrix4 transform,
    required Size canvasSize,
  }) {
    if (object is! RectangleDrawableObject) return false;

    object.isSelected = true;
    object.isDragging = true;
    
    // Determine what type of manipulation (move, resize, etc.)
    // This is a simplified implementation - you could add handle detection here
    
    return true;
  }

  @override
  bool updateManipulation({
    required IDrawableObject object,
    required Offset currentPoint,
    required Matrix4 transform,
    required Size canvasSize,
  }) {
    if (object is! RectangleDrawableObject || !object.isDragging) return false;

    // For rectangles, manipulation could be:
    // 1. Moving the entire rectangle
    // 2. Resizing by dragging a corner/edge
    // 3. Rotating (if rotation is supported)
    
    // This is a simplified implementation that just moves the rectangle
    // In a real implementation, you'd detect which handle was clicked
    // and perform the appropriate transformation
    
    return true; // Request repaint
  }

  @override
  bool endManipulation({
    required IDrawableObject object,
  }) {
    if (object is! RectangleDrawableObject) return false;

    object.isDragging = false;
    
    return true;
  }

  @override
  void updateColor({
    required IDrawableObject object,
    required Color newColor,
  }) {
    if (object is! RectangleDrawableObject) return;

    object.updateColor(newColor);
  }

  @override
  IDrawableObject? createFromJson(Map<String, dynamic> json) {
    try {
      final data = RectangleObjectData.fromJson(json);
      return RectangleDrawableObject(data: data);
    } catch (e) {
      // Log error and return null
      debugPrint('Error creating RectangleDrawableObject from JSON: $e');
      return null;
    }
  }

  /// Creates a rectangle object programmatically
  IDrawableObject createRectangleObject({
    required String id,
    required Offset startPoint,
    required Offset endPoint,
    required Color color,
    double? strokeWidth,
    bool? filled,
    double scale = 1.0,
  }) {
    final startPointData = DrawPointData.fromOffset(startPoint, scale);
    final endPointData = DrawPointData.fromOffset(endPoint, scale);

    final data = RectangleObjectData(
      id: id,
      color: color.value,
      strokeWidth: strokeWidth ?? defaultStrokeWidth,
      startPoint: startPointData,
      endPoint: endPointData,
      filled: filled ?? this.filled,
    );

    return RectangleDrawableObject(data: data);
  }

  /// Validates if the given JSON represents a valid rectangle object
  bool isValidJson(Map<String, dynamic> json) {
    try {
      return json['toolType'] == 'rectangle' &&
          json.containsKey('id') &&
          json.containsKey('color') &&
          json.containsKey('strokeWidth') &&
          json.containsKey('startPoint') &&
          json.containsKey('endPoint');
    } catch (e) {
      return false;
    }
  }

  /// Gets the tool configuration for serialization
  Map<String, dynamic> getToolConfig() {
    return {
      'toolType': toolType.id,
      'defaultStrokeWidth': defaultStrokeWidth,
      'filled': filled,
      'minSize': minSize,
    };
  }

  /// Creates a tool instance from configuration
  static RectangleDrawingTool fromConfig(Map<String, dynamic> config) {
    return RectangleDrawingTool(
      defaultStrokeWidth: config['defaultStrokeWidth'] as double? ?? 2.0,
      filled: config['filled'] as bool? ?? false,
      minSize: config['minSize'] as double? ?? 5.0,
    );
  }

  /// Detects which part of the rectangle was clicked for manipulation
  RectangleManipulationType _detectManipulationType(
    RectangleDrawableObject object,
    Offset point,
    Size canvasSize,
  ) {
    const handleSize = 8.0; // Pixel size of corner handles
    final normalizedHandleSize = handleSize / canvasSize.shortestSide;
    
    final bounds = object.bounds;
    
    // Check corner handles
    if ((point - bounds.topLeft).distance <= normalizedHandleSize) {
      return RectangleManipulationType.resizeTopLeft;
    }
    if ((point - bounds.topRight).distance <= normalizedHandleSize) {
      return RectangleManipulationType.resizeTopRight;
    }
    if ((point - bounds.bottomLeft).distance <= normalizedHandleSize) {
      return RectangleManipulationType.resizeBottomLeft;
    }
    if ((point - bounds.bottomRight).distance <= normalizedHandleSize) {
      return RectangleManipulationType.resizeBottomRight;
    }
    
    // Check if inside rectangle (move)
    if (bounds.contains(point)) {
      return RectangleManipulationType.move;
    }
    
    return RectangleManipulationType.none;
  }
}

/// Enumeration of rectangle manipulation types
enum RectangleManipulationType {
  none,
  move,
  resizeTopLeft,
  resizeTopRight,
  resizeBottomLeft,
  resizeBottomRight,
}