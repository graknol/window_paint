import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:window_paint/src/v2/domain/entities/draw_tool_type.dart';
import 'package:window_paint/src/v2/domain/interfaces/drawable_object.dart';
import 'package:window_paint/src/v2/domain/interfaces/drawing_tool.dart';
import 'package:window_paint/src/v2/presentation/state/window_paint_state.dart';

/// Controller for managing window paint state using modern Flutter patterns.
/// 
/// This controller follows Flutter best practices with proper state management,
/// command pattern for undo/redo, and clean separation of concerns.
class WindowPaintController extends ValueNotifier<WindowPaintState> {
  WindowPaintController({
    WindowPaintState? initialState,
    Map<DrawToolType, IDrawingTool>? tools,
  }) : _tools = tools ?? {},
       super(initialState ?? const WindowPaintState());

  final Map<DrawToolType, IDrawingTool> _tools;
  
  /// Current drawing operation tracker
  IDrawableObject? _currentDrawingObject;
  
  /// Callbacks for external listeners
  void Function(IDrawableObject object)? onObjectAdded;
  void Function(IDrawableObject oldObject, IDrawableObject newObject)? onObjectModified;
  void Function(IDrawableObject object)? onObjectRemoved;

  // Getters for convenient access to state properties
  DrawToolType get activeTool => value.activeTool;
  Color get activeColor => value.activeColor;
  List<IDrawableObject> get objects => value.objects;
  String? get selectedObjectId => value.selectedObjectId;
  IDrawableObject? get selectedObject => value.selectedObject;
  bool get isDrawing => value.isDrawing;
  double get strokeWidth => value.strokeWidth;
  Size get canvasSize => value.canvasSize;
  TransformationData get transform => value.transform;
  bool get canUndo => value.canUndo;
  bool get canRedo => value.canRedo;

  /// Registers a drawing tool for the given type
  void registerTool(DrawToolType type, IDrawingTool tool) {
    _tools[type] = tool;
  }

  /// Changes the active drawing tool
  void setActiveTool(DrawToolType tool) {
    if (isDrawing) return; // Don't change tools while drawing
    
    value = value.copyWith(
      activeTool: tool,
      clearSelection: true, // Clear selection when changing tools
    );
  }

  /// Changes the active color
  void setActiveColor(Color color) {
    // If an object is selected, update its color
    if (selectedObject != null) {
      final toolType = DrawToolType.values.firstWhere(
        (type) => type.toString().split('.').last == selectedObject!.toolType,
        orElse: () => DrawToolType.pencil,
      );
      final tool = _tools[toolType];
      if (tool is ISelectableTool) {
        tool.updateColor(object: selectedObject!, newColor: color);
        notifyListeners(); // Trigger repaint
      }
    }
    
    value = value.copyWith(activeColor: color);
  }

  /// Changes the stroke width
  void setStrokeWidth(double width) {
    value = value.copyWith(strokeWidth: width);
  }

  /// Updates the canvas size
  void setCanvasSize(Size size) {
    value = value.copyWith(canvasSize: size);
  }

  /// Updates the transformation data
  void setTransform(TransformationData transform) {
    value = value.copyWith(transform: transform);
  }

  /// Starts a drawing operation
  Future<void> startDrawing({
    required BuildContext context,
    required Offset point,
    required Matrix4 transform,
  }) async {
    if (isDrawing) return;

    final tool = _tools[activeTool];
    if (tool == null) return;

    value = value.copyWith(isDrawing: true);

    try {
      final result = await tool.startDrawing(
        context: context,
        startPoint: point,
        color: activeColor,
        transform: transform,
        canvasSize: canvasSize,
        options: {'strokeWidth': strokeWidth},
      );

      if (result != null) {
        _currentDrawingObject = result;
        // Add the object immediately for live preview
        value = value.copyWith(
          objects: [...objects, result],
        );
      }
    } catch (e) {
      debugPrint('Error starting drawing: $e');
      value = value.copyWith(isDrawing: false);
    }
  }

  /// Updates an ongoing drawing operation
  void updateDrawing({
    required Offset point,
    required Matrix4 transform,
  }) {
    if (!isDrawing || _currentDrawingObject == null) return;

    final tool = _tools[activeTool];
    if (tool == null) return;

    final shouldRepaint = tool.updateDrawing(
      object: _currentDrawingObject!,
      currentPoint: point,
      color: activeColor,
      transform: transform,
      canvasSize: canvasSize,
    );

    if (shouldRepaint) {
      notifyListeners();
    }
  }

  /// Ends a drawing operation
  void endDrawing() {
    if (!isDrawing || _currentDrawingObject == null) return;

    final tool = _tools[activeTool];
    if (tool == null) {
      value = value.copyWith(isDrawing: false);
      return;
    }

    final shouldKeep = tool.endDrawing(
      object: _currentDrawingObject!,
      color: activeColor,
      canvasSize: canvasSize,
    );

    if (shouldKeep) {
      // Execute add command for undo/redo functionality
      _executeCommand(AddObjectCommand(_currentDrawingObject!));
      onObjectAdded?.call(_currentDrawingObject!);
    } else {
      // Remove the object if it shouldn't be kept
      final newObjects = List<IDrawableObject>.from(objects);
      newObjects.removeWhere((obj) => obj.id == _currentDrawingObject!.id);
      value = value.copyWith(objects: newObjects);
    }

    _currentDrawingObject = null;
    value = value.copyWith(isDrawing: false);
  }

  /// Cancels an ongoing drawing operation
  void cancelDrawing() {
    if (!isDrawing || _currentDrawingObject == null) return;

    // Remove the current drawing object
    final newObjects = List<IDrawableObject>.from(objects);
    newObjects.removeWhere((obj) => obj.id == _currentDrawingObject!.id);
    
    _currentDrawingObject = null;
    value = value.copyWith(
      isDrawing: false,
      objects: newObjects,
    );
  }

  /// Attempts to select an object at the given point
  bool selectObjectAt({
    required Offset point,
    required Matrix4 transform,
  }) {
    // Check objects in reverse order (topmost first)
    for (int i = objects.length - 1; i >= 0; i--) {
      final object = objects[i];
      final toolType = DrawToolType.values.firstWhere(
        (type) => type.toString().split('.').last == object.toolType,
        orElse: () => DrawToolType.pencil,
      );
      final tool = _tools[toolType];
      
      if (tool is ISelectableTool) {
        if (tool.canSelect(
          object: object,
          point: point,
          transform: transform,
          canvasSize: canvasSize,
        )) {
          value = value.copyWith(
            selectedObjectId: object.id,
            activeColor: object.primaryColor,
          );
          return true;
        }
      }
    }

    // No object selected, clear selection
    value = value.copyWith(clearSelection: true);
    return false;
  }

  /// Clears the current selection
  void clearSelection() {
    value = value.copyWith(clearSelection: true);
  }

  /// Deletes the currently selected object
  void deleteSelectedObject() {
    final selected = selectedObject;
    if (selected == null) return;

    _executeCommand(RemoveObjectCommand(selected));
    onObjectRemoved?.call(selected);
  }

  /// Adds an object programmatically
  void addObject(IDrawableObject object) {
    _executeCommand(AddObjectCommand(object));
    onObjectAdded?.call(object);
  }

  /// Removes an object programmatically
  void removeObject(IDrawableObject object) {
    _executeCommand(RemoveObjectCommand(object));
    onObjectRemoved?.call(object);
  }

  /// Clears all objects
  void clearAllObjects() {
    for (final object in objects) {
      onObjectRemoved?.call(object);
    }
    
    value = value.copyWith(
      objects: [],
      clearSelection: true,
    );
  }

  /// Executes a command and adds it to the undo stack
  void _executeCommand(WindowPaintCommand command) {
    final newState = command.execute(value);
    final newUndoStack = [...value.undoStack, command];
    
    // Limit undo stack size to prevent memory issues
    if (newUndoStack.length > 100) {
      newUndoStack.removeAt(0);
    }
    
    value = newState.copyWith(undoStack: newUndoStack);
  }

  /// Undoes the last command
  void undo() {
    if (!canUndo) return;

    final command = value.undoStack.last;
    final newUndoStack = List<WindowPaintCommand>.from(value.undoStack)..removeLast();
    final newRedoStack = [...value.redoStack, command];
    
    final newState = command.undo(value);
    value = newState.copyWith(
      undoStack: newUndoStack,
      redoStack: newRedoStack,
    );
  }

  /// Redoes the last undone command
  void redo() {
    if (!canRedo) return;

    final command = value.redoStack.last;
    final newRedoStack = List<WindowPaintCommand>.from(value.redoStack)..removeLast();
    final newUndoStack = [...value.undoStack, command];
    
    final newState = command.execute(value);
    value = newState.copyWith(
      undoStack: newUndoStack,
      redoStack: newRedoStack,
    );
  }

  /// Loads objects from JSON data
  void loadFromJson(List<Map<String, dynamic>> jsonData) {
    final loadedObjects = <IDrawableObject>[];
    
    for (final json in jsonData) {
      try {
        final toolTypeStr = json['toolType'] as String?;
        if (toolTypeStr != null) {
          final toolType = DrawToolType.values.firstWhere(
            (type) => type.toString().split('.').last == toolTypeStr,
            orElse: () => DrawToolType.pencil,
          );
          final tool = _tools[toolType];
          final object = tool?.createFromJson(json);
          if (object != null) {
            loadedObjects.add(object);
          }
        }
      } catch (e) {
        debugPrint('Error loading object from JSON: $e');
      }
    }
    
    value = value.copyWith(
      objects: loadedObjects,
      clearSelection: true,
    );
  }

  /// Exports all objects to JSON format
  List<Map<String, dynamic>> exportToJson() {
    return objects.map((obj) => obj.toJson()).toList();
  }

  @override
  void dispose() {
    _currentDrawingObject = null;
    super.dispose();
  }
}