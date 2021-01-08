import 'package:flutter/foundation.dart';

class WindowPaintController
    with WindowPaintEagerListenerMixin, WindowPaintLocalListenersMixin {
  /// Release the resources used by this object. The object is no longer usable
  /// after this method is called.
  ///
  /// The most recently returned [TickerFuture], if any, is marked as having been
  /// canceled, meaning the future never completes and its [TickerFuture.orCancel]
  /// derivative future completes with a [TickerCanceled] error.
  @override
  void dispose() {
    // assert(() {
    //   if (_ticker == null) {
    //     throw FlutterError.fromParts(<DiagnosticsNode>[
    //       ErrorSummary(
    //           'WindowPaintController.dispose() called more than once.'),
    //       ErrorDescription(
    //           'A given $runtimeType cannot be disposed more than once.\n'),
    //       DiagnosticsProperty<WindowPaintController>(
    //         'The following $runtimeType object was disposed multiple times',
    //         this,
    //         style: DiagnosticsTreeStyle.errorProperty,
    //       ),
    //     ]);
    //   }
    //   return true;
    // }());
    // _ticker!.dispose();
    // _ticker = null;
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
