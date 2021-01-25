## [0.1.0-nullsafety.4] - Jan 25, 2021

* Expose `TransformationController` on `WindowPaintCanvas`/`WindowPaint`.

## [0.1.0-nullsafety.3] - Jan 21, 2021

* `InteractiveViewer`'s `minScale` and `maxScale` are now configurable.
* Scale objects, outlines, hitboxes, and path-simplification tolerance relative to the zoom-level.
* `DrawRectangle._paintOutline` parameter `Sizesize` corrected to `Size size`.

## [0.1.0-nullsafety.2] - Jan 13, 2021

* Added a button for toggling hitboxes in the `example` app.
* The framework now supports selecting objects. It's the adapter's
  responsibility to perform hit-testing, (de)selecting, rendering
  outlines and resize handles, and moving the objects. This gives
  the greatest flexibility and gives a tool the opportunity to
  include only the features it needs.
* The reference `DrawObject` and `DrawObjectAdapter` implementations
  demonstrate both simple ([AABB](https://en.wikipedia.org/wiki/Bounding_volume#Common_types))
  and complex ([OBB](https://en.wikipedia.org/wiki/Bounding_volume#Common_types)) 
  hit-testing techniques.
* The `Line` class has been added to make it easier to work with
  lines of a given width. Its `contains` method makes it easy to
  perform OBB hit-testing.
* Added a dependency on [vector_math: ^2.1.0-nullsafety.5](https://pub.dev/packages/vector_math/versions/2.1.0-nullsafety.5)
* Lots of other small changes to the API.

## [0.1.0-nullsafety.1] - Jan 12, 2021

* Replaced the `example`'s picture with a solid color.
* Added explanation of the package's name in the README.
* Added `DrawTextAdapter` and `DrawText` to the `example` project.
* `DrawObjectAdapter.start` returns `FutureOr<DrawObject?>?` to support async operations, i.e. showing a dialog for text input.
* `DrawObjectAdapter.start` accepts a `BuildContext` and the current transformation `Matrix4`.

## [0.1.0-nullsafety.0] - Jan 12, 2021

* Solves an issue with how `InteractiveViewer.onInteractionUpdate` on the beta channel behaves. This change is both backward and forward compatible.
* Added static analysis with the pedantic 1.9.0 ruleset.
* Migrated to sound null-safety.
* Controllers now use the `ValueNotifier` pattern from `TextEditingController` instead of the mixin way of `AnimationController`.
* Controllers now also have `Restorable` equivalents, i.e. how `TextEditingController` has `RestorableTextEditingController`.
* `CustomRadio` has been moved to the `example` project.
* The `example` project's `WindowPaintControl` now has a more clear icon for the "rectangle with cross" paint mode.
* Files are organized in a more consumer-friendly fashion, with a `lib/src` folder and a `lib/window_paint.dart` file which exports all the necessary library files.

## [0.0.1] - Jan 11, 2021

* Initial release.
