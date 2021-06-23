## [0.6.1] - June 23, 2021

- Handle missing non-required properties in `DrawObject.fromJSON` by providing sensible defaults.

## [0.6.0] - June 18, 2021

- Added `WindowPaint.onAdd` and `WindowPaint.onChange` which are triggered by
interacting with the UI. Programmatic changes do not trigger these; meaning
that any change by using `WindowPaintController` will have to be handled by
the caller.

## [0.5.0] - June 17, 2021

- Changed `SelectOutlineMixin.selectOutline` to `getSelectOutline(Size size)` to correctly display the select outline.

## [0.4.0] - June 17, 2021

- All coordinates are now normalized to the given screen size; making sharing and collaboration easier.
- Added `DrawObject.clone()` which returns a deep clone of the object; making diff'ing easier.

## [0.3.0] - June 15, 2021

- `DrawRectangle` and `DrawRectangleCross` serializes `endpoint` as `endpoint.x` and `endpoint.y` instead of `endpointX` and `endpointY`.

## [0.2.0] - June 15, 2021

- `DrawObject` now exposes IDs, making them identifiable, which is meant to simplify collaboration efforts.
- Removed the `nullsafety` version postfix.
- Updated the SDK constraint to `>=2.12.0 <3.0.0`.

## [0.1.0-nullsafety.12] - June 14, 2021

- `DrawObject.toJSON()` and `DrawObject.fromJSON()` now take (de)normalization arguments to be able to
  (de)normalize points to make sharing across different devices easier.

## [0.1.0-nullsafety.11] - June 11, 2021

- `DragHandleMixin` keeps track of valid state to make it easier for the caller to use with multiple mixins of this kind (select, drag, finalize).

## [0.1.0-nullsafety.10] - June 11, 2021

- Update `_paintedSelected` in `paintSelectOutline()` so that `shouldRepaintSelectOutline()` behaves correctly.

## [0.1.0-nullsafety.9] - June 11, 2021

- Re-index the selected object when calling `WindowPaintController.removeObject()` and `WindowPaintController.removeObjectsWhere()`.

## [0.1.0-nullsafety.8] - May 11, 2021

- Compute hitbox of `DrawRectangle` correctly so it works for all orientations and not just when drawing from _top-left_ -> _bottom-right_.

## [0.1.0-nullsafety.7] - Feb 01, 2021

- Simplify the selection logic, while also allowing for more natural transitioning between selection, non-selection and inter-object selection.
- Generalize drag handle logic with DragHandleMixin.
- Generalize select outline painting with SelectOutlineMixin.

## [0.1.0-nullsafety.6] - Jan 29, 2021

- Fix a bug where `Line.contains()` always returns `true` when `start == end`.
- Encapsulate `InteractiveViewer` in a `ClipRect` to prevent overflow when zooming and painting.
- Paint each `DrawObject` in their own `CustomPaint`.
- Use `Map<dynamic, dynamic>` instead of `Map<String, dynamic>` in restoration, due to casting issues.
- Restore `DrawRectangle.endpoint` during restoration.
- Call `WindowPaintController.notifyListeners()` when interaction ends to fully restore the last object that was interacted with.
- Improve documentation and README.

## [0.1.0-nullsafety.5] - Jan 28, 2021

- Make hitbox extents configurable.
- Move objects into `WindowPaintController`.
- Move object selection into `WindowPaintController`.
- Update the selected object's color when setting `WindowPaintController.color`.
- Support serialization and restoration of `DrawObject` through `RestorableWindowPaintController`.
- Merge `WindowPaintCanvas` into `WindowPaint`.
- Update example project.

## [0.1.0-nullsafety.4] - Jan 25, 2021

- Expose `TransformationController` on `WindowPaintCanvas`/`WindowPaint`.

## [0.1.0-nullsafety.3] - Jan 21, 2021

- `InteractiveViewer`'s `minScale` and `maxScale` are now configurable.
- Scale objects, outlines, hitboxes, and path-simplification tolerance relative to the zoom-level.
- `DrawRectangle._paintOutline` parameter `Sizesize` corrected to `Size size`.

## [0.1.0-nullsafety.2] - Jan 13, 2021

- Added a button for toggling hitboxes in the `example` app.
- The framework now supports selecting objects. It's the adapter's
  responsibility to perform hit-testing, (de)selecting, rendering
  outlines and resize handles, and moving the objects. This gives
  the greatest flexibility and gives a tool the opportunity to
  include only the features it needs.
- The reference `DrawObject` and `DrawObjectAdapter` implementations
  demonstrate both simple ([AABB](https://en.wikipedia.org/wiki/Bounding_volume#Common_types))
  and complex ([OBB](https://en.wikipedia.org/wiki/Bounding_volume#Common_types))
  hit-testing techniques.
- The `Line` class has been added to make it easier to work with
  lines of a given width. Its `contains` method makes it easy to
  perform OBB hit-testing.
- Added a dependency on [vector_math: ^2.1.0-nullsafety.5](https://pub.dev/packages/vector_math/versions/2.1.0-nullsafety.5)
- Lots of other small changes to the API.

## [0.1.0-nullsafety.1] - Jan 12, 2021

- Replaced the `example`'s picture with a solid color.
- Added explanation of the package's name in the README.
- Added `DrawTextAdapter` and `DrawText` to the `example` project.
- `DrawObjectAdapter.start` returns `FutureOr<DrawObject?>?` to support async operations, i.e. showing a dialog for text input.
- `DrawObjectAdapter.start` accepts a `BuildContext` and the current transformation `Matrix4`.

## [0.1.0-nullsafety.0] - Jan 12, 2021

- Solves an issue with how `InteractiveViewer.onInteractionUpdate` on the beta channel behaves. This change is both backward and forward compatible.
- Added static analysis with the pedantic 1.9.0 ruleset.
- Migrated to sound null-safety.
- Controllers now use the `ValueNotifier` pattern from `TextEditingController` instead of the mixin way of `AnimationController`.
- Controllers now also have `Restorable` equivalents, i.e. how `TextEditingController` has `RestorableTextEditingController`.
- `CustomRadio` has been moved to the `example` project.
- The `example` project's `WindowPaintControl` now has a more clear icon for the "rectangle with cross" paint mode.
- Files are organized in a more consumer-friendly fashion, with a `lib/src` folder and a `lib/window_paint.dart` file which exports all the necessary library files.

## [0.0.1] - Jan 11, 2021

- Initial release.
