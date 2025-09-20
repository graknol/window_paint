import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:window_paint/src/v2/domain/entities/draw_tool_type.dart';
import 'package:window_paint/src/v2/domain/interfaces/drawable_object.dart';

/// Immutable state class for the window paint widget.
/// 
/// This provides a clean, immutable state representation following Flutter best practices.
@immutable
class WindowPaintState {
  const WindowPaintState({
    this.activeTool = DrawToolType.panZoom,
    this.activeColor = const Color(0xFF000000),
    this.objects = const [],
    this.selectedObjectId,
    this.isDrawing = false,
    this.strokeWidth = 2.0,
    this.canvasSize = Size.zero,
    this.transform = const TransformationData(),
    this.undoStack = const [],
    this.redoStack = const [],
  });

  /// Currently active drawing tool
  final DrawToolType activeTool;
  
  /// Current drawing color
  final Color activeColor;
  
  /// List of all drawable objects
  final List<IDrawableObject> objects;
  
  /// ID of the currently selected object (if any)
  final String? selectedObjectId;
  
  /// Whether a drawing operation is currently in progress
  final bool isDrawing;
  
  /// Current stroke width
  final double strokeWidth;
  
  /// Size of the drawing canvas
  final Size canvasSize;
  
  /// Current transformation matrix data
  final TransformationData transform;
  
  /// Undo stack for command pattern
  final List<WindowPaintCommand> undoStack;
  
  /// Redo stack for command pattern
  final List<WindowPaintCommand> redoStack;

  /// Whether there's a selected object
  bool get hasSelection => selectedObjectId != null;
  
  /// The currently selected object (if any)
  IDrawableObject? get selectedObject {
    if (selectedObjectId == null) return null;
    try {
      return objects.firstWhere((obj) => obj.id == selectedObjectId);
    } catch (e) {
      return null;
    }
  }
  
  /// Whether undo is available
  bool get canUndo => undoStack.isNotEmpty;
  
  /// Whether redo is available
  bool get canRedo => redoStack.isNotEmpty;

  /// Creates a copy with modified properties
  WindowPaintState copyWith({
    DrawToolType? activeTool,
    Color? activeColor,
    List<IDrawableObject>? objects,
    String? selectedObjectId,
    bool clearSelection = false,
    bool? isDrawing,
    double? strokeWidth,
    Size? canvasSize,
    TransformationData? transform,
    List<WindowPaintCommand>? undoStack,
    List<WindowPaintCommand>? redoStack,
  }) {
    return WindowPaintState(
      activeTool: activeTool ?? this.activeTool,
      activeColor: activeColor ?? this.activeColor,
      objects: objects ?? this.objects,
      selectedObjectId: clearSelection ? null : (selectedObjectId ?? this.selectedObjectId),
      isDrawing: isDrawing ?? this.isDrawing,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      canvasSize: canvasSize ?? this.canvasSize,
      transform: transform ?? this.transform,
      undoStack: undoStack ?? this.undoStack,
      redoStack: redoStack ?? this.redoStack,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WindowPaintState &&
        other.activeTool == activeTool &&
        other.activeColor == activeColor &&
        listEquals(other.objects, objects) &&
        other.selectedObjectId == selectedObjectId &&
        other.isDrawing == isDrawing &&
        other.strokeWidth == strokeWidth &&
        other.canvasSize == canvasSize &&
        other.transform == transform &&
        listEquals(other.undoStack, undoStack) &&
        listEquals(other.redoStack, redoStack);
  }

  @override
  int get hashCode {
    return Object.hash(
      activeTool,
      activeColor,
      Object.hashAll(objects),
      selectedObjectId,
      isDrawing,
      strokeWidth,
      canvasSize,
      transform,
      Object.hashAll(undoStack),
      Object.hashAll(redoStack),
    );
  }

  @override
  String toString() {
    return 'WindowPaintState('
        'activeTool: $activeTool, '
        'activeColor: $activeColor, '
        'objectCount: ${objects.length}, '
        'selectedObjectId: $selectedObjectId, '
        'isDrawing: $isDrawing, '
        'strokeWidth: $strokeWidth, '
        'canvasSize: $canvasSize, '
        'transform: $transform'
        ')';
  }
}

/// Data class for transformation information
@immutable
class TransformationData {
  const TransformationData({
    this.translation = Offset.zero,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  final Offset translation;
  final double scale;
  final double rotation;

  Matrix4 toMatrix4() {
    return Matrix4.identity()
      ..translate(translation.dx, translation.dy)
      ..scale(scale)
      ..rotateZ(rotation);
  }

  factory TransformationData.fromMatrix4(Matrix4 matrix) {
    // Extract transformation components from matrix
    final translation = Offset(matrix.getTranslation().x, matrix.getTranslation().y);
    final scale = matrix.getMaxScaleOnAxis();
    
    return TransformationData(
      translation: translation,
      scale: scale,
      rotation: 0.0, // Rotation extraction is more complex, skip for now
    );
  }

  TransformationData copyWith({
    Offset? translation,
    double? scale,
    double? rotation,
  }) {
    return TransformationData(
      translation: translation ?? this.translation,
      scale: scale ?? this.scale,
      rotation: rotation ?? this.rotation,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransformationData &&
        other.translation == translation &&
        other.scale == scale &&
        other.rotation == rotation;
  }

  @override
  int get hashCode => Object.hash(translation, scale, rotation);

  @override
  String toString() {
    return 'TransformationData(translation: $translation, scale: $scale, rotation: $rotation)';
  }
}

/// Base class for command pattern implementation
abstract class WindowPaintCommand {
  const WindowPaintCommand();
  
  /// Executes the command
  WindowPaintState execute(WindowPaintState state);
  
  /// Undoes the command
  WindowPaintState undo(WindowPaintState state);
  
  /// Description of the command for debugging
  String get description;
}

/// Command for adding an object
class AddObjectCommand extends WindowPaintCommand {
  const AddObjectCommand(this.object);
  
  final IDrawableObject object;
  
  @override
  WindowPaintState execute(WindowPaintState state) {
    return state.copyWith(
      objects: [...state.objects, object],
      redoStack: [], // Clear redo stack when new command is executed
    );
  }
  
  @override
  WindowPaintState undo(WindowPaintState state) {
    final newObjects = List<IDrawableObject>.from(state.objects);
    newObjects.removeWhere((obj) => obj.id == object.id);
    return state.copyWith(objects: newObjects);
  }
  
  @override
  String get description => 'Add ${object.toolType} object';
}

/// Command for removing an object
class RemoveObjectCommand extends WindowPaintCommand {
  const RemoveObjectCommand(this.object);
  
  final IDrawableObject object;
  
  @override
  WindowPaintState execute(WindowPaintState state) {
    final newObjects = List<IDrawableObject>.from(state.objects);
    newObjects.removeWhere((obj) => obj.id == object.id);
    return state.copyWith(
      objects: newObjects,
      selectedObjectId: state.selectedObjectId == object.id ? null : state.selectedObjectId,
      redoStack: [],
    );
  }
  
  @override
  WindowPaintState undo(WindowPaintState state) {
    return state.copyWith(
      objects: [...state.objects, object],
    );
  }
  
  @override
  String get description => 'Remove ${object.toolType} object';
}

/// Command for modifying an object
class ModifyObjectCommand extends WindowPaintCommand {
  const ModifyObjectCommand(this.oldObject, this.newObject);
  
  final IDrawableObject oldObject;
  final IDrawableObject newObject;
  
  @override
  WindowPaintState execute(WindowPaintState state) {
    final newObjects = List<IDrawableObject>.from(state.objects);
    final index = newObjects.indexWhere((obj) => obj.id == oldObject.id);
    if (index != -1) {
      newObjects[index] = newObject;
    }
    return state.copyWith(
      objects: newObjects,
      redoStack: [],
    );
  }
  
  @override
  WindowPaintState undo(WindowPaintState state) {
    final newObjects = List<IDrawableObject>.from(state.objects);
    final index = newObjects.indexWhere((obj) => obj.id == newObject.id);
    if (index != -1) {
      newObjects[index] = oldObject;
    }
    return state.copyWith(objects: newObjects);
  }
  
  @override
  String get description => 'Modify ${oldObject.toolType} object';
}