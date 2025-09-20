import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:window_paint/src/v2/domain/entities/draw_tool_type.dart';
import 'package:window_paint/src/v2/domain/interfaces/drawable_object.dart';
import 'package:window_paint/src/v2/domain/interfaces/drawing_tool.dart';

/// Simplified controller for managing window paint state.
/// 
/// This controller provides essential functionality with minimal complexity.
class WindowPaintController extends ChangeNotifier {
  WindowPaintController({Map<DrawToolType, IDrawingTool>? tools}) 
    : _tools = tools ?? {};

  final Map<DrawToolType, IDrawingTool> _tools;
  
  // Core state
  DrawToolType _activeTool = DrawToolType.panZoom;
  Color _activeColor = const Color(0xFF000000);
  double _strokeWidth = 2.0;
  Size _canvasSize = Size.zero;
  
  // Drawing objects
  final List<IDrawableObject> _objects = [];
  String? _selectedObjectId;
  
  // Drawing state
  bool _isDrawing = false;
  IDrawableObject? _currentDrawingObject;
  
  // Callbacks
  void Function(IDrawableObject object)? onObjectAdded;
  void Function(IDrawableObject object)? onObjectRemoved;

  // Getters
  DrawToolType get activeTool => _activeTool;
  Color get activeColor => _activeColor;
  List<IDrawableObject> get objects => List.unmodifiable(_objects);
  String? get selectedObjectId => _selectedObjectId;
  bool get isDrawing => _isDrawing;
  double get strokeWidth => _strokeWidth;
  Size get canvasSize => _canvasSize;
  
  IDrawableObject? get selectedObject {
    if (_selectedObjectId == null) return null;
    try {
      return _objects.firstWhere((obj) => obj.id == _selectedObjectId);
    } catch (e) {
      return null;
    }
  }

  /// Registers a drawing tool for the given type
  void registerTool(DrawToolType type, IDrawingTool tool) {
    _tools[type] = tool;
  }

  /// Changes the active drawing tool
  void setActiveTool(DrawToolType tool) {
    if (_isDrawing) return; // Don't change tools while drawing
    
    _activeTool = tool;
    _selectedObjectId = null; // Clear selection when changing tools
    notifyListeners();
  }

  /// Changes the active color
  void setActiveColor(Color color) {
    _activeColor = color;
    notifyListeners();
  }

  /// Changes the stroke width
  void setStrokeWidth(double width) {
    _strokeWidth = width;
    notifyListeners();
  }

  /// Updates the canvas size
  void setCanvasSize(Size size) {
    _canvasSize = size;
    notifyListeners();
  }

  /// Starts a drawing operation
  Future<void> startDrawing({
    required BuildContext context,
    required Offset point,
    required Matrix4 transform,
  }) async {
    if (_isDrawing) return;

    final tool = _tools[_activeTool];
    if (tool == null) return;

    _isDrawing = true;
    notifyListeners();

    try {
      final result = await tool.startDrawing(
        context: context,
        startPoint: point,
        color: _activeColor,
        transform: transform,
        canvasSize: _canvasSize,
        options: {'strokeWidth': _strokeWidth},
      );

      if (result != null) {
        _currentDrawingObject = result;
        _objects.add(result);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error starting drawing: $e');
      _isDrawing = false;
      notifyListeners();
    }
  }

  /// Updates an ongoing drawing operation
  void updateDrawing({
    required Offset point,
    required Matrix4 transform,
  }) {
    if (!_isDrawing || _currentDrawingObject == null) return;

    final tool = _tools[_activeTool];
    if (tool == null) return;

    final shouldRepaint = tool.updateDrawing(
      object: _currentDrawingObject!,
      currentPoint: point,
      color: _activeColor,
      transform: transform,
      canvasSize: _canvasSize,
    );

    if (shouldRepaint) {
      notifyListeners();
    }
  }

  /// Ends a drawing operation
  void endDrawing() {
    if (!_isDrawing || _currentDrawingObject == null) return;

    final tool = _tools[_activeTool];
    if (tool == null) {
      _isDrawing = false;
      notifyListeners();
      return;
    }

    final shouldKeep = tool.endDrawing(
      object: _currentDrawingObject!,
      color: _activeColor,
      canvasSize: _canvasSize,
    );

    if (shouldKeep) {
      onObjectAdded?.call(_currentDrawingObject!);
    } else {
      _objects.removeWhere((obj) => obj.id == _currentDrawingObject!.id);
    }

    _currentDrawingObject = null;
    _isDrawing = false;
    notifyListeners();
  }

  /// Cancels an ongoing drawing operation
  void cancelDrawing() {
    if (!_isDrawing || _currentDrawingObject == null) return;

    _objects.removeWhere((obj) => obj.id == _currentDrawingObject!.id);
    _currentDrawingObject = null;
    _isDrawing = false;
    notifyListeners();
  }

  /// Attempts to select an object at the given point
  bool selectObjectAt({
    required Offset point,
    required Matrix4 transform,
  }) {
    // Check objects in reverse order (topmost first)
    for (int i = _objects.length - 1; i >= 0; i--) {
      final object = _objects[i];
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
          canvasSize: _canvasSize,
        )) {
          _selectedObjectId = object.id;
          _activeColor = object.primaryColor;
          notifyListeners();
          return true;
        }
      }
    }

    // No object selected, clear selection
    _selectedObjectId = null;
    notifyListeners();
    return false;
  }

  /// Clears the current selection
  void clearSelection() {
    _selectedObjectId = null;
    notifyListeners();
  }

  /// Deletes the currently selected object
  void deleteSelectedObject() {
    final selected = selectedObject;
    if (selected == null) return;

    _objects.removeWhere((obj) => obj.id == selected.id);
    _selectedObjectId = null;
    onObjectRemoved?.call(selected);
    notifyListeners();
  }

  /// Adds an object programmatically
  void addObject(IDrawableObject object) {
    _objects.add(object);
    onObjectAdded?.call(object);
    notifyListeners();
  }

  /// Removes an object programmatically
  void removeObject(IDrawableObject object) {
    _objects.removeWhere((obj) => obj.id == object.id);
    if (_selectedObjectId == object.id) {
      _selectedObjectId = null;
    }
    onObjectRemoved?.call(object);
    notifyListeners();
  }

  /// Clears all objects
  void clearAllObjects() {
    for (final object in _objects) {
      onObjectRemoved?.call(object);
    }
    
    _objects.clear();
    _selectedObjectId = null;
    notifyListeners();
  }

  /// Loads objects from JSON data
  void loadFromJson(List<Map<String, dynamic>> jsonData) {
    _objects.clear();
    
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
            _objects.add(object);
          }
        }
      } catch (e) {
        debugPrint('Error loading object from JSON: $e');
      }
    }
    
    _selectedObjectId = null;
    notifyListeners();
  }

  /// Exports all objects to JSON format
  List<Map<String, dynamic>> exportToJson() {
    return _objects.map((obj) => obj.toJson()).toList();
  }

  @override
  void dispose() {
    _currentDrawingObject = null;
    super.dispose();
  }
}