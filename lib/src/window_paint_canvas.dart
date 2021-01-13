import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:window_paint/src/draw/draw_object.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';
import 'package:window_paint/src/window_paint_painter.dart';

class WindowPaintCanvas extends StatefulWidget {
  final Color color;
  final DrawObjectAdapter adapter;
  final Widget child;

  const WindowPaintCanvas({
    Key? key,
    this.color = const Color(0xFF000000),
    required this.adapter,
    required this.child,
  }) : super(key: key);

  @override
  _WindowPaintCanvasState createState() => _WindowPaintCanvasState();
}

class _WindowPaintCanvasState extends State<WindowPaintCanvas> {
  final _transformationController = TransformationController();

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

  @override
  void initState() {
    super.initState();
    _lockedTransform = _transformationController.value;
    _transformationController.addListener(() {
      /// In newer versions of [InteractiveViewer], the [onInteractionUpdate]
      /// callback is not called when [panScaleEnabled] is [false].
      ///
      /// To overcome this limitation, we have to manually reset the
      /// transformation with the [transformationController].
      if (widget.adapter.panScaleEnabled) {
        _lockedTransform = _transformationController.value;
      } else if (_transformationController.value != _lockedTransform) {
        _transformationController.value = _lockedTransform;
      }
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _transformationController,
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
    final focalPointScene = _transformationController.toScene(
      details.localFocalPoint,
    );
    final transform = _transformationController.value.clone();
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

  void _onInteractionStartSync(DrawObject? object) {
    if (object != null) {
      setState(() {
        _objects.add(object);
        _hasActiveInteraction = true;
      });
    }
  }

  Future<void> _onInteractionStartAsync(Future<DrawObject?> pending) async {
    /// We do not need to call [setState] when setting [_pendingObject] as it's
    /// not used in the [build] method.
    _pendingObject = pending;
    final object = await pending;
    if (object != null) {
      setState(() {
        _objects.add(object);
      });
    }
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    if (_pendingObject != null) {
      return;
    }
    final object = _objects.last;
    final focalPointScene = _transformationController.toScene(
      details.localFocalPoint,
    );
    final repaint = widget.adapter.update(
      object,
      focalPointScene,
      widget.color,
    );
    if (repaint) {
      setState(() {});
    }
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    if (_pendingObject != null) {
      /// We do not need to call [setState] when setting [_pendingObject] as
      /// it's not used in the [build] method.
      _pendingObject = null;
      return;
    }
    final object = _objects.last;
    setState(() {
      final keep = widget.adapter.end(object, widget.color);
      if (!keep) {
        _objects.removeLast();
      }
      _hasActiveInteraction = false;
    });
  }
}
