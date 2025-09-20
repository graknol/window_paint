# Window Paint - Drawing Widget for Flutter

A powerful, extensible drawing widget for Flutter that lets you pan, zoom and paint over any other widget. Perfect for PDF annotations, markup tools, and collaborative drawing applications.

## 🚀 Version 2.0 - New Architecture!

We've completely rewritten window_paint with a clean, modern architecture following Flutter best practices. The new v2.0 offers:

- **✅ Clean Architecture** - Proper separation of concerns with domain, data, and presentation layers
- **✅ Type Safety** - Enum-based tool types instead of error-prone strings
- **✅ Better State Management** - Immutable state with command pattern for undo/redo
- **✅ Enhanced Extensibility** - Plugin-based architecture for adding new drawing tools
- **✅ Improved Serialization** - Clean JSON schema for easy server-side rendering
- **✅ Modern Flutter Patterns** - ValueNotifier, proper disposal, reactive updates

### Quick Start with v2.0

```dart
import 'package:window_paint/window_paint_v2.dart';

class MyDrawingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = WindowPaintController();
    final tools = {
      DrawToolType.pencil: PencilDrawingTool(),
      // Add more tools as needed
    };

    return WindowPaintV2(
      controller: controller,
      tools: tools,
      child: Container(
        width: 400,
        height: 300,
        color: Colors.white,
      ),
      onObjectAdded: (objectId) => print('Added: $objectId'),
    );
  }
}
```

## Legacy v1.x Support

The original window_paint implementation is still available for backward compatibility:

```dart
import 'package:window_paint/window_paint.dart'; // v1.x (legacy)
```

For new projects, we strongly recommend using v2.0:

```dart
import 'package:window_paint/window_paint_v2.dart'; // v2.0 (recommended)
```

## V2.0 Features & Benefits

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