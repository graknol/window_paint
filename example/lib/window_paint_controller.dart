import 'dart:ui';

import 'package:flutter/foundation.dart';

class WindowPaintController
    with WindowPaintEagerListenerMixin, WindowPaintLocalListenersMixin {
  bool _panEnabled;
  bool _scaleEnabled;
  bool _paintEnabled;
  Color _color;

  WindowPaintController({
    bool initialPanEnabled = true,
    bool initialScaleEnabled = true,
    bool initialPaintEnabled = false,
    Color initialColor = const Color(0xFF000000),
  })  : assert(initialPanEnabled != null),
        assert(initialScaleEnabled != null),
        assert(initialPaintEnabled != null),
        assert(initialColor != null),
        _panEnabled = initialPanEnabled,
        _scaleEnabled = initialScaleEnabled,
        _paintEnabled = initialPaintEnabled,
        _color = initialColor;

  bool get panEnabled => _panEnabled;
  bool get scaleEnabled => _scaleEnabled;
  bool get paintEnabled => _paintEnabled;
  Color get color => _color;

  set panEnabled(bool enabled) {
    assert(enabled != null);
    _panEnabled = enabled;
    notifyListeners();
  }

  set scaleEnabled(bool enabled) {
    assert(enabled != null);
    _scaleEnabled = enabled;
    notifyListeners();
  }

  set paintEnabled(bool enabled) {
    assert(enabled != null);
    _paintEnabled = enabled;
    notifyListeners();
  }

  set color(Color color) {
    assert(color != null);
    _color = color;
    notifyListeners();
  }

  void update({
    bool panEnabled,
    bool scaleEnabled,
    bool paintEnabled,
    Color color,
  }) {
    assert(panEnabled != null ||
        scaleEnabled != null ||
        paintEnabled != null ||
        color != null);
    _panEnabled = panEnabled ?? _panEnabled;
    _scaleEnabled = scaleEnabled ?? _scaleEnabled;
    _paintEnabled = paintEnabled ?? _paintEnabled;
    _color = color ?? _color;
    notifyListeners();
  }

  /// Release the resources used by this object. The object is no longer usable
  /// after this method is called.
  @override
  void dispose() {
    super.dispose();
  }
}

/// A mixin that replaces the [didRegisterListener]/[didUnregisterListener] contract
/// with a dispose contract.
///
/// This mixin provides implementations of [didRegisterListener] and [didUnregisterListener],
/// and therefore can be used in conjunction with mixins that require these methods,
/// [WindowPaintLocalListenersMixin].
mixin WindowPaintEagerListenerMixin {
  /// This implementation ignores listener registrations.
  void didRegisterListener() {}

  /// This implementation ignores listener registrations.
  void didUnregisterListener() {}

  /// Release the resources used by this object. The object is no longer usable
  /// after this method is called.
  @mustCallSuper
  void dispose() {}
}

mixin WindowPaintLocalListenersMixin {
  final ObserverList<VoidCallback> _listeners = ObserverList<VoidCallback>();

  /// Called immediately before a listener is added via [addListener].
  ///
  /// At the time this method is called the registered listener is not yet
  /// notified by [notifyListeners].
  void didRegisterListener();

  /// Called immediately after a listener is removed via [removeListener].
  ///
  /// At the time this method is called the removed listener is no longer
  /// notified by [notifyListeners].
  void didUnregisterListener();

  /// Calls the listener every time the value of the animation changes.
  ///
  /// Listeners can be removed with [removeListener].
  void addListener(VoidCallback listener) {
    didRegisterListener();
    _listeners.add(listener);
  }

  /// Stop calling the listener every time the value of the animation changes.
  ///
  /// Listeners can be added with [addListener].
  void removeListener(VoidCallback listener) {
    final bool removed = _listeners.remove(listener);
    if (removed) {
      didUnregisterListener();
    }
  }

  /// Calls all the listeners.
  ///
  /// If listeners are added or removed during this function, the modifications
  /// will not change which listeners are called during this iteration.
  void notifyListeners() {
    final List<VoidCallback> localListeners =
        List<VoidCallback>.from(_listeners);
    for (final VoidCallback listener in localListeners) {
      InformationCollector collector;
      assert(() {
        collector = () sync* {
          yield DiagnosticsProperty<WindowPaintLocalListenersMixin>(
            'The $runtimeType notifying listeners was',
            this,
            style: DiagnosticsTreeStyle.errorProperty,
          );
        };
        return true;
      }());
      try {
        if (_listeners.contains(listener)) listener();
      } catch (exception, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: exception,
          stack: stack,
          library: 'window_paint library',
          context:
              ErrorDescription('while notifying listeners for $runtimeType'),
          informationCollector: collector,
        ));
      }
    }
  }
}
