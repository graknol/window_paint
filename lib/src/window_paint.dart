import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:measurer/measurer.dart';
import 'package:window_paint/src/draw/adapters/draw_pencil_adapter.dart';
import 'package:window_paint/src/draw/adapters/draw_rectangle_adapter.dart';
import 'package:window_paint/src/draw/adapters/draw_rectangle_cross_adapter.dart';
import 'package:window_paint/src/draw/adapters/pan_zoom_adapter.dart';
import 'package:window_paint/src/draw/draw_object.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';
import 'package:window_paint/src/window_paint_controller.dart';
import 'package:window_paint/src/window_paint_painter.dart';

typedef OnAddCallback = void Function(DrawObject object);
typedef OnChangeCallback = void Function(DrawObject before, DrawObject after);

class WindowPaint extends StatefulWidget {
  WindowPaint({
    Key? key,
    this.controller,
    this.transformationController,
    this.minScale = 1.0,
    this.maxScale = 2.5,
    List<DrawObjectAdapter> adapters = const [
      PanZoomAdapter(),
      DrawPencilAdapter(),
      DrawRectangleAdapter(),
      DrawRectangleCrossAdapter(),
    ],
    required this.child,
    this.onAdd,
    this.onChange,
    this.restorationId,
  })  : adapters = Map<String, DrawObjectAdapter>.fromIterable(adapters,
            key: (a) => a.typeId),
        super(key: key);

  final WindowPaintController? controller;
  final TransformationController? transformationController;
  final double minScale;
  final double maxScale;
  final Map<String, DrawObjectAdapter> adapters;
  final Widget child;

  /// Called when an object has been added by the user interactively through
  /// the UI.
  ///
  /// Will not get triggered on programmatically added objects.
  final OnAddCallback? onAdd;

  /// Called when a *selected* object has been changed by the user interactively
  /// through the UI.
  ///
  /// Will not get triggered on programmatically changed objects.
  final OnChangeCallback? onChange;

  /// Restoration ID to save and restore the state of the window paint widget.
  ///
  /// If non-null, and no [controller] has been provided, the window paint
  /// widget will persist and restore its current paint mode and color. If a
  /// [controller] has been provided, it is the responsibility of the owner of
  /// that controller to persist and restore it, e.g. by using
  /// a [RestorableWindowPaintController].
  ///
  /// The state of this widget is persisted in a [RestorationBucket] claimed
  /// from the surrounding [RestorationScope] using the provided restoration ID.
  ///
  /// See also:
  ///
  ///  * [RestorationManager], which explains how state restoration works in
  ///    Flutter.
  final String? restorationId;

  @override
  _WindowPaintState createState() => _WindowPaintState();
}

class _WindowPaintState extends State<WindowPaint> with RestorationMixin {
  RestorableWindowPaintController? _controller;
  WindowPaintController get _effectiveController =>
      widget.controller ?? _controller!.value;

  late final TransformationController _transformationController;

  /// Used by [_transformationController]'s listener to discard any
  /// transformation when [panScaleEnabled] is [false].
  late Matrix4 _lockedTransform;

  /// Used to signal [CustomPaint.willChange] so that the raster cache knows
  /// that the painter most likely will change next frame.
  var _hasActiveInteraction = false;

  /// The [Future] returned by the adapter's [start] method, if any. Signals to
  /// [onInteractiveUpdate] and [onInteractiveEnd] that they should discard
  /// their events for this interaction.
  Future<DrawObject?>? _pendingObject;

  DrawObjectAdapter get _activeAdapter =>
      widget.adapters[_effectiveController.mode]!;

  /// The current size of the painting surface's child. This is used to
  /// calculate the relative coordinates, as to not depend on the screen size.
  Size? _size;

  /// The value of [_size] at the start of this interaction. This is a safeguard
  /// in case [_onMeasure] gets called in the middle of an interaction.
  Size? _interactionSize;

  /// A clone of the object being selected during [_onInteractionStart].
  /// This is used to compare it to the same object in [_onInteractionEnd] and
  /// ultimately trigger `widget.onChange` if it has changed.
  DrawObject? _interactionObject;

  bool _hasInteractionSize() {
    return _interactionSize != null;
  }

  Offset _normalizeInteractionOffset(Offset offset) {
    final size = _interactionSize;
    if (size == null) {
      throw StateError('[_interactionSize] must not be null');
    }
    return offset.scale(1.0 / size.width, 1.0 / size.height);
  }

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _createLocalController();
    }

    _transformationController = widget.transformationController != null
        ? TransformationController(widget.transformationController!.value)
        : TransformationController();
    _lockedTransform = _transformationController.value;
    _transformationController.addListener(_onTransformationControllerChange);
    widget.transformationController
        ?.addListener(_onParentTransformationControllerChange);
  }

  @override
  void didUpdateWidget(WindowPaint oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && oldWidget.controller != null) {
      _createLocalController(oldWidget.controller!.value);
    } else if (widget.controller != null && oldWidget.controller == null) {
      unregisterFromRestoration(_controller!);
      _controller!.dispose();
      _controller = null;
    }

    if (widget.transformationController == null &&
        oldWidget.transformationController != null) {
      oldWidget.transformationController!
          .removeListener(_onParentTransformationControllerChange);
    } else if (widget.transformationController != null &&
        oldWidget.transformationController == null) {
      widget.transformationController!
          .addListener(_onParentTransformationControllerChange);
    }
  }

  void _onTransformationControllerChange() {
    /// In newer versions of [InteractiveViewer], the [onInteractionUpdate]
    /// callback is not called when [panScaleEnabled] is [false].
    ///
    /// To overcome this limitation, we have to manually reset the
    /// transformation with the [transformationController].
    ///
    /// We also do this if an object is selected.
    if (_activeAdapter.panScaleEnabled && !_effectiveController.isSelecting) {
      _lockedTransform = _transformationController.value;

      /// This two-way relationship between the parent and
      /// local [TransformationController] could cause infinite
      /// nested callbacks.
      ///
      /// Therefore we need to check if the value is different before notifying
      /// listeners of any change.
      if (widget.transformationController != null &&
          widget.transformationController?.value !=
              _transformationController.value) {
        widget.transformationController?.value =
            _transformationController.value;
      }
    } else if (_transformationController.value != _lockedTransform) {
      _transformationController.value = _lockedTransform;
    }
  }

  void _onParentTransformationControllerChange() {
    _lockedTransform = widget.transformationController!.value;

    /// This two-way relationship between the parent and
    /// local [TransformationController] could cause infinite nested callbacks.
    ///
    /// Therefore we need to check if the value is different before notifying
    /// listeners of any change.
    if (_transformationController.value !=
        widget.transformationController!.value) {
      _transformationController.value = widget.transformationController!.value;
    }
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    if (_controller != null) {
      _registerController();
    }
  }

  void _registerController() {
    assert(_controller != null);
    registerForRestoration(_controller!, 'controller');
  }

  void _createLocalController([WindowPaintValue? value]) {
    assert(_controller == null);
    _controller = value == null
        ? RestorableWindowPaintController(widget.adapters.values.toList())
        : RestorableWindowPaintController.fromValue(
            widget.adapters.values.toList(), value);
    if (!restorePending) {
      _registerController();
    }
  }

  @override
  String? get restorationId => widget.restorationId;

  @override
  void dispose() {
    _controller?.dispose();
    widget.transformationController
        ?.removeListener(_onParentTransformationControllerChange);
    _transformationController.removeListener(_onTransformationControllerChange);
    _transformationController.dispose();
    super.dispose();
  }

  void _onMeasure(Size size, BoxConstraints? constraints) {
    // We do not want to call [setState] here, as we don't use it in
    // the [build] method.
    _size = size;
  }

  @override
  Widget build(BuildContext context) {
    return Measurer(
      onMeasure: _onMeasure,
      child: ClipRect(
        child: InteractiveViewer(
          transformationController: _transformationController,
          minScale: widget.minScale,
          maxScale: widget.maxScale,
          onInteractionStart: (details) =>
              _onInteractionStart(context, details),
          onInteractionUpdate: _onInteractionUpdate,
          onInteractionEnd: _onInteractionEnd,
          child: ValueListenableBuilder<WindowPaintValue>(
            valueListenable: _effectiveController,
            builder: (context, value, child) {
              return Stack(
                children: [
                  child!,
                  ...value.objects.map((object) {
                    return Positioned.fill(
                      child: CustomPaint(
                        painter: WindowPaintPainter(
                          object: object,
                        ),
                        willChange: _hasActiveInteraction,
                      ),
                    );
                  }).toList(),
                ],
              );
            },
            child: widget.child,
          ),
        ),
      ),
    );
  }

  Future<void> _onInteractionStart(
    BuildContext context,
    ScaleStartDetails details,
  ) async {
    _interactionSize = _size;
    if (!_hasInteractionSize()) {
      return;
    }
    final focalPoint = _normalizeInteractionOffset(
      _transformationController.toScene(
        details.localFocalPoint,
      ),
    );
    final transform = _transformationController.value.clone();
    if (_attemptToSelect(focalPoint, transform)) {
      _interactionObject = _effectiveController.selectedObject!.clone();
      return;
    }
    final pending = _activeAdapter.start(
      context,
      focalPoint,
      _effectiveController.color,
      transform,
      _interactionSize!,
    );
    if (pending is DrawObject?) {
      _onInteractionStartSync(pending);
    } else {
      await _onInteractionStartAsync(pending);
    }
  }

  /// Attempts to select an object and returns [true] if an object is
  /// being selected.
  bool _attemptToSelect(Offset focalPoint, Matrix4 transform) {
    void _selectIfNoneAlready() {
      if (!_effectiveController.isSelecting) {
        _trySelectObject(focalPoint, transform);
      }
    }

    bool _attemptInteraction() {
      if (_effectiveController.isSelecting) {
        _onInteractionStartSelected(focalPoint, transform);
      }
      return _effectiveController.isSelecting;
    }

    _selectIfNoneAlready();
    if (!_attemptInteraction()) {
      _selectIfNoneAlready();
      _attemptInteraction();
    }

    return _effectiveController.isSelecting;
  }

  void _onInteractionStartSelected(Offset focalPoint, Matrix4 transform) {
    final object = _effectiveController.selectedObject!;
    if (object.adapter.selectedStart(
      object,
      focalPoint,
      transform,
      _interactionSize!,
    )) {
      _startInteraction();
    } else {
      _cancelSelectObject();
    }
  }

  void _onInteractionStartSync(DrawObject? object) {
    if (object != null) {
      _addObject(object);
      _startInteraction();
    }
  }

  Future<void> _onInteractionStartAsync(Future<DrawObject?> pending) async {
    DrawObject? onAddObject;

    /// We do not need to call [setState] when setting [_pendingObject] as it's
    /// not used in the [build] method.
    _pendingObject = pending;
    final object = await pending;
    if (object != null) {
      onAddObject = object.clone();
      _addObject(object);
    }

    // We call this last, just to be sure we don't introduce any side effects
    // with the state.
    if (onAddObject != null) {
      widget.onAdd?.call(onAddObject);
    }
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    if (_pendingObject != null) {
      return;
    }
    if (_hasActiveInteraction) {
      final focalPoint = _normalizeInteractionOffset(
        _transformationController.toScene(
          details.localFocalPoint,
        ),
      );
      final transform = _transformationController.value.clone();
      final selectedObject = _effectiveController.selectedObject;
      final repaint = selectedObject != null
          ? selectedObject.adapter.selectedUpdate(
              selectedObject,
              focalPoint,
              transform,
              _interactionSize!,
            )
          : _effectiveController.objects.last.adapter.update(
              _effectiveController.objects.last,
              focalPoint,
              _effectiveController.color,
              transform,
              _interactionSize!,
            );
      if (repaint) {
        setState(() {});
      }
    }
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    // Keep a copy of the interaction size for the `object.adapter.end` method
    final tempInteractionSize = _interactionSize;
    _interactionSize = null;

    // Keep a copy of the interaction object for the [detectChange] method
    final onChangeObjectFrom = _interactionObject;
    _interactionObject = null;

    DrawObject? onChangeObjectTo;
    DrawObject? onAddObject;

    void detectChange(DrawObject object) {
      if (onChangeObjectFrom != null) {
        // Make sure it's still the same object
        if (onChangeObjectFrom.id == object.id) {
          final equals = const DeepCollectionEquality().equals;
          if (!equals(onChangeObjectFrom.toJSON(), object.toJSON())) {
            onChangeObjectTo = object.clone();
          }
        }
      }
    }

    if (_pendingObject != null) {
      /// We do not need to call [setState] when setting [_pendingObject] as
      /// it's not used in the [build] method.
      _pendingObject = null;
      return;
    }
    if (_hasActiveInteraction) {
      if (_effectiveController.isSelecting) {
        final object = _effectiveController.selectedObject!;
        final remain = object.adapter.selectedEnd(object);
        if (!remain) {
          _cancelSelectObject();
        }
        detectChange(object);
      } else {
        final object = _effectiveController.objects.last;
        final keep = object.adapter.end(
          object,
          _effectiveController.color,
          tempInteractionSize!,
        );
        if (keep) {
          onAddObject = object.clone();
        } else {
          _removeObject(object);
        }
      }
      _endInteraction();
    }

    // We call these last, just to be sure we don't introduce any side effects
    // with the state.
    if (onChangeObjectFrom != null && onChangeObjectTo != null) {
      widget.onChange?.call(onChangeObjectFrom, onChangeObjectTo!);
    }
    if (onAddObject != null) {
      widget.onAdd?.call(onAddObject);
    }
  }

  bool _trySelectObject(Offset focalPoint, Matrix4 transform) {
    if (_activeAdapter.selectEnabled) {
      for (final object in _effectiveController.objects.reversed) {
        if (object.adapter.querySelect(
          object,
          focalPoint,
          transform,
          _interactionSize!,
        )) {
          _selectObject(object);
          return true;
        }
      }
    }
    return false;
  }

  void _startInteraction() {
    setState(() {
      _hasActiveInteraction = true;
    });
  }

  void _endInteraction() {
    setState(() {
      _hasActiveInteraction = false;
      _effectiveController.objectWasUpdated();
    });
  }

  void _addObject(DrawObject object) {
    _effectiveController.addObject(object);
  }

  void _removeObject(DrawObject object) {
    _effectiveController.removeObject(object);
  }

  void _selectObject(DrawObject object) {
    final index = _effectiveController.objects.indexOf(object);
    object.adapter.select(object);
    _effectiveController.selectObject(index);
  }

  void _cancelSelectObject() {
    final object = _effectiveController.selectedObject;
    if (object != null) {
      object.adapter.cancelSelect(object);
      _effectiveController.cancelSelectObject();
    }
    _endInteraction();
  }
}
