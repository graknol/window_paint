# Window Paint - Drawing Widget for Flutter

A powerful, extensible drawing widget for Flutter that lets you pan, zoom and paint over any other widget. Perfect for PDF annotations, markup tools, and collaborative drawing applications.

## 🚀 Choose Your Approach

We offer **three different versions** to match your needs:

### 🎯 Simple Version (Recommended for Most Use Cases)

Clean, straightforward API with minimal boilerplate - perfect for most drawing applications:

```dart
import 'package:window_paint/window_paint_simple.dart';

class MyDrawingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = WindowPaintController();

    return WindowPaint(
      controller: controller,
      child: Container(width: 400, height: 300, color: Colors.white),
      onDrawingAdded: (drawing) => print('Drawing added: ${drawing.id}'),
    );
  }
}
```

**Features:**
- ✅ **Minimal Setup** - Just a few lines of code to get started
- ✅ **Built-in Tools** - Pencil, rectangle, circle, and pan/zoom
- ✅ **Clean JSON Export** - Perfect for server-side PDF rendering
- ✅ **Selection & Editing** - Tap to select and modify drawings
- ✅ **Type Safety** - Enum-based tools and strong typing

### 🏗️ Full v2.0 Architecture (Advanced Use Cases)

Complete architectural solution with clean architecture principles:

```dart
import 'package:window_paint/window_paint_v2.dart';

// For applications requiring extensive customization,
// plugin architectures, and complex state management
```

**Features:**
- ✅ **Clean Architecture** - Domain, data, and presentation layers
- ✅ **Plugin System** - Easy to add custom drawing tools
- ✅ **Command Pattern** - Built-in undo/redo functionality
- ✅ **Advanced State Management** - Immutable state with reactive updates

### 📦 Legacy v1.x (Backward Compatibility)

Original implementation for existing applications:

```dart
import 'package:window_paint/window_paint.dart'; // v1.x (legacy)
```

## 📊 Version Comparison

| Feature | Simple | Full v2.0 | Legacy v1.x |
|---------|--------|-----------|-------------|
| **Setup Complexity** | 🟢 Minimal | 🟡 Moderate | 🔴 Complex |
| **API Simplicity** | 🟢 Very Easy | 🟡 Structured | 🔴 Verbose |
| **Drawing Tools** | 🟢 Built-in (4 tools) | 🟢 Extensible | 🟡 Limited |
| **JSON Export** | 🟢 Clean Schema | 🟢 Structured | 🟡 Basic |
| **Undo/Redo** | 🔴 Not Built-in | 🟢 Full Support | 🔴 None |
| **Type Safety** | 🟢 Strong Types | 🟢 Full Type Safety | 🔴 String-based |
| **Custom Tools** | 🟡 Possible | 🟢 Plugin System | 🔴 Difficult |
| **File Size** | 🟢 Single File | 🟡 Structured | 🟡 Multiple Files |
| **Learning Curve** | 🟢 5 minutes | 🟡 30 minutes | 🔴 Several hours |

## 🎯 Which Version Should You Use?

### Choose **Simple** if you:
- Want to add drawing functionality quickly
- Need basic tools (pencil, shapes, pan/zoom)
- Prefer minimal boilerplate and setup
- Want clean JSON export for server-side PDF rendering
- Are building a straightforward drawing/annotation app

### Choose **Full v2.0** if you:
- Need extensive customization and custom tools
- Want built-in undo/redo functionality
- Require plugin architecture for third-party tools
- Are building a complex drawing application
- Want clean architecture with proper separation of concerns

### Choose **Legacy v1.x** if you:
- Have existing code using the original API
- Need backward compatibility
- Are maintaining legacy applications

## 🚀 Quick Start Examples

### Simple Version (Most Common)

```dart
import 'package:flutter/material.dart';
import 'package:window_paint/window_paint_simple.dart';

class QuickDrawingApp extends StatefulWidget {
  @override
  _QuickDrawingAppState createState() => _QuickDrawingAppState();
}

class _QuickDrawingAppState extends State<QuickDrawingApp> {
  final controller = WindowPaintController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quick Drawing'),
        actions: [
          // Tool selector
          DropdownButton<DrawingTool>(
            value: controller.tool,
            onChanged: (tool) => controller.setTool(tool!),
            items: [
              DropdownMenuItem(value: DrawingTool.pan, child: Text('Pan')),
              DropdownMenuItem(value: DrawingTool.pencil, child: Text('Pencil')),
              DropdownMenuItem(value: DrawingTool.rectangle, child: Text('Rectangle')),
              DropdownMenuItem(value: DrawingTool.circle, child: Text('Circle')),
            ],
          ),
          // Clear button
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: controller.clearAll,
          ),
        ],
      ),
      body: WindowPaint(
        controller: controller,
        child: Container(
          color: Colors.grey[100],
          child: Center(
            child: Text('Draw here!', style: TextStyle(fontSize: 24)),
          ),
        ),
        onDrawingAdded: (drawing) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Drawing added: ${drawing.type}')),
          );
        },
      ),
    );
  }
  
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
```

### API Comparison

```dart
// Simple Version - Minimal boilerplate
final controller = WindowPaintController();
controller.setTool(DrawingTool.pencil);
controller.setColor(Colors.red);

WindowPaint(
  controller: controller,
  child: myWidget,
)

// Full v2.0 - More configuration options
final controller = WindowPaintController(
  tools: {
    DrawToolType.pencil: PencilDrawingTool(),
    DrawToolType.rectangle: RectangleDrawingTool(),
  },
);

WindowPaintV2(
  controller: controller,
  tools: tools,
  child: myWidget,
)

// Legacy v1.x - Complex setup
final adapters = [
  DrawPencilAdapter(),
  DrawRectangleAdapter(),
];
final controller = WindowPaintController();

WindowPaint(
  controller: controller,
  adapters: adapters,
  child: myWidget,
)
```

### 🏗️ Clean Architecture
The new architecture follows clean code principles with clear separation of concerns:

- **Domain Layer**: Business logic and entities
- **Data Layer**: Serialization and data models  
- **Presentation Layer**: UI components and state management

### 🔧 Extensible Tool System
Easily add new drawing tools by implementing simple interfaces:

```dart
class MyCustomTool implements IDrawingTool {
  @override
  DrawToolType get toolType => DrawToolType.custom;
  
  @override
  Future<IDrawableObject?> startDrawing({...}) async {
    // Your custom drawing logic
  }
  
  // Implement other required methods...
}
```

### 📦 Perfect for Server-Side Rendering
Clean JSON serialization makes it easy to render the same drawings on the server:

```dart
// Export drawing data
final jsonData = controller.exportToJson();

// JSON structure is clean and server-friendly:
[
  {
    "id": "uuid-here",
    "toolType": "pencil",
    "color": 4294901760,
    "strokeWidth": 2.0,
    "points": [...],
    "metadata": {}
  }
]
```

### ↩️ Undo/Redo Support
Built-in command pattern for full undo/redo functionality:

```dart
controller.undo();   // Undo last action
controller.redo();   // Redo last undone action
```

### 🎯 Type Safety
No more string-based tool modes - everything is strongly typed:

```dart
// Old v1 way (error-prone):
controller.mode = 'pencil';

// New v2 way (type-safe):
controller.setActiveTool(DrawToolType.pencil);
```

## Architecture Overview

See [ARCHITECTURE_V2.md](ARCHITECTURE_V2.md) for a detailed explanation of the v2.0 architecture, design principles, and examples.

## Examples

### Basic Drawing App

Check out the complete example in `example/lib/main_v2.dart` which demonstrates:

- Tool selection (pencil, rectangle, etc.)
- Color picker
- Stroke width adjustment
- Undo/redo functionality
- Object selection and manipulation

### Adding Custom Tools

```dart
class CircleDrawingTool implements ISelectableTool {
  @override
  DrawToolType get toolType => DrawToolType.circle; // You'd add this enum value
  
  @override
  Future<IDrawableObject?> startDrawing({...}) async {
    return CircleDrawableObject(
      center: startPoint,
      radius: 0,
      color: color,
    );
  }
  
  @override
  bool updateDrawing({...}) {
    if (object is CircleDrawableObject) {
      final distance = (currentPoint - object.center).distance;
      object.radius = distance;
      return true; // Request repaint
    }
    return false;
  }
  
  // Implement other required methods...
}
```

## Migration Guide

### From v1 to v2

1. **Install both versions** (they can coexist):
   ```dart
   import 'package:window_paint/window_paint.dart'; // v1
   import 'package:window_paint/window_paint_v2.dart'; // v2
   ```

2. **Replace widgets gradually**:
   ```dart
   // Old v1:
   WindowPaint(
     controller: oldController,
     adapters: adapters,
     child: myChild,
   )
   
   // New v2:
   WindowPaintV2(
     controller: newController,
     tools: tools,
     child: myChild,
   )
   ```

3. **Update state management**:
   ```dart
   // Old v1:
   final controller = WindowPaintController(
     initialMode: 'pencil',
     initialColor: Colors.red,
   );
   
   // New v2:
   final controller = WindowPaintController(
     initialState: WindowPaintState(
       activeTool: DrawToolType.pencil,
       activeColor: Colors.red,
     ),
   );
   ```

## API Comparison

| Feature | v1.x (Legacy) | v2.0 (Recommended) |
|---------|---------------|-------------------|
| Tool Selection | `controller.mode = 'pencil'` | `controller.setActiveTool(DrawToolType.pencil)` |
| Color Change | `controller.color = Colors.red` | `controller.setActiveColor(Colors.red)` |
| Adding Objects | `controller.addObject(object)` | `controller.addObject(object)` |
| Undo/Redo | ❌ Not built-in | ✅ `controller.undo()` / `controller.redo()` |
| Type Safety | ❌ String-based | ✅ Enum-based |
| Architecture | ❌ Monolithic | ✅ Clean Architecture |
| Extensibility | ⚠️ Complex | ✅ Interface-based |
| State Management | ⚠️ Mutable | ✅ Immutable |

For the general use case you should manage to get up and running by playing around with `example/lib/main.dart`.

If you want to add your own types of drawing tools, I'd advise you to take a look at `DrawObjectAdapter` and `DrawObject` and their subclass reference implementations that ship with this library.

This library does not ship with UI controls as part of its core library,
but you can copy the `example/lib/window_paint_control.dart` file and use
that as a starting point.

## Adapters and Objects

`DrawObjectAdapter` is responsible for creating, updating, (de)serializing and selecting their `DrawObject` counterpart. These classes are documented well enough to be able to write your own implementations.

This library ships with four reference implementations:

|DrawObjectAdapter          |DrawObject         |
|---------------------------|-------------------|
|PanZoomAdapter             |DrawNoop           |
|DrawPencilAdapter          |DrawPencil         |
|DrawRectangleAdapter       |DrawRectangle      |
|DrawRectangleCrossAdapter  |DrawRectangleCross |

Additionally, the example project ships with a fifth:

|DrawObjectAdapter          |DrawObject         |
|---------------------------|-------------------|
|DrawTextAdapter            |DrawText           |

## State Restoration

This library has full state restoration support with the `RestorableWindowPaintController`:

```dart
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
      // Remember to set this, otherwise state restoration will be disabled.
      restorationScopeId: 'root', 
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with RestorationMixin { // <- Add the RestorationMixin.
  final adapters = <DrawObjectAdapter>[
    // Add your adapters here...
    //
    // Remember to always provide the same adapters,
    // otherwise not all objects will manage to be restored!
  ];

  // This is your friend.
  late final RestorableWindowPaintController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RestorableWindowPaintController(
      adapters,
      initialColor: Colors.red,
    );
  }

  // Register your controller for state restoration.
  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_controller, 'controller');
  }

  // Give your component a unique restorationId in the enclosing RestorationScope.
  @override
  String? get restorationId => 'main_page';

  @override
  void dispose() {
    // Of course, remember to dispose of it.
    _controller.dispose();
    super.dispose();
  }
}
```

## Path Simplification

Take a look at `DrawPencil.finalize()` to see `simplifyPoints()` in action.

This function takes hundreds of individual points and reduces them down to the bare minimum to approximately represent the same path with the given `tolerance`. The results are rather impressive.

Credit for this algorithm goes to [Vladimir Agafonkin](https://github.com/mourner/simplify-js/blob/6930f87d19f87a5b262becaf1fd3080102b0cb51/simplify.js#L1).

## Hit-testing

Canvas-based path rendering is rather dynamic. Thus, if we want to do object selection, we're forced to manage hit-testing ourselves.

Luckily someone else already figured out the math for us!

For simple [AABB](https://en.wikipedia.org/wiki/Bounding_volume#Common_types) hit-testing, we can utilize Flutter's `Rect.contains(Offset)` method.

For more complex hit-testing, like [OBB](https://en.wikipedia.org/wiki/Bounding_volume#Common_types), we've implemented the `Line(Offset start, Offset end, double extent)` class. This allows us to hit-test against diagonal lines (like the pencil strokes or the rectangle inner cross).

For even more possibilities, check out the excellent [vector_math](https://pub.dev/packages/vector_math).

## Naming

The name window paint comes from my childhood memories.

Me and my siblings used to paint the windows in our bedrooms with "art", the kind of stunning art you're able to create with this library 👨‍🎨. After drying, our works overlayed the outside world &mdash; which is exactly what this package does.

## License

MIT