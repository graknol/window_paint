import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:window_paint/src/draw/draw_object.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';
import 'package:window_paint/src/utils/draw_object_serialization.dart';

class WindowPaintController extends ValueNotifier<WindowPaintValue> {
  /// Creates a controller for a window paint widget.
  factory WindowPaintController({
    String initialMode = 'pan_zoom',
    Color initialColor = const Color(0xFF000000),
    List<DrawObject>? initialObjects,
  }) =>
      WindowPaintController.fromValue(
        WindowPaintValue(
          mode: initialMode,
          color: initialColor,
          objects: initialObjects,
        ),
      );

  /// Creates a controller for a window paint widget from an initial
  /// [WindowPaintValue].
  WindowPaintController.fromValue(WindowPaintValue? value)
      : super(value ?? WindowPaintValue.empty);

  /// The current paint mode being used.
  String get mode => value.mode;

  /// The color of the paint tool.
  Color get color => value.color;

  /// The objects to render.
  List<DrawObject> get objects => value.objects;

  /// The value of [color] before selecting an object.
  ///
  /// Used to restore [color] when the selection is cancelled.
  Color get colorBeforeSelection => value.colorBeforeSelection;

  /// The index of the currently selected object, if any.
  ///
  /// Equal to `-1` if no object is selected.
  int get selectedObjectIndex => value.selectedObjectIndex;

  /// Whether or not we're currently selecting a [DrawObject].
  bool get isSelecting => value.isSelecting;

  /// The selected object or [null] if none is selected.
  DrawObject? get selectedObject =>
      isSelecting ? value.objects[value.selectedObjectIndex] : null;

  /// Setting this will notify all the listeners of this [WindowPaintController]
  /// that they need to update (it calls [notifyListeners()]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  ///
  /// This property can be set from a listener added to this
  /// [WindowPaintController]; however, one should not also set [color]
  /// and [objects] in a separate statement. To change both the [mode], [color]
  /// and [objects] change the controller's [value].
  set mode(String newMode) {
    value = value.copyWith(
      mode: newMode,
    );
  }

  /// Setting this will notify all the listeners of this [WindowPaintController]
  /// that they need to update (it calls [notifyListeners()]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  ///
  /// This property can be set from a listener added to this
  /// [WindowPaintController]; however, one should not also set [mode]
  /// and [objects] in a separate statement. To change both the [mode], [color]
  /// and [objects] change the controller's [value].
  ///
  /// Setting this will update the color of the selected object.
  set color(Color newColor) {
    if (isSelecting) {
      if (newColor != color) {
        final object = selectedObject!;
        object.adapter.selectUpdateColor(object, newColor);
      }
    }
    value = value.copyWith(
      color: newColor,
    );
  }

  /// Setting this will notify all the listeners of this [WindowPaintController]
  /// that they need to update (it calls [notifyListeners()]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  ///
  /// This property can be set from a listener added to this
  /// [WindowPaintController]; however, one should not also set [mode]
  /// and [color] in a separate statement. To change both the [mode], [color]
  /// and [objects] change the controller's [value].
  set objects(List<DrawObject> newObjects) {
    value = value.copyWith(
      objects: newObjects,
    );
  }

  /// Calling this will notify all the listeners of this [WindowPaintController]
  /// that they need to update (it calls [notifyListeners()]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  ///
  /// This method can be called from a listener added to this
  /// [WindowPaintController]; however, one should not call it repeatedly.
  /// To add multiple [DrawObject] call [addObjects()].
  void addObject(DrawObject object) {
    objects.add(object);
    notifyListeners();
  }

  /// Calling this will notify all the listeners of this [WindowPaintController]
  /// that they need to update (it calls [notifyListeners()]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  ///
  /// This method can be called from a listener added to this
  /// [WindowPaintController].
  void addObjects(Iterable<DrawObject> objects) {
    this.objects.addAll(objects);
    notifyListeners();
  }

  /// Calling this will notify all the listeners of this [WindowPaintController]
  /// that they need to update (it calls [notifyListeners()]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  ///
  /// This method can be called from a listener added to this
  /// [WindowPaintController]; however, one should not call it repeatedly.
  /// To remove multiple [DrawObject] call [removeObjectsWhere()].
  void removeObject(DrawObject object) {
    objects.remove(object);
    notifyListeners();
  }

  /// Calling this will notify all the listeners of this [WindowPaintController]
  /// that they need to update (it calls [notifyListeners()]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  ///
  /// This method can be called from a listener added to this
  /// [WindowPaintController].
  void removeObjectsWhere(bool Function(DrawObject object) test) {
    objects.removeWhere(test);
    notifyListeners();
  }

  /// Stores the [color] so that it can be restored when the selection
  /// gets cancelled.
  ///
  /// Calling this will notify all the listeners of this [WindowPaintController]
  /// that they need to update (it calls [notifyListeners()]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  ///
  /// This method can be called from a listener added to this
  /// [WindowPaintController].
  void selectObject(int index) {
    final object = objects[index];
    value = value.copyWith(
      color: object.primaryColor,
      colorBeforeSelection: value.color,
      selectedObjectIndex: index,
    );
  }

  /// Restores [color] to the value it had before the object was selected.
  ///
  /// Calling this will notify all the listeners of this [WindowPaintController]
  /// that they need to update (it calls [notifyListeners()]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  ///
  /// This method can be called from a listener added to this
  /// [WindowPaintController].
  void cancelSelectObject() {
    value = value.copyWith(
      color: value.colorBeforeSelection,
      colorBeforeSelection: const Color(0x00000000),
      selectedObjectIndex: -1,
    );
  }

  /// Calling this will notify all the listeners of this [WindowPaintController]
  /// that the last object is done. This is basically just a wrapper
  /// around [notifyListeners()].
  ///
  /// Used to restore the last [DrawObject] that was interacted with in its
  /// entirety, not just its start or intermediate state. The reason being that
  /// we add the objects before they are done, thus [notifyListeners()] gets
  /// called only once at the start of the interaction.
  void objectWasUpdated() {
    notifyListeners();
  }

  @override
  set value(WindowPaintValue newValue) {
    super.value = newValue;
  }
}

/// The current mode and color state for a [WindowPaint] widget.
@immutable
class WindowPaintValue {
  /// Creates information for painting a widget.
  ///
  /// The [mode] and [color] arguments must not be null, but each have default
  /// values.
  WindowPaintValue({
    this.mode = 'pan_zoom',
    this.color = const Color(0xFF000000),
    List<DrawObject>? objects,
    this.colorBeforeSelection = const Color(0x00000000),
    this.selectedObjectIndex = -1,
  }) : objects = objects ?? [];

  /// Creates an instance of this class from a JSON object.
  factory WindowPaintValue.fromJSON(
      List<DrawObjectAdapter> adapters, Map encoded) {
    return WindowPaintValue(
      mode: encoded['mode'] as String,
      color: Color(encoded['color'] as int),
      objects: drawObjectsFromJSON(encoded['objects'] as List, adapters),
    );
  }

  /// Returns a representation of this object as a JSON object.
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'mode': mode,
      'color': color.value,
      'objects': drawObjectsToJSON(objects),
    };
  }

  /// The current paint mode being used.
  final String mode;

  /// The color of the paint tool.
  final Color color;

  /// The objects to render.
  final List<DrawObject> objects;

  /// The value of [color] before selecting an object.
  ///
  /// Used to restore [color] when the selection is cancelled.
  final Color colorBeforeSelection;

  /// The index of the currently selected object, if any.
  ///
  /// Equal to `-1` if no object is selected.
  final int selectedObjectIndex;

  /// Whether or not we're currently selecting a [DrawObject].
  bool get isSelecting => selectedObjectIndex >= 0;

  /// A value that corresponds to the pan/zoom mode and black color.
  static WindowPaintValue empty = WindowPaintValue();

  /// Creates a copy of this value but with the given fields replaced with the
  /// new values.
  WindowPaintValue copyWith({
    String? mode,
    Color? color,
    List<DrawObject>? objects,
    Color? colorBeforeSelection,
    int? selectedObjectIndex,
  }) {
    return WindowPaintValue(
      mode: mode ?? this.mode,
      color: color ?? this.color,
      objects: objects ?? this.objects,
      colorBeforeSelection: colorBeforeSelection ?? this.colorBeforeSelection,
      selectedObjectIndex: selectedObjectIndex ?? this.selectedObjectIndex,
    );
  }

  @override
  String toString() =>
      '${objectRuntimeType(this, 'WindowPaintValue')}(mode: $mode, color: $color, objects: ${describeIdentity(objects)})';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WindowPaintValue &&
        other.mode == mode &&
        other.color == color &&
        listEquals(other.objects, objects) &&
        other.colorBeforeSelection == colorBeforeSelection &&
        other.selectedObjectIndex == selectedObjectIndex;
  }

  @override
  int get hashCode => hashValues(
        mode.hashCode,
        color.hashCode,
        objects.hashCode,
        colorBeforeSelection.hashCode,
        selectedObjectIndex.hashCode,
      );
}

/// A [RestorableProperty] that knows how to store and restore a
/// [WindowPaintController].
///
/// The [WindowPaintController] is accessible via the [value] getter. During
/// state restoration, the property will restore [WindowPaintController.mode]
/// and [WindowPaintController.color] to the values they had when the
/// restoration data it is getting restored from was collected.
class RestorableWindowPaintController
    extends RestorableChangeNotifier<WindowPaintController> {
  /// Creates a [RestorableWindowPaintController].
  factory RestorableWindowPaintController(
    List<DrawObjectAdapter> adapters, {
    String initialMode = 'pan_zoom',
    Color initialColor = const Color(0xFF000000),
    List<DrawObject>? initialObjects,
  }) =>
      RestorableWindowPaintController.fromValue(
        adapters,
        WindowPaintValue(
          mode: initialMode,
          color: initialColor,
          objects: initialObjects ?? [],
        ),
      );

  /// Creates a [RestorableWindowPaintController] from an initial
  /// [WindowPaintValue].
  RestorableWindowPaintController.fromValue(
      List<DrawObjectAdapter> adapters, WindowPaintValue value)
      : _adapters = adapters,
        _initialValue = value;

  final List<DrawObjectAdapter> _adapters;
  final WindowPaintValue _initialValue;

  @override
  WindowPaintController createDefaultValue() {
    return WindowPaintController.fromValue(_initialValue);
  }

  @override
  WindowPaintController fromPrimitives(Object? data) {
    return WindowPaintController.fromValue(
        WindowPaintValue.fromJSON(_adapters, data! as Map));
  }

  @override
  Object toPrimitives() {
    return value.value.toJSON();
  }
}
