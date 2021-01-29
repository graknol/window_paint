import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class CustomRadioController extends ValueNotifier<CustomRadioValue> {
  /// Creates a controller for a custom radio.
  factory CustomRadioController({
    int initialIndex = 0,
  }) =>
      CustomRadioController.fromValue(
        CustomRadioValue(
          index: initialIndex,
        ),
      );

  /// Creates a controller for a custom radio from an
  /// initial [CustomRadioValue].
  CustomRadioController.fromValue(CustomRadioValue? value)
      : super(value ?? CustomRadioValue.empty);

  /// The index of the currently selected radio element.
  int get index => value.index;

  /// Setting this will notify all the listeners of this [CustomRadioController]
  /// that they need to update (it calls [notifyListeners]). For this reason,
  /// this value should only be set between frames, e.g. in response to user
  /// actions, not during the build, layout, or paint phases.
  set index(int newIndex) {
    value = value.copyWith(
      index: newIndex,
    );
  }

  @override
  set value(CustomRadioValue newValue) {
    super.value = newValue;
  }
}

/// The current mode and color state for a [CustomRadio] widget.
@immutable
class CustomRadioValue {
  /// Creates information for painting a widget.
  ///
  /// The [mode] and [color] arguments must not be null, but each have default
  /// values.
  const CustomRadioValue({
    this.index = 0,
  }) : assert(index >= 0);

  /// The index of the currently selected radio element.
  final int index;

  /// A value that corresponds to the first radio element being selected.
  static const CustomRadioValue empty = CustomRadioValue();

  /// Creates a copy of this value but with the given fields replaced with the
  /// new values.
  CustomRadioValue copyWith({
    int? index,
  }) {
    return CustomRadioValue(
      index: index ?? this.index,
    );
  }

  @override
  String toString() =>
      '${objectRuntimeType(this, 'CustomRadioValue')}(index: $index)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CustomRadioValue && other.index == index;
  }

  @override
  int get hashCode => index.hashCode;
}

/// A [RestorableProperty] that knows how to store and restore a
/// [CustomRadioController].
///
/// The [CustomRadioController] is accessible via the [value] getter. During
/// state restoration, the property will restore [CustomRadioController.index]
/// to the value it had when the restoration data it is getting restored from
/// was collected.
class RestorableCustomRadioController
    extends RestorableChangeNotifier<CustomRadioController> {
  /// Creates a [RestorableCustomRadioController].
  factory RestorableCustomRadioController({
    int initialIndex = 0,
  }) =>
      RestorableCustomRadioController.fromValue(
        CustomRadioValue(
          index: initialIndex,
        ),
      );

  /// Creates a [RestorableCustomRadioController] from an initial
  /// [CustomRadioValue].
  RestorableCustomRadioController.fromValue(CustomRadioValue value)
      : _initialValue = value;

  final CustomRadioValue _initialValue;

  @override
  CustomRadioController createDefaultValue() {
    return CustomRadioController.fromValue(_initialValue);
  }

  @override
  CustomRadioController fromPrimitives(Object? data) {
    return CustomRadioController.fromValue(
      CustomRadioValue(
        index: data! as int,
      ),
    );
  }

  @override
  Object toPrimitives() {
    return value.index;
  }
}
