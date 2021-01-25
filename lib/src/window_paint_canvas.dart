import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:window_paint/src/draw/draw_object.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';
import 'package:window_paint/src/window_paint_painter.dart';

class WindowPaintCanvas extends StatefulWidget {
  const WindowPaintCanvas({
    Key? key,
    this.controller,
    this.color = const Color(0xFF000000),
    this.minScale = 1.0,
    this.maxScale = 2.5,
    this.onSelectionStart,
    this.onSelectionEnd,
    required this.adapter,
    required this.child,
  }) : super(key: key);

  final TransformationController? controller;
  final Color color;
  final double minScale;
  final double maxScale;
  final void Function(DrawObject)? onSelectionStart;
  final void Function(DrawObject)? onSelectionEnd;
  final DrawObjectAdapter adapter;
  final Widget child;

  @override
  _WindowPaintCanvasState createState() => _WindowPaintCanvasState();
}

class _WindowPaintCanvasState extends State<WindowPaintCanvas> {
  late final TransformationController _controller;

  /// List of drawable objects to render.
  final _objects = <DrawObject>[];

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

  /// Reference to the currently selected [DrawObject] in [_objects], if any.
  DrawObject? _selectedObject;

  /// Whether or not we're currently selecting a [DrawObject].
  bool get _isSelecting => _selectedObject != null;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller != null
        ? TransformationController(widget.controller!.value)
        : TransformationController();
    _lockedTransform = _controller.value;
    _controller.addListener(_onTransformationControllerChange);
    widget.controller?.addListener(_onParentTransformationControllerChange);
  }

  @override
  void didUpdateWidget(WindowPaintCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == null && oldWidget.controller != null) {
      oldWidget.controller!
          .removeListener(_onParentTransformationControllerChange);
    } else if (widget.controller != null && oldWidget.controller == null) {
      widget.controller!.addListener(_onParentTransformationControllerChange);
    }
    if (_isSelecting) {
      if (widget.color != oldWidget.color) {
        _selectedObject!.adapter
            .selectUpdateColor(_selectedObject!, widget.color);
      }
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
    if (widget.adapter.panScaleEnabled && _selectedObject == null) {
      _lockedTransform = _controller.value;

      /// This two-way relationship between the parent and
      /// local [TransformationController] could cause infinite
      /// nested callbacks.
      ///
      /// Therefore we need to check if the value is different before notifying
      /// listeners of any change.
      if (widget.controller != null &&
          widget.controller?.value != _controller.value) {
        widget.controller?.value = _controller.value;
      }
    } else if (_controller.value != _lockedTransform) {
      _controller.value = _lockedTransform;
    }
  }

  void _onParentTransformationControllerChange() {
    _lockedTransform = widget.controller!.value;

    /// This two-way relationship between the parent and
    /// local [TransformationController] could cause infinite nested callbacks.
    ///
    /// Therefore we need to check if the value is different before notifying
    /// listeners of any change.
    if (_controller.value != widget.controller!.value) {
      _controller.value = widget.controller!.value;
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onParentTransformationControllerChange);
    _controller.removeListener(_onTransformationControllerChange);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _controller,
      minScale: widget.minScale,
      maxScale: widget.maxScale,
      onInteractionStart: (details) => _onInteractionStart(context, details),
      onInteractionUpdate: _onInteractionUpdate,
      onInteractionEnd: _onInteractionEnd,
      child: CustomPaint(
        foregroundPainter: WindowPaintPainter(
          objects: _objects,
        ),
        willChange: _hasActiveInteraction,
        child: widget.child,
      ),
    );
  }

  Future<void> _onInteractionStart(
    BuildContext context,
    ScaleStartDetails details,
  ) async {
    final focalPointScene = _controller.toScene(
      details.localFocalPoint,
    );
    final transform = _controller.value.clone();
    if (_isSelecting) {
      _onInteractionStartSelected(_selectedObject!, focalPointScene, transform);
      if (_isSelecting) {
        return;
      }
    }
    if (_trySelectObject(focalPointScene, transform)) {
      return;
    }
    final pending = widget.adapter.start(
      context,
      focalPointScene,
      widget.color,
      transform,
    );
    if (pending is DrawObject?) {
      _onInteractionStartSync(pending);
    } else {
      await _onInteractionStartAsync(pending);
    }
  }

  void _onInteractionStartSelected(
    DrawObject object,
    Offset focalPoint,
    Matrix4 transform,
  ) {
    if (object.adapter.selectedStart(object, focalPoint, transform)) {
      _startInteraction();
    }
    _cancelSelectObject();
  }

  void _onInteractionStartSync(DrawObject? object) {
    if (object != null) {
      _addObject(object);
      _startInteraction();
    }
  }

  Future<void> _onInteractionStartAsync(Future<DrawObject?> pending) async {
    /// We do not need to call [setState] when setting [_pendingObject] as it's
    /// not used in the [build] method.
    _pendingObject = pending;
    final object = await pending;
    if (object != null) {
      _addObject(object);
    }
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    if (_pendingObject != null) {
      return;
    }
    if (_hasActiveInteraction) {
      final focalPointScene = _controller.toScene(
        details.localFocalPoint,
      );
      final transform = _controller.value.clone();
      final repaint = _isSelecting
          ? _selectedObject!.adapter.selectedUpdate(
              _selectedObject!,
              focalPointScene,
              transform,
            )
          : widget.adapter.update(
              _objects.last,
              focalPointScene,
              widget.color,
              transform,
            );
      if (repaint) {
        setState(() {});
      }
    }
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    if (_pendingObject != null) {
      /// We do not need to call [setState] when setting [_pendingObject] as
      /// it's not used in the [build] method.
      _pendingObject = null;
      return;
    }
    if (_hasActiveInteraction) {
      if (_isSelecting) {
        final remain = _selectedObject!.adapter.selectedEnd(_selectedObject!);
        if (!remain) {
          _cancelSelectObject();
        }
      } else {
        final object = _objects.last;
        final keep = object.adapter.end(object, widget.color);
        if (!keep) {
          _removeLastObject();
        }
      }
      _endInteraction();
    }
  }

  bool _trySelectObject(Offset focalPoint, Matrix4 transform) {
    if (widget.adapter.selectEnabled) {
      for (final object in _objects.reversed) {
        if (object.adapter.querySelect(object, focalPoint, transform)) {
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
    });
  }

  void _addObject(DrawObject object) {
    setState(() {
      _objects.add(object);
    });
  }

  void _removeLastObject() {
    setState(() {
      _objects.removeLast();
    });
  }

  void _selectObject(DrawObject object) {
    _selectedObject = object;
    object.adapter.select(object);
    widget.onSelectionStart?.call(_selectedObject!);
  }

  void _cancelSelectObject() {
    final object = _selectedObject!;
    widget.onSelectionEnd?.call(object);
    object.adapter.cancelSelect(object);
    _selectedObject = null;
    _endInteraction();
  }
}
