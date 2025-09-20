import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/widgets.dart';

/// Simple, clean drawing widget for window_paint v2.0
/// 
/// This version focuses on simplicity and ease of use while maintaining
/// the core functionality. Much less boilerplate than the full v2 architecture.
class WindowPaint extends StatefulWidget {
  const WindowPaint({
    super.key,
    this.controller,
    required this.child,
    this.onDrawingAdded,
    this.onDrawingRemoved,
    this.maxScale = 3.0,
    this.minScale = 0.5,
  });

  /// Optional controller for external state management
  final WindowPaintController? controller;

  /// Widget to draw on top of
  final Widget child;

  /// Called when a drawing is completed and added
  final void Function(DrawingObject drawing)? onDrawingAdded;

  /// Called when a drawing is removed
  final void Function(String drawingId)? onDrawingRemoved;

  /// Maximum zoom scale
  final double maxScale;

  /// Minimum zoom scale  
  final double minScale;

  @override
  State<WindowPaint> createState() => _WindowPaintState();
}

class _WindowPaintState extends State<WindowPaint> {
  late WindowPaintController _controller;
  late TransformationController _transformationController;
  bool _ownController = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? WindowPaintController();
    _ownController = widget.controller == null;
    _transformationController = TransformationController();
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (_ownController) _controller.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  void _handlePanStart(ScaleStartDetails details) {
    if (_controller.tool == DrawingTool.pan) return;
    
    _controller._startDrawing(
      details.localFocalPoint,
      _transformationController.value,
      Size.zero, // Will be updated in paint
    );
  }

  void _handlePanUpdate(ScaleUpdateDetails details) {
    if (_controller.tool == DrawingTool.pan) return;
    
    _controller._updateDrawing(
      details.localFocalPoint,
      _transformationController.value,
    );
  }

  void _handlePanEnd(ScaleEndDetails details) {
    if (_controller.tool == DrawingTool.pan) return;
    
    final completed = _controller._endDrawing();
    if (completed != null) {
      widget.onDrawingAdded?.call(completed);
    }
  }

  void _handleTap(TapDownDetails details) {
    _controller._selectAt(details.localPosition);
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _transformationController,
      maxScale: widget.maxScale,
      minScale: widget.minScale,
      panEnabled: _controller.tool == DrawingTool.pan,
      scaleEnabled: _controller.tool == DrawingTool.pan,
      child: GestureDetector(
        onScaleStart: _handlePanStart,
        onScaleUpdate: _handlePanUpdate,
        onScaleEnd: _handlePanEnd,
        onTapDown: _handleTap,
        child: CustomPaint(
          painter: _WindowPainter(_controller),
          child: widget.child,
        ),
      ),
    );
  }
}

/// Simple drawing tools enum - extensible with custom tools
enum DrawingTool {
  pan,
  pencil,
  rectangle,
  circle,
  custom, // For custom registered tools
}

/// Factory function type for creating drawing objects
typedef DrawingFactory = DrawingObject Function({
  required Offset point,
  required int color,
  required double strokeWidth,
});

/// Custom tool definition
class CustomTool {
  const CustomTool({
    required this.id,
    required this.name,
    required this.factory,
  });

  final String id;
  final String name;
  final DrawingFactory factory;
}

/// Helper class to reduce parameter duplication
class _DrawingParams {
  const _DrawingParams({
    required this.point,
    required this.color,
    required this.strokeWidth,
  });

  final Offset point;
  final int color;
  final double strokeWidth;
}

/// Simple controller for managing drawing state
class WindowPaintController extends ChangeNotifier {
  WindowPaintController({
    DrawingTool tool = DrawingTool.pencil,
    Color color = const Color(0xFF000000),
    double strokeWidth = 2.0,
    Map<String, CustomTool>? customTools,
  }) : _tool = tool,
       _color = color,
       _strokeWidth = strokeWidth,
       _customTools = customTools ?? {};

  DrawingTool _tool;
  Color _color;
  double _strokeWidth;
  final List<DrawingObject> _drawings = [];
  String? _selectedId;
  DrawingObject? _currentDrawing;
  Size _canvasSize = Size.zero;
  final Map<String, CustomTool> _customTools;
  String? _activeCustomToolId; // Tracks which custom tool is active

  // Getters
  DrawingTool get tool => _tool;
  Color get color => _color;
  double get strokeWidth => _strokeWidth;
  List<DrawingObject> get drawings => List.unmodifiable(_drawings);
  String? get selectedId => _selectedId;
  DrawingObject? get selectedDrawing => 
      _drawings.where((d) => d.id == _selectedId).firstOrNull;
  Map<String, CustomTool> get customTools => Map.unmodifiable(_customTools);
  String? get activeCustomToolId => _activeCustomToolId;

  // Simple setters
  void setTool(DrawingTool tool) {
    _tool = tool;
    if (tool != DrawingTool.custom) {
      _activeCustomToolId = null; // Clear custom tool when switching to built-in
    }
    _selectedId = null; // Clear selection when changing tools
    notifyListeners();
  }

  /// Register a new custom drawing tool
  void registerCustomTool(CustomTool tool) {
    _customTools[tool.id] = tool;
    notifyListeners();
  }

  /// Unregister a custom drawing tool
  void unregisterCustomTool(String toolId) {
    _customTools.remove(toolId);
    if (_activeCustomToolId == toolId) {
      // Switch back to pencil if current custom tool is removed
      setTool(DrawingTool.pencil);
    }
    notifyListeners();
  }

  /// Set active custom tool by ID
  void setCustomTool(String toolId) {
    if (_customTools.containsKey(toolId)) {
      _tool = DrawingTool.custom;
      _activeCustomToolId = toolId;
      _selectedId = null; // Clear selection when changing tools
      notifyListeners();
    } else {
      throw ArgumentError('Custom tool with ID "$toolId" is not registered');
    }
  }

  /// Get currently active custom tool, if any
  CustomTool? get activeCustomTool => 
      _activeCustomToolId != null ? _customTools[_activeCustomToolId] : null;

  void setColor(Color color) {
    _color = color;
    // Update selected object color if any
    final selected = selectedDrawing;
    if (selected != null) {
      selected.color = color.value;
    }
    notifyListeners();
  }

  void setStrokeWidth(double width) {
    _strokeWidth = width;
    notifyListeners();
  }

  // Drawing operations
  void _startDrawing(Offset point, Matrix4 transform, Size canvasSize) {
    if (_tool == DrawingTool.pan) return;
    
    _canvasSize = canvasSize;
    final normalizedPoint = _normalizePoint(point);
    
    _currentDrawing = _createDrawingForTool(normalizedPoint);
    
    if (_currentDrawing != null) {
      _drawings.add(_currentDrawing!);
      notifyListeners();
    }
  }

  /// Creates a new drawing object based on the current tool
  DrawingObject? _createDrawingForTool(Offset point) {
    final commonParams = _DrawingParams(
      point: point,
      color: _color.value,
      strokeWidth: _strokeWidth,
    );

    switch (_tool) {
      case DrawingTool.pencil:
        return _createPencilDrawing(commonParams);
      case DrawingTool.rectangle:
        return _createRectangleDrawing(commonParams);
      case DrawingTool.circle:
        return _createCircleDrawing(commonParams);
      case DrawingTool.custom:
        return _createCustomDrawing(commonParams);
      case DrawingTool.pan:
        return null;
    }
  }

  /// Creates a custom drawing using the active custom tool
  DrawingObject? _createCustomDrawing(_DrawingParams params) {
    final customTool = activeCustomTool;
    if (customTool == null) return null;
    
    return customTool.factory(
      point: params.point,
      color: params.color,
      strokeWidth: params.strokeWidth,
    );
  }

  /// Creates a new pencil drawing with the given parameters
  PencilDrawing _createPencilDrawing(_DrawingParams params) {
    return PencilDrawing.start(
      point: params.point,
      color: params.color,
      strokeWidth: params.strokeWidth,
    );
  }

  /// Creates a new rectangle drawing with the given parameters
  RectangleDrawing _createRectangleDrawing(_DrawingParams params) {
    return RectangleDrawing.start(
      point: params.point,
      color: params.color,
      strokeWidth: params.strokeWidth,
    );
  }

  /// Creates a new circle drawing with the given parameters
  CircleDrawing _createCircleDrawing(_DrawingParams params) {
    return CircleDrawing.start(
      point: params.point,
      color: params.color,
      strokeWidth: params.strokeWidth,
    );
  }

  void _updateDrawing(Offset point, Matrix4 transform) {
    if (_currentDrawing == null) return;
    
    final normalizedPoint = _normalizePoint(point);
    _currentDrawing!.update(normalizedPoint);
    notifyListeners();
  }

  DrawingObject? _endDrawing() {
    final drawing = _currentDrawing;
    _currentDrawing = null;
    
    if (drawing != null && !drawing.isValid()) {
      _drawings.remove(drawing);
      notifyListeners();
      return null;
    }
    
    return drawing;
  }

  void _selectAt(Offset point) {
    final normalizedPoint = _normalizePoint(point);
    final selectedDrawing = _findDrawingAt(normalizedPoint);
    
    if (selectedDrawing != null) {
      _selectDrawing(selectedDrawing);
    } else {
      _clearSelection();
    }
  }

  DrawingObject? _findDrawingAt(Offset point) {
    // Check drawings in reverse order (top to bottom)
    for (int i = _drawings.length - 1; i >= 0; i--) {
      if (_drawings[i].containsPoint(point)) {
        return _drawings[i];
      }
    }
    return null;
  }

  void _selectDrawing(DrawingObject drawing) {
    _selectedId = drawing.id;
    _color = Color(drawing.color);
    notifyListeners();
  }

  void _clearSelection() {
    _selectedId = null;
    notifyListeners();
  }

  Offset _normalizePoint(Offset point) {
    if (_canvasSize == Size.zero) return point;
    return Offset(
      point.dx / _canvasSize.width,
      point.dy / _canvasSize.height,
    );
  }

  // Public operations
  void deleteSelected() {
    if (_selectedId != null) {
      _drawings.removeWhere((d) => d.id == _selectedId);
      _selectedId = null;
      notifyListeners();
    }
  }

  void clearAll() {
    _drawings.clear();
    _selectedId = null;
    notifyListeners();
  }

  // Serialization
  List<Map<String, dynamic>> toJson() {
    return _drawings.map((d) => d.toJson()).toList();
  }

  void fromJson(List<Map<String, dynamic>> json) {
    _clearDrawings();
    _loadDrawingsFromJson(json);
    notifyListeners();
  }

  void _clearDrawings() {
    _drawings.clear();
    _selectedId = null;
  }

  void _loadDrawingsFromJson(List<Map<String, dynamic>> json) {
    for (final item in json) {
      final drawing = DrawingObject.fromJson(item);
      if (drawing != null) {
        _drawings.add(drawing);
      }
    }
  }
}

/// Base class for all drawing objects
abstract class DrawingObject {
  DrawingObject({
    required this.id,
    required this.type,
    required this.color,
    required this.strokeWidth,
  });

  final String id;
  final String type;
  int color;
  final double strokeWidth;

  void update(Offset point);
  void paint(Canvas canvas, Size size);
  bool containsPoint(Offset point);
  bool isValid();
  Map<String, dynamic> toJson();

  static DrawingObject? fromJson(Map<String, dynamic> json) {
    try {
      final type = json['type'] as String;
      return _createDrawingFromType(type, json);
    } catch (e) {
      return null;
    }
  }

  static DrawingObject? _createDrawingFromType(String type, Map<String, dynamic> json) {
    switch (type) {
      case 'pencil':
        return PencilDrawing.fromJson(json);
      case 'rectangle':
        return RectangleDrawing.fromJson(json);
      case 'circle':
        return CircleDrawing.fromJson(json);
      case 'line':
        return LineDrawing.fromJson(json);
      case 'arrow':
        return ArrowDrawing.fromJson(json);
      default:
        return null;
    }
  }
}

/// Pencil/freehand drawing
class PencilDrawing extends DrawingObject {
  PencilDrawing({
    required super.id,
    required super.color,
    required super.strokeWidth,
    required this.points,
  }) : super(type: 'pencil');

  final List<Offset> points;

  factory PencilDrawing.start({
    required Offset point,
    required int color,
    required double strokeWidth,
  }) {
    return PencilDrawing(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      color: color,
      strokeWidth: strokeWidth,
      points: [point],
    );
  }

  @override
  void update(Offset point) {
    points.add(point);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final paint = _createPaint();
    _drawLineSegments(canvas, size, paint);
  }

  Paint _createPaint() {
    return Paint()
      ..color = Color(color)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
  }

  void _drawLineSegments(Canvas canvas, Size size, Paint paint) {
    for (int i = 0; i < points.length - 1; i++) {
      final from = _denormalizePoint(points[i], size);
      final to = _denormalizePoint(points[i + 1], size);
      canvas.drawLine(from, to, paint);
    }
  }

  Offset _denormalizePoint(Offset point, Size size) {
    return Offset(
      point.dx * size.width,
      point.dy * size.height,
    );
  }

  @override
  bool containsPoint(Offset point) {
    const threshold = 0.02; // 2% of screen
    return points.any((p) => (p - point).distance < threshold);
  }

  @override
  bool isValid() => points.length >= 2;

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'color': color,
    'strokeWidth': strokeWidth,
    'points': points.map((p) => {'x': p.dx, 'y': p.dy}).toList(),
  };

  static PencilDrawing fromJson(Map<String, dynamic> json) {
    final pointsData = json['points'] as List;
    final points = pointsData.map((p) => Offset(p['x'], p['y'])).toList();
    
    return PencilDrawing(
      id: json['id'],
      color: json['color'],
      strokeWidth: json['strokeWidth'],
      points: points,
    );
  }
}

/// Rectangle drawing
class RectangleDrawing extends DrawingObject {
  RectangleDrawing({
    required super.id,
    required super.color,
    required super.strokeWidth,
    required this.startPoint,
    required this.endPoint,
  }) : super(type: 'rectangle');

  final Offset startPoint;
  Offset endPoint;

  factory RectangleDrawing.start({
    required Offset point,
    required int color,
    required double strokeWidth,
  }) {
    return RectangleDrawing(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      color: color,
      strokeWidth: strokeWidth,
      startPoint: point,
      endPoint: point,
    );
  }

  @override
  void update(Offset point) {
    endPoint = point;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = _createPaint();
    final rect = _calculateRect(size);
    canvas.drawRect(rect, paint);
  }

  Paint _createPaint() {
    return Paint()
      ..color = Color(color)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
  }

  Rect _calculateRect(Size size) {
    return Rect.fromPoints(
      _denormalizePoint(startPoint, size),
      _denormalizePoint(endPoint, size),
    );
  }

  Offset _denormalizePoint(Offset point, Size size) {
    return Offset(
      point.dx * size.width,
      point.dy * size.height,
    );
  }

  @override
  bool containsPoint(Offset point) {
    final rect = Rect.fromPoints(startPoint, endPoint);
    const threshold = 0.02;
    return rect.inflate(threshold).contains(point) && 
           !rect.deflate(threshold).contains(point);
  }

  @override
  bool isValid() {
    const minSize = 0.01; // 1% of screen
    return (startPoint - endPoint).distance > minSize;
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'color': color,
    'strokeWidth': strokeWidth,
    'startPoint': {'x': startPoint.dx, 'y': startPoint.dy},
    'endPoint': {'x': endPoint.dx, 'y': endPoint.dy},
  };

  static RectangleDrawing fromJson(Map<String, dynamic> json) {
    final start = json['startPoint'];
    final end = json['endPoint'];
    
    return RectangleDrawing(
      id: json['id'],
      color: json['color'],
      strokeWidth: json['strokeWidth'],
      startPoint: Offset(start['x'], start['y']),
      endPoint: Offset(end['x'], end['y']),
    );
  }
}

/// Circle drawing
class CircleDrawing extends DrawingObject {
  CircleDrawing({
    required super.id,
    required super.color,
    required super.strokeWidth,
    required this.center,
    required this.radius,
  }) : super(type: 'circle');

  final Offset center;
  double radius;

  factory CircleDrawing.start({
    required Offset point,
    required int color,
    required double strokeWidth,
  }) {
    return CircleDrawing(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      color: color,
      strokeWidth: strokeWidth,
      center: point,
      radius: 0,
    );
  }

  @override
  void update(Offset point) {
    radius = (center - point).distance;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = _createPaint();
    final centerPx = _denormalizePoint(center, size);
    final radiusPx = _calculateRadius(size);
    
    canvas.drawCircle(centerPx, radiusPx, paint);
  }

  Paint _createPaint() {
    return Paint()
      ..color = Color(color)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
  }

  Offset _denormalizePoint(Offset point, Size size) {
    return Offset(
      point.dx * size.width,
      point.dy * size.height,
    );
  }

  double _calculateRadius(Size size) {
    return radius * size.shortestSide;
  }

  @override
  bool containsPoint(Offset point) {
    final distance = (center - point).distance;
    const threshold = 0.02;
    return (distance - radius).abs() < threshold;
  }

  @override
  bool isValid() {
    const minRadius = 0.01; // 1% of screen
    return radius > minRadius;
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'color': color,
    'strokeWidth': strokeWidth,
    'center': {'x': center.dx, 'y': center.dy},
    'radius': radius,
  };

  static CircleDrawing fromJson(Map<String, dynamic> json) {
    final centerData = json['center'];
    
    return CircleDrawing(
      id: json['id'],
      color: json['color'],
      strokeWidth: json['strokeWidth'],
      center: Offset(centerData['x'], centerData['y']),
      radius: json['radius'],
    );
  }
}

/// Custom painter for rendering drawings
class _WindowPainter extends CustomPainter {
  const _WindowPainter(this.controller);

  final WindowPaintController controller;

  @override
  void paint(Canvas canvas, Size size) {
    // Update canvas size in controller
    controller._canvasSize = size;

    // Draw all objects
    for (final drawing in controller.drawings) {
      drawing.paint(canvas, size);
    }

    // Draw selection outline for selected object
    final selected = controller.selectedDrawing;
    if (selected != null) {
      _paintSelection(canvas, size, selected);
    }
  }

  void _paintSelection(Canvas canvas, Size size, DrawingObject drawing) {
    final paint = _createSelectionPaint();

    if (drawing is PencilDrawing) {
      _paintPencilSelection(canvas, size, drawing, paint);
    } else if (drawing is RectangleDrawing) {
      _paintRectangleSelection(canvas, size, drawing, paint);
    } else if (drawing is CircleDrawing) {
      _paintCircleSelection(canvas, size, drawing, paint);
    }
  }

  Paint _createSelectionPaint() {
    return Paint()
      ..color = const Color(0x80000000)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
  }

  void _paintPencilSelection(Canvas canvas, Size size, PencilDrawing drawing, Paint paint) {
    final bounds = _getBounds(drawing.points, size);
    canvas.drawRect(bounds.inflate(5), paint);
  }

  void _paintRectangleSelection(Canvas canvas, Size size, RectangleDrawing drawing, Paint paint) {
    final rect = _denormalizeRect(drawing.startPoint, drawing.endPoint, size);
    canvas.drawRect(rect.inflate(5), paint);
  }

  void _paintCircleSelection(Canvas canvas, Size size, CircleDrawing drawing, Paint paint) {
    final center = _denormalizePoint(drawing.center, size);
    final radius = drawing.radius * size.shortestSide + 5;
    canvas.drawCircle(center, radius, paint);
  }

  Offset _denormalizePoint(Offset point, Size size) {
    return Offset(
      point.dx * size.width,
      point.dy * size.height,
    );
  }

  Rect _denormalizeRect(Offset start, Offset end, Size size) {
    return Rect.fromPoints(
      _denormalizePoint(start, size),
      _denormalizePoint(end, size),
    );
  }

  Rect _getBounds(List<Offset> points, Size size) {
    if (points.isEmpty) return Rect.zero;
    
    final bounds = _calculateNormalizedBounds(points);
    return _denormalizeRect(bounds.topLeft, bounds.bottomRight, size);
  }

  Rect _calculateNormalizedBounds(List<Offset> points) {
    double minX = points.first.dx, maxX = points.first.dx;
    double minY = points.first.dy, maxY = points.first.dy;
    
    for (final point in points) {
      minX = _min(minX, point.dx);
      maxX = _max(maxX, point.dx);
      minY = _min(minY, point.dy);
      maxY = _max(maxY, point.dy);
    }
    
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }

  double _min(double a, double b) => a < b ? a : b;
  double _max(double a, double b) => a > b ? a : b;

  @override
  bool shouldRepaint(_WindowPainter oldDelegate) {
    return controller != oldDelegate.controller;
  }
}

/// Example custom drawing tools to demonstrate extensibility

/// Example: Line drawing tool
class LineDrawing extends DrawingObject {
  LineDrawing({
    required super.id,
    required super.color,
    required super.strokeWidth,
    required this.startPoint,
    required this.endPoint,
  }) : super(type: 'line');

  final Offset startPoint;
  Offset endPoint;

  factory LineDrawing.start({
    required Offset point,
    required int color,
    required double strokeWidth,
  }) {
    return LineDrawing(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      color: color,
      strokeWidth: strokeWidth,
      startPoint: point,
      endPoint: point,
    );
  }

  @override
  void update(Offset point) {
    endPoint = point;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(color)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final start = Offset(
      startPoint.dx * size.width,
      startPoint.dy * size.height,
    );
    final end = Offset(
      endPoint.dx * size.width,
      endPoint.dy * size.height,
    );

    canvas.drawLine(start, end, paint);
  }

  @override
  bool containsPoint(Offset point) {
    // Simple distance-to-line calculation
    const threshold = 0.02;
    final d = _distanceToLine(point, startPoint, endPoint);
    return d < threshold;
  }

  double _distanceToLine(Offset point, Offset lineStart, Offset lineEnd) {
    final dx = lineEnd.dx - lineStart.dx;
    final dy = lineEnd.dy - lineStart.dy;
    final length = (dx * dx + dy * dy);
    
    if (length == 0) return (point - lineStart).distance;
    
    final t = ((point.dx - lineStart.dx) * dx + (point.dy - lineStart.dy) * dy) / length;
    final projection = Offset(
      lineStart.dx + t * dx,
      lineStart.dy + t * dy,
    );
    
    return (point - projection).distance;
  }

  @override
  bool isValid() {
    const minLength = 0.01;
    return (startPoint - endPoint).distance > minLength;
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'color': color,
    'strokeWidth': strokeWidth,
    'startPoint': {'x': startPoint.dx, 'y': startPoint.dy},
    'endPoint': {'x': endPoint.dx, 'y': endPoint.dy},
  };

  static LineDrawing fromJson(Map<String, dynamic> json) {
    final start = json['startPoint'];
    final end = json['endPoint'];
    
    return LineDrawing(
      id: json['id'],
      color: json['color'],
      strokeWidth: json['strokeWidth'],
      startPoint: Offset(start['x'], start['y']),
      endPoint: Offset(end['x'], end['y']),
    );
  }
}

/// Example: Arrow drawing tool
class ArrowDrawing extends DrawingObject {
  ArrowDrawing({
    required super.id,
    required super.color,
    required super.strokeWidth,
    required this.startPoint,
    required this.endPoint,
  }) : super(type: 'arrow');

  final Offset startPoint;
  Offset endPoint;

  factory ArrowDrawing.start({
    required Offset point,
    required int color,
    required double strokeWidth,
  }) {
    return ArrowDrawing(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      color: color,
      strokeWidth: strokeWidth,
      startPoint: point,
      endPoint: point,
    );
  }

  @override
  void update(Offset point) {
    endPoint = point;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(color)
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final start = Offset(
      startPoint.dx * size.width,
      startPoint.dy * size.height,
    );
    final end = Offset(
      endPoint.dx * size.width,
      endPoint.dy * size.height,
    );

    // Draw main line
    canvas.drawLine(start, end, paint);

    // Draw arrowhead
    _drawArrowhead(canvas, start, end, paint);
  }

  void _drawArrowhead(Canvas canvas, Offset start, Offset end, Paint paint) {
    final direction = (end - start);
    if (direction.distance < 10) return; // Too short for arrowhead
    
    final angle = direction.direction;
    final headLength = strokeWidth * 8;
    const headAngle = 0.5; // radians
    
    final head1 = end + Offset(
      headLength * math.cos(angle + math.pi - headAngle),
      headLength * math.sin(angle + math.pi - headAngle),
    );
    final head2 = end + Offset(
      headLength * math.cos(angle + math.pi + headAngle),
      headLength * math.sin(angle + math.pi + headAngle),
    );
    
    canvas.drawLine(end, head1, paint);
    canvas.drawLine(end, head2, paint);
  }

  @override
  bool containsPoint(Offset point) {
    const threshold = 0.02;
    final d = _distanceToLine(point, startPoint, endPoint);
    return d < threshold;
  }

  double _distanceToLine(Offset point, Offset lineStart, Offset lineEnd) {
    final dx = lineEnd.dx - lineStart.dx;
    final dy = lineEnd.dy - lineStart.dy;
    final length = (dx * dx + dy * dy);
    
    if (length == 0) return (point - lineStart).distance;
    
    final t = ((point.dx - lineStart.dx) * dx + (point.dy - lineStart.dy) * dy) / length;
    final projection = Offset(
      lineStart.dx + t * dx,
      lineStart.dy + t * dy,
    );
    
    return (point - projection).distance;
  }

  @override
  bool isValid() {
    const minLength = 0.01;
    return (startPoint - endPoint).distance > minLength;
  }

  @override
  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'color': color,
    'strokeWidth': strokeWidth,
    'startPoint': {'x': startPoint.dx, 'y': startPoint.dy},
    'endPoint': {'x': endPoint.dx, 'y': endPoint.dy},
  };

  static ArrowDrawing fromJson(Map<String, dynamic> json) {
    final start = json['startPoint'];
    final end = json['endPoint'];
    
    return ArrowDrawing(
      id: json['id'],
      color: json['color'],
      strokeWidth: json['strokeWidth'],
      startPoint: Offset(start['x'], start['y']),
      endPoint: Offset(end['x'], end['y']),
    );
  }
}

/// Utility functions for creating common custom tools

/// Creates a line drawing tool
CustomTool createLineTool() {
  return CustomTool(
    id: 'line',
    name: 'Line',
    factory: ({required point, required color, required strokeWidth}) {
      return LineDrawing.start(
        point: point,
        color: color,
        strokeWidth: strokeWidth,
      );
    },
  );
}

/// Creates an arrow drawing tool  
CustomTool createArrowTool() {
  return CustomTool(
    id: 'arrow',
    name: 'Arrow',
    factory: ({required point, required color, required strokeWidth}) {
      return ArrowDrawing.start(
        point: point,
        color: color,
        strokeWidth: strokeWidth,
      );
    },
  );
}