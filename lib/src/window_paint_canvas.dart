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
  final objects = <DrawObject>[];

  Future<DrawObject?>? _pendingObject;
  var _hasActiveInteraction = false;
  late Matrix4 _lockedTransform;

  @override
  void initState() {
    super.initState();
    _lockedTransform = _transformationController.value;
    _transformationController.addListener(() {
      /// In newer versions of [InteractiveViewer], the [onInteractionUpdate]
      /// callback is not called when [panEnabled] and [scaleEnabled] are false.
      ///
      /// To overcome this limitation, we have to manually reset the
      /// transformation with the [transformationController].
      if (widget.adapter.panEnabled || widget.adapter.scaleEnabled) {
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
          objects: objects,
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
    final pending = widget.adapter.start(
      context,
      focalPointScene,
      widget.color,
      _transformationController.value.clone(),
    );
    if (pending is DrawObject?) {
      final object = pending;
      if (object != null) {
        setState(() {
          objects.add(object);
          _hasActiveInteraction = true;
        });
      }
    } else {
      _pendingObject = pending;
      final object = await pending;
      if (object != null) {
        setState(() {
          objects.add(object);
        });
      }
    }
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    if (_pendingObject != null) {
      return;
    }
    final object = objects.last;
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
      _pendingObject = null;
      return;
    }
    final object = objects.last;
    setState(() {
      final keep = widget.adapter.end(object, widget.color);
      if (!keep) {
        objects.removeLast();
      }
      _hasActiveInteraction = false;
    });
  }
}
