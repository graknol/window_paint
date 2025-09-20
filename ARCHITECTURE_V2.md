# Window Paint v2.0 Architecture Guide

This document explains the architecture of window_paint v2.0, which represents a complete rewrite following Flutter best practices.

## Overview

Window Paint v2.0 introduces a clean architecture with proper separation of concerns, type safety, and enhanced extensibility. The library is designed to be maintainable, testable, and easy to extend with new drawing tools.

## Architecture Layers

### 1. Domain Layer (`lib/src/v2/domain/`)

The domain layer contains the core business logic and entities.

#### Entities
- **`DrawToolType`**: Type-safe enum for drawing tool types
- **`PencilDrawableObject`**: Concrete implementation of drawable objects

#### Interfaces
- **`IDrawableObject`**: Contract for all drawable objects
- **`IDrawingTool`**: Contract for drawing tool implementations
- **`ISelectableTool`**: Extended contract for tools that support selection

### 2. Data Layer (`lib/src/v2/data/`)

The data layer handles serialization and data models.

#### Models
- **`DrawPointData`**: Immutable data model for drawing points
- **`DrawableObjectData`**: Base class for serializable object data
- **`PencilObjectData`**: Specific data model for pencil objects
- **`RectangleObjectData`**: Specific data model for rectangle objects
- **`TextObjectData`**: Specific data model for text objects

### 3. Presentation Layer (`lib/src/v2/presentation/`)

The presentation layer handles UI state management and widgets.

#### State Management
- **`WindowPaintState`**: Immutable state class
- **`WindowPaintController`**: State controller with command pattern
- **`WindowPaintCommand`**: Base class for undo/redo commands

#### Widgets
- **`WindowPaintV2`**: Main drawing widget

### 4. Tools Layer (`lib/src/v2/tools/`)

Contains implementations of drawing tools.

- **`PencilDrawingTool`**: Implementation of pencil drawing functionality

## Key Design Principles

### 1. Immutability

All state objects are immutable, following Flutter best practices:

```dart
@immutable
class WindowPaintState {
  const WindowPaintState({
    this.activeTool = DrawToolType.panZoom,
    this.activeColor = const Color(0xFF000000),
    // ...
  });
  
  WindowPaintState copyWith({
    DrawToolType? activeTool,
    Color? activeColor,
    // ...
  }) {
    return WindowPaintState(
      activeTool: activeTool ?? this.activeTool,
      // ...
    );
  }
}
```

### 2. Separation of Data and Behavior

Data models are separate from business logic:

```dart
// Data model - pure data, no behavior
class PencilObjectData {
  const PencilObjectData({
    required this.id,
    required this.points,
    // ...
  });
}

// Drawable object - combines data with rendering behavior
class PencilDrawableObject implements IDrawableObject {
  PencilDrawableObject({required this.data});
  
  final PencilObjectData data;
  
  @override
  void render(Canvas canvas, Size size, Offset Function(Offset) denormalize) {
    // Rendering logic here
  }
}
```

### 3. Interface-Based Design

Everything is built around interfaces for maximum flexibility:

```dart
abstract interface class IDrawingTool {
  DrawToolType get toolType;
  
  Future<IDrawableObject?> startDrawing({
    required BuildContext context,
    required Offset startPoint,
    // ...
  });
  
  // More methods...
}
```

### 4. Command Pattern for Undo/Redo

All state changes go through commands:

```dart
abstract class WindowPaintCommand {
  WindowPaintState execute(WindowPaintState state);
  WindowPaintState undo(WindowPaintState state);
  String get description;
}

class AddObjectCommand extends WindowPaintCommand {
  const AddObjectCommand(this.object);
  final IDrawableObject object;
  
  @override
  WindowPaintState execute(WindowPaintState state) {
    return state.copyWith(
      objects: [...state.objects, object],
    );
  }
  
  @override
  WindowPaintState undo(WindowPaintState state) {
    final newObjects = List<IDrawableObject>.from(state.objects);
    newObjects.removeWhere((obj) => obj.id == object.id);
    return state.copyWith(objects: newObjects);
  }
}
```

## Usage Examples

### Basic Usage

```dart
import 'package:window_paint/window_paint_v2.dart';

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  late WindowPaintController _controller;
  
  @override
  void initState() {
    super.initState();
    
    final tools = {
      DrawToolType.pencil: PencilDrawingTool(),
    };
    
    _controller = WindowPaintController(
      initialState: const WindowPaintState(
        activeTool: DrawToolType.pencil,
        activeColor: Colors.red,
      ),
      tools: tools,
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return WindowPaintV2(
      controller: _controller,
      tools: tools,
      child: Container(
        width: 400,
        height: 300,
        color: Colors.white,
      ),
    );
  }
}
```

### Adding Custom Tools

```dart
class CustomDrawingTool implements ISelectableTool {
  @override
  DrawToolType get toolType => DrawToolType.custom; // You'd need to add this
  
  @override
  Future<IDrawableObject?> startDrawing({
    required BuildContext context,
    required Offset startPoint,
    required Color color,
    required Matrix4 transform,
    required Size canvasSize,
    Map<String, dynamic>? options,
  }) async {
    // Your custom drawing logic
    return MyCustomDrawableObject(/* ... */);
  }
  
  // Implement other required methods...
}
```

### JSON Serialization

The v2 architecture provides clean JSON serialization:

```dart
// Export to JSON
final jsonData = controller.exportToJson();

// JSON structure:
[
  {
    "id": "uuid-here",
    "toolType": "pencil",
    "color": 4294901760,
    "strokeWidth": 2.0,
    "points": [
      {
        "x": 0.1,
        "y": 0.2,
        "scale": 1.0,
        "pressure": 1.0,
        "timestamp": "2023-01-01T12:00:00.000Z"
      }
    ],
    "simplified": false,
    "metadata": {}
  }
]

// Import from JSON
controller.loadFromJson(jsonData);
```

## Benefits of v2 Architecture

### 1. Type Safety
- Enum-based tool types instead of strings
- Strongly typed interfaces
- Compile-time error detection

### 2. Extensibility
- Plugin-based tool architecture
- Clean interfaces for custom implementations
- Configurable tool settings

### 3. Maintainability
- Clear separation of concerns
- Single responsibility principle
- Immutable state management

### 4. Testability
- Interface-based design enables easy mocking
- Pure functions for state transformations
- Isolated components

### 5. Server Compatibility
- Clean JSON schema
- Separate data models for serialization
- Metadata support for future extensions

## Migration from v1

The v2 architecture is designed to coexist with the original v1 implementation. You can gradually migrate by:

1. Import both versions:
   ```dart
   import 'package:window_paint/window_paint.dart'; // v1
   import 'package:window_paint/window_paint_v2.dart'; // v2
   ```

2. Use v2 for new features while keeping existing v1 code

3. Gradually replace v1 usage with v2 implementations

## Future Enhancements

The v2 architecture is designed to support:

- Plugin system for third-party tools
- Advanced gesture recognition
- Real-time collaboration features
- Performance optimizations
- Accessibility improvements
- Animation support

## Conclusion

Window Paint v2.0 represents a significant improvement over the original implementation, providing a solid foundation for modern Flutter applications that need drawing capabilities. The clean architecture ensures the library will be maintainable and extensible for years to come.