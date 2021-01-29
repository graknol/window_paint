# Painting with power

`WindowPaint` lets you pan, zoom and paint over any other widget.

It uses the new `InteractiveViewer` coupled with `CustomPainter`; giving you the bare minimum to get you started.

## Getting Started

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