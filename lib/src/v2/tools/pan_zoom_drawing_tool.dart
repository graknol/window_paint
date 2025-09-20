import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:window_paint/src/v2/domain/entities/draw_tool_type.dart';
import 'package:window_paint/src/v2/domain/interfaces/drawable_object.dart';
import 'package:window_paint/src/v2/domain/interfaces/drawing_tool.dart';

/// Implementation of the pan/zoom tool for the v2 architecture.
/// 
/// This tool doesn't create drawable objects but enables navigation
/// within the drawing canvas. It demonstrates how tools can be used
/// for non-drawing purposes.
class PanZoomDrawingTool implements IDrawingTool {
  PanZoomDrawingTool({
    this.enablePan = true,
    this.enableZoom = true,
    this.minScale = 0.1,
    this.maxScale = 5.0,
  });

  final bool enablePan;
  final bool enableZoom;
  final double minScale;
  final double maxScale;

  @override
  DrawToolType get toolType => DrawToolType.panZoom;

  @override
  bool get supportsPanZoom => true;

  @override
  bool get supportsSelection => false;

  @override
  Future<IDrawableObject?> startDrawing({
    required BuildContext context,
    required Offset startPoint,
    required Color color,
    required Matrix4 transform,
    required Size canvasSize,
    Map<String, dynamic>? options,
  }) async {
    // Pan/zoom tool doesn't create drawable objects
    // The actual pan/zoom behavior is handled by the InteractiveViewer
    // in the WindowPaintV2 widget
    return null;
  }

  @override
  bool updateDrawing({
    required IDrawableObject object,
    required Offset currentPoint,
    required Color color,
    required Matrix4 transform,
    required Size canvasSize,
  }) {
    // No drawing to update for pan/zoom tool
    return false;
  }

  @override
  bool endDrawing({
    required IDrawableObject object,
    required Color color,
    required Size canvasSize,
  }) {
    // No object to keep
    return false;
  }

  @override
  IDrawableObject? createFromJson(Map<String, dynamic> json) {
    // Pan/zoom tool doesn't create objects from JSON
    return null;
  }

  /// Gets the tool configuration for serialization
  Map<String, dynamic> getToolConfig() {
    return {
      'toolType': toolType.id,
      'enablePan': enablePan,
      'enableZoom': enableZoom,
      'minScale': minScale,
      'maxScale': maxScale,
    };
  }

  /// Creates a tool instance from configuration
  static PanZoomDrawingTool fromConfig(Map<String, dynamic> config) {
    return PanZoomDrawingTool(
      enablePan: config['enablePan'] as bool? ?? true,
      enableZoom: config['enableZoom'] as bool? ?? true,
      minScale: config['minScale'] as double? ?? 0.1,
      maxScale: config['maxScale'] as double? ?? 5.0,
    );
  }

  /// Checks if the current scale is within bounds
  bool isScaleValid(double scale) {
    return scale >= minScale && scale <= maxScale;
  }

  /// Clamps the scale to valid bounds
  double clampScale(double scale) {
    return scale.clamp(minScale, maxScale);
  }

  /// Calculates the appropriate scale for fitting content
  double calculateFitScale(Size contentSize, Size viewportSize) {
    final scaleX = viewportSize.width / contentSize.width;
    final scaleY = viewportSize.height / contentSize.height;
    final fitScale = scaleX < scaleY ? scaleX : scaleY;
    
    return clampScale(fitScale);
  }

  /// Calculates the center point for a given content size
  Offset calculateCenter(Size contentSize) {
    return Offset(contentSize.width / 2, contentSize.height / 2);
  }

  @override
  String toString() {
    return 'PanZoomDrawingTool('
        'enablePan: $enablePan, '
        'enableZoom: $enableZoom, '
        'minScale: $minScale, '
        'maxScale: $maxScale'
        ')';
  }
}