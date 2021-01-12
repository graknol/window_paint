import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class WindowPaintController extends ValueNotifier<WindowPaintValue> {
  /// Creates a controller for a window paint widget.
  factory WindowPaintController({
    String initialMode = 'pan_zoom',
    Color initialColor = const Color(0xFF000000),
  }) =>
      WindowPaintController.fromValue(
        WindowPaintValue(
          mode: initialMode,
          color: initialColor,
        ),
      );

  /// Creates a controller for a window paint widget from an initial
  /// [WindowPaintValue].
  WindowPaintController.fromValue(WindowPaintValue? value)
      : super(value ?? WindowPaintValue.empty);

  /// The current paint mode being used.
  String get mode => value.mode;
  // The color of the paint tool.
  Color get color => value.color;

  /// Setting this will notify all the listeners of this [WindowPaintController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  ///
  /// This property can be set from a listener added to this
  /// [WindowPaintController]; however, one should not also set [color]
  /// in a separate statement. To change both the [mode] and the [color]
  /// change the controller's [value].
  set mode(String newMode) {
    value = value.copyWith(
      mode: newMode,
    );
  }

  /// Setting this will notify all the listeners of this [WindowPaintController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  ///
  /// This property can be set from a listener added to this
  /// [WindowPaintController]; however, one should not also set [mode]
  /// in a separate statement. To change both the [mode] and the [color]
  /// change the controller's [value].
  set color(Color newColor) {
    value = value.copyWith(
      color: newColor,
    );
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
  const WindowPaintValue({
    this.mode = 'pan_zoom',
    this.color = const Color(0xFF000000),
  });

  /// Creates an instance of this class from a JSON object.
  factory WindowPaintValue.fromJSON(Map<String, dynamic> encoded) {
    return WindowPaintValue(
      mode: encoded['mode'] as String,
      color: Color(encoded['color'] as int),
    );
  }

  /// Returns a representation of this object as a JSON object.
  Map<String, dynamic> toJSON() {
    return <String, dynamic>{
      'mode': mode,
      'color': color.value,
    };
  }

  /// The current paint mode being used.
  final String mode;

  /// The color of the paint tool.
  final Color color;

  /// A value that corresponds to the pan/zoom mode and black color.
  static const WindowPaintValue empty = WindowPaintValue();

  /// Creates a copy of this value but with the given fields replaced with the
  /// new values.
  WindowPaintValue copyWith({
    String? mode,
    Color? color,
  }) {
    return WindowPaintValue(
      mode: mode ?? this.mode,
      color: color ?? this.color,
    );
  }

  @override
  String toString() =>
      '${objectRuntimeType(this, 'WindowPaintValue')}(mode: $mode, color: $color)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WindowPaintValue &&
        other.mode == mode &&
        other.color == color;
  }

  @override
  int get hashCode => hashValues(
        mode.hashCode,
        color.hashCode,
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
  factory RestorableWindowPaintController({
    String initialMode = 'pan_zoom',
    Color initialColor = const Color(0xFF000000),
  }) =>
      RestorableWindowPaintController.fromValue(
        WindowPaintValue(
          mode: initialMode,
          color: initialColor,
        ),
      );

  /// Creates a [RestorableWindowPaintController] from an initial
  /// [WindowPaintValue].
  RestorableWindowPaintController.fromValue(WindowPaintValue value)
      : _initialValue = value;

  final WindowPaintValue _initialValue;

  @override
  WindowPaintController createDefaultValue() {
    return WindowPaintController.fromValue(_initialValue);
  }

  @override
  WindowPaintController fromPrimitives(Object? data) {
    return WindowPaintController.fromValue(
        WindowPaintValue.fromJSON(data as Map<String, dynamic>));
  }

  @override
  Object toPrimitives() {
    return value.value.toJSON();
  }
}
