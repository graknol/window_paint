import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:window_paint/src/v2/domain/interfaces/drawable_object.dart';
import 'package:window_paint/src/v2/domain/entities/draw_tool_type.dart';

/// Interface for drawing tool implementations.
/// 
/// This interface defines how drawing tools should behave in the new architecture.
/// It provides better separation between tool logic and rendering.
abstract interface class IDrawingTool {
  /// The type of this drawing tool
  DrawToolType get toolType;
  
  /// Whether this tool supports pan and zoom gestures
  bool get supportsPanZoom;
  
  /// Whether this tool supports object selection
  bool get supportsSelection;
  
  /// Starts a new drawing operation
  /// 
  /// Returns the created object or null if the operation should be discarded.
  /// If a Future is returned, update and end will not be called until it completes.
  Future<IDrawableObject?> startDrawing({
    required BuildContext context,
    required Offset startPoint,
    required Color color,
    required Matrix4 transform,
    required Size canvasSize,
    Map<String, dynamic>? options,
  });
  
  /// Updates an ongoing drawing operation
  /// 
  /// Returns true if the canvas should be repainted.
  bool updateDrawing({
    required IDrawableObject object,
    required Offset currentPoint,
    required Color color,
    required Matrix4 transform,
    required Size canvasSize,
  });
  
  /// Ends a drawing operation
  /// 
  /// Returns true if the object should be kept, false to discard it.
  bool endDrawing({
    required IDrawableObject object,
    required Color color,
    required Size canvasSize,
  });
  
  /// Creates a drawable object from JSON data
  IDrawableObject? createFromJson(Map<String, dynamic> json);
}

/// Interface for tools that support object selection and manipulation
abstract interface class ISelectableTool extends IDrawingTool {
  /// Checks if the given point would select the object
  bool canSelect({
    required IDrawableObject object,
    required Offset point,
    required Matrix4 transform,
    required Size canvasSize,
  });
  
  /// Starts manipulating a selected object
  bool startManipulation({
    required IDrawableObject object,
    required Offset startPoint,
    required Matrix4 transform,
    required Size canvasSize,
  });
  
  /// Updates the manipulation of a selected object
  bool updateManipulation({
    required IDrawableObject object,
    required Offset currentPoint,
    required Matrix4 transform,
    required Size canvasSize,
  });
  
  /// Ends the manipulation of a selected object
  bool endManipulation({
    required IDrawableObject object,
  });
  
  /// Updates the color of a selected object
  void updateColor({
    required IDrawableObject object,
    required Color newColor,
  });
}