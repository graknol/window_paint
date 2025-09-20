# Creating Custom Drawing Tools - Window Paint v2.0

This guide explains how to create custom drawing tools using the window_paint v2.0 architecture.

## Overview

The v2.0 architecture makes it easy to add new drawing tools through a clean plugin system. Each tool consists of:

1. **Data Model** - Defines the serializable data structure
2. **Drawable Object** - Implements rendering and interaction behavior
3. **Drawing Tool** - Handles the drawing workflow

## Step-by-Step Guide

### 1. Define Your Tool Type

First, add your tool to the `DrawToolType` enum:

```dart
// In lib/src/v2/domain/entities/draw_tool_type.dart
enum DrawToolType {
  // ... existing tools
  circle('circle'),
  arrow('arrow'),
  text('text');
  
  // ... rest of enum
}
```

### 2. Create the Data Model

Create a data model that extends `DrawableObjectData`:

```dart
// lib/src/v2/data/models/circle_object_data.dart
class CircleObjectData extends DrawableObjectData {
  const CircleObjectData({
    required super.id,
    required super.color,
    required super.strokeWidth,
    required this.center,
    required this.radius,
    this.filled = false,
    super.metadata = const {},
  }) : super(toolType: 'circle');

  final DrawPointData center;
  final double radius;
  final bool filled;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'toolType': toolType,
      'color': color,
      'strokeWidth': strokeWidth,
      'center': center.toJson(),
      'radius': radius,
      'filled': filled,
      'metadata': metadata,
    };
  }

  static CircleObjectData fromJson(Map<String, dynamic> json) {
    return CircleObjectData(
      id: json['id'] as String,
      color: json['color'] as int,
      strokeWidth: (json['strokeWidth'] as num).toDouble(),
      center: DrawPointData.fromJson(json['center'] as Map<String, dynamic>),
      radius: (json['radius'] as num).toDouble(),
      filled: json['filled'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );
  }

  CircleObjectData copyWith({
    String? id,
    int? color,
    double? strokeWidth,
    DrawPointData? center,
    double? radius,
    bool? filled,
    Map<String, dynamic>? metadata,
  }) {
    return CircleObjectData(
      id: id ?? this.id,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      center: center ?? this.center,
      radius: radius ?? this.radius,
      filled: filled ?? this.filled,
      metadata: metadata ?? this.metadata,
    );
  }
}
```

### 3. Create the Drawable Object

Implement the `IDrawableObject` interface:

```dart
// lib/src/v2/domain/entities/circle_drawable_object.dart
class CircleDrawableObject implements IDrawableObject {
  CircleDrawableObject({
    required this.data,
    this.isSelected = false,
    this.isDragging = false,
  });

  final CircleObjectData data;
  bool isSelected;
  bool isDragging;

  @override
  String get id => data.id;

  @override
  String get toolType => data.toolType;

  @override
  Color get primaryColor => data.colorValue;

  @override
  void render(Canvas canvas, Size size, Offset Function(Offset) denormalize) {
    final paint = Paint()
      ..color = primaryColor
      ..strokeWidth = data.strokeWidth
      ..style = data.filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..isAntiAlias = true;

    final center = denormalize(data.center.toOffset());
    final radius = data.radius * size.shortestSide;

    canvas.drawCircle(center, radius, paint);

    if (isSelected) {
      _renderSelectionOutline(canvas, size, denormalize);
    }
  }

  void _renderSelectionOutline(Canvas canvas, Size size, Offset Function(Offset) denormalize) {
    final center = denormalize(data.center.toOffset());
    final radius = data.radius * size.shortestSide;
    
    final selectionPaint = Paint()
      ..color = const Color(0x8A000000)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius + 5, selectionPaint);
  }

  @override
  bool containsPoint(Offset point, Size size) {
    final distance = (point - data.center.toOffset()).distance;
    final threshold = data.radius + (5.0 / size.shortestSide);
    
    if (data.filled) {
      return distance <= data.radius;
    } else {
      return (distance - data.radius).abs() <= threshold;
    }
  }

  @override
  Rect getBounds() {
    final center = data.center.toOffset();
    return Rect.fromCircle(center: center, radius: data.radius);
  }

  @override
  IDrawableObject clone() {
    return CircleDrawableObject(
      data: CircleObjectData(
        id: data.id,
        color: data.color,
        strokeWidth: data.strokeWidth,
        center: DrawPointData(
          x: data.center.x,
          y: data.center.y,
          scale: data.center.scale,
          pressure: data.center.pressure,
          timestamp: data.center.timestamp,
        ),
        radius: data.radius,
        filled: data.filled,
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

  // Add methods for manipulation
  void updateRadius(double newRadius) {
    // Update radius (simplified for demo)
  }

  void updateCenter(Offset newCenter) {
    // Update center (simplified for demo)
  }
}
```

### 4. Create the Drawing Tool

Implement the `ISelectableTool` interface:

```dart
// lib/src/v2/tools/circle_drawing_tool.dart
class CircleDrawingTool implements ISelectableTool {
  CircleDrawingTool({
    this.defaultStrokeWidth = 2.0,
    this.filled = false,
    this.minRadius = 5.0,
  });

  final double defaultStrokeWidth;
  final bool filled;
  final double minRadius;
  
  static const _uuid = Uuid();

  @override
  DrawToolType get toolType => DrawToolType.circle;

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
    
    final centerData = DrawPointData.fromOffset(startPoint, scale);

    final data = CircleObjectData(
      id: _uuid.v4(),
      color: color.value,
      strokeWidth: strokeWidth,
      center: centerData,
      radius: 0.0,
      filled: isFilled,
    );

    return CircleDrawableObject(data: data);
  }

  @override
  bool updateDrawing({
    required IDrawableObject object,
    required Offset currentPoint,
    required Color color,
    required Matrix4 transform,
    required Size canvasSize,
  }) {
    if (object is! CircleDrawableObject) return false;

    final distance = (currentPoint - object.data.center.toOffset()).distance;
    object.updateRadius(distance);
    
    return true;
  }

  @override
  bool endDrawing({
    required IDrawableObject object,
    required Color color,
    required Size canvasSize,
  }) {
    if (object is! CircleDrawableObject) return false;

    // Only keep circles larger than minimum radius
    final pixelRadius = object.data.radius * canvasSize.shortestSide;
    return pixelRadius >= minRadius;
  }

  @override
  bool canSelect({
    required IDrawableObject object,
    required Offset point,
    required Matrix4 transform,
    required Size canvasSize,
  }) {
    if (object is! CircleDrawableObject) return false;
    return object.containsPoint(point, canvasSize);
  }

  @override
  bool startManipulation({
    required IDrawableObject object,
    required Offset startPoint,
    required Matrix4 transform,
    required Size canvasSize,
  }) {
    if (object is! CircleDrawableObject) return false;

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
    if (object is! CircleDrawableObject || !object.isDragging) return false;
    
    // Implement circle manipulation (move, resize)
    return true;
  }

  @override
  bool endManipulation({required IDrawableObject object}) {
    if (object is! CircleDrawableObject) return false;
    object.isDragging = false;
    return true;
  }

  @override
  void updateColor({
    required IDrawableObject object,
    required Color newColor,
  }) {
    // Update circle color
  }

  @override
  IDrawableObject? createFromJson(Map<String, dynamic> json) {
    try {
      final data = CircleObjectData.fromJson(json);
      return CircleDrawableObject(data: data);
    } catch (e) {
      debugPrint('Error creating CircleDrawableObject from JSON: $e');
      return null;
    }
  }
}
```

### 5. Register Your Tool

Add your tool to the available tools:

```dart
// In your widget or controller setup
final tools = {
  DrawToolType.panZoom: PanZoomDrawingTool(),
  DrawToolType.pencil: PencilDrawingTool(),
  DrawToolType.rectangle: RectangleDrawingTool(),
  DrawToolType.circle: CircleDrawingTool(), // Your new tool
};

final controller = WindowPaintController(tools: tools);
```

### 6. Update Exports

Add your new classes to the main export file:

```dart
// In lib/window_paint_v2.dart
export 'src/v2/domain/entities/circle_drawable_object.dart';
export 'src/v2/tools/circle_drawing_tool.dart';
```

## Advanced Features

### Custom Tool Configuration

Make your tools configurable:

```dart
class CircleDrawingTool implements ISelectableTool {
  CircleDrawingTool({
    this.snapToGrid = false,
    this.gridSize = 10.0,
    this.allowNegativeRadius = false,
  });

  final bool snapToGrid;
  final double gridSize;
  final bool allowNegativeRadius;

  // ... implementation
}
```

### Complex Manipulation

Implement sophisticated manipulation modes:

```dart
enum CircleManipulationType {
  move,
  resize,
  none,
}

CircleManipulationType _detectManipulationType(Offset point, CircleDrawableObject object) {
  final distance = (point - object.data.center.toOffset()).distance;
  const handleThreshold = 0.02; // Normalized threshold
  
  if ((distance - object.data.radius).abs() <= handleThreshold) {
    return CircleManipulationType.resize;
  } else if (distance <= object.data.radius) {
    return CircleManipulationType.move;
  }
  
  return CircleManipulationType.none;
}
```

### Validation and Error Handling

Add proper validation:

```dart
@override
bool endDrawing({...}) {
  if (object is! CircleDrawableObject) return false;

  // Validate circle properties
  if (object.data.radius <= 0) return false;
  if (object.data.center.x < 0 || object.data.center.x > 1) return false;
  if (object.data.center.y < 0 || object.data.center.y > 1) return false;

  return true;
}
```

## Best Practices

1. **Immutability**: Keep data models immutable when possible
2. **Error Handling**: Always handle JSON parsing errors gracefully
3. **Performance**: Implement efficient hit detection for complex shapes
4. **User Experience**: Provide visual feedback during manipulation
5. **Testing**: Write unit tests for your data models and tools
6. **Documentation**: Document your tool's behavior and configuration options

## Testing Your Tool

Create unit tests for your tool:

```dart
// test/circle_tool_test.dart
void main() {
  group('CircleDrawingTool', () {
    test('creates valid circle from drawing', () async {
      final tool = CircleDrawingTool();
      final object = await tool.startDrawing(
        context: MockBuildContext(),
        startPoint: Offset(0.5, 0.5),
        color: Colors.red,
        transform: Matrix4.identity(),
        canvasSize: Size(100, 100),
      );

      expect(object, isA<CircleDrawableObject>());
      expect(object!.data.center.toOffset(), equals(Offset(0.5, 0.5)));
    });
  });
}
```

## Conclusion

The v2.0 architecture makes it straightforward to add new drawing tools while maintaining clean separation of concerns. Your custom tools will automatically benefit from:

- Serialization support
- Undo/redo functionality
- Selection and manipulation
- Consistent API
- Type safety

This plugin-based approach ensures that the library remains extensible and maintainable as new requirements emerge.