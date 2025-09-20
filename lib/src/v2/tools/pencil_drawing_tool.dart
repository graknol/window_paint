import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:uuid/uuid.dart';
import 'package:window_paint/src/v2/domain/entities/draw_tool_type.dart';
import 'package:window_paint/src/v2/domain/interfaces/drawable_object.dart';
import 'package:window_paint/src/v2/domain/interfaces/drawing_tool.dart';
import 'package:window_paint/src/v2/domain/entities/pencil_drawable_object.dart';
import 'package:window_paint/src/v2/data/models/drawable_object_data.dart';
import 'package:window_paint/src/v2/data/models/draw_point_data.dart';

/// Implementation of the pencil drawing tool using the new architecture.
/// 
/// This demonstrates how drawing tools are implemented in the v2 system
/// with better separation of concerns and extensibility.
class PencilDrawingTool implements ISelectableTool {
  PencilDrawingTool({
    this.defaultStrokeWidth = 2.0,
    this.hitboxExtent = 10.0,
    this.simplifyTolerance = 1.0,
    this.autoSimplify = true,
  });

  final double defaultStrokeWidth;
  final double hitboxExtent;
  final double simplifyTolerance;
  final bool autoSimplify;
  
  static const _uuid = Uuid();

  @override
  DrawToolType get toolType => DrawToolType.pencil;

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
    final scale = transform.getMaxScaleOnAxis();
    
    final firstPoint = DrawPointData.fromOffset(
      startPoint,
      scale,
      timestamp: DateTime.now(),
    );

    final data = PencilObjectData(
      id: _uuid.v4(),
      color: color.value,
      strokeWidth: strokeWidth,
      points: [firstPoint],
    );

    return PencilDrawableObject(data: data);
  }

  @override
  bool updateDrawing({
    required IDrawableObject object,
    required Offset currentPoint,
    required Color color,
    required Matrix4 transform,
    required Size canvasSize,
  }) {
    if (object is! PencilDrawableObject) return false;

    final scale = transform.getMaxScaleOnAxis();
    final newPoint = DrawPointData.fromOffset(
      currentPoint,
      scale,
      timestamp: DateTime.now(),
    );

    // Add the new point to the pencil stroke
    object.addPoint(newPoint);
    
    return true; // Request repaint
  }

  @override
  bool endDrawing({
    required IDrawableObject object,
    required Color color,
    required Size canvasSize,
  }) {
    if (object is! PencilDrawableObject) return false;

    // Simplify the stroke if auto-simplification is enabled
    if (autoSimplify && object.data.points.length > 2) {
      object.simplify();
    }

    // Only keep the object if it has at least 2 points
    return object.data.points.length >= 2;
  }

  @override
  bool canSelect({
    required IDrawableObject object,
    required Offset point,
    required Matrix4 transform,
    required Size canvasSize,
  }) {
    if (object is! PencilDrawableObject) return false;
    
    return object.containsPoint(point, canvasSize);
  }

  @override
  bool startManipulation({
    required IDrawableObject object,
    required Offset startPoint,
    required Matrix4 transform,
    required Size canvasSize,
  }) {
    if (object is! PencilDrawableObject) return false;

    object.isSelected = true;
    object.isDragging = true;
    
    return true;
  }

  @override
  bool updateManipulation({
    required IDrawableObject object,
    required Offset currentPoint,
    required Matrix4 transform,
    required Size canvasSize,
  }) {
    if (object is! PencilDrawableObject || !object.isDragging) return false;

    // For pencil objects, manipulation typically means moving the entire stroke
    // This is a simplified implementation - you might want to implement
    // more sophisticated manipulation like reshaping specific parts
    
    return true; // Request repaint
  }

  @override
  bool endManipulation({
    required IDrawableObject object,
  }) {
    if (object is! PencilDrawableObject) return false;

    object.isDragging = false;
    
    return true;
  }

  @override
  void updateColor({
    required IDrawableObject object,
    required Color newColor,
  }) {
    if (object is! PencilDrawableObject) return;

    object.updateColor(newColor);
  }

  @override
  IDrawableObject? createFromJson(Map<String, dynamic> json) {
    try {
      final data = PencilObjectData.fromJson(json);
      return PencilDrawableObject(data: data);
    } catch (e) {
      // Log error and return null
      debugPrint('Error creating PencilDrawableObject from JSON: $e');
      return null;
    }
  }

  /// Creates a pencil object programmatically
  IDrawableObject createPencilObject({
    required String id,
    required List<Offset> points,
    required Color color,
    double? strokeWidth,
    double scale = 1.0,
  }) {
    final dataPoints = points.map((point) => DrawPointData.fromOffset(
      point,
      scale,
    )).toList();

    final data = PencilObjectData(
      id: id,
      color: color.value,
      strokeWidth: strokeWidth ?? defaultStrokeWidth,
      points: dataPoints,
    );

    return PencilDrawableObject(data: data);
  }

  /// Validates if the given JSON represents a valid pencil object
  bool isValidJson(Map<String, dynamic> json) {
    try {
      return json['toolType'] == 'pencil' &&
          json.containsKey('id') &&
          json.containsKey('color') &&
          json.containsKey('strokeWidth') &&
          json.containsKey('points') &&
          json['points'] is List;
    } catch (e) {
      return false;
    }
  }

  /// Gets the tool configuration for serialization
  Map<String, dynamic> getToolConfig() {
    return {
      'toolType': toolType.id,
      'defaultStrokeWidth': defaultStrokeWidth,
      'hitboxExtent': hitboxExtent,
      'simplifyTolerance': simplifyTolerance,
      'autoSimplify': autoSimplify,
    };
  }

  /// Creates a tool instance from configuration
  static PencilDrawingTool fromConfig(Map<String, dynamic> config) {
    return PencilDrawingTool(
      defaultStrokeWidth: config['defaultStrokeWidth'] as double? ?? 2.0,
      hitboxExtent: config['hitboxExtent'] as double? ?? 10.0,
      simplifyTolerance: config['simplifyTolerance'] as double? ?? 1.0,
      autoSimplify: config['autoSimplify'] as bool? ?? true,
    );
  }
}