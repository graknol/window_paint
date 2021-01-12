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
