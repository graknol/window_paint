import 'package:example/draw/draw_object.dart';
import 'package:example/draw/draw_object_adapter.dart';
import 'package:example/window_paint_painter.dart';
import 'package:flutter/widgets.dart';

class WindowPaintCanvas extends StatefulWidget {
  final Color color;
  final DrawObjectAdapter adapter;
  final Widget child;

  const WindowPaintCanvas({
    Key key,
    this.color = const Color(0xFF000000),
    @required this.adapter,
    @required this.child,
  })  : assert(color != null),
        assert(adapter != null),
        assert(child != null),
        super(key: key);

  @override
  _WindowPaintCanvasState createState() => _WindowPaintCanvasState();
}

class _WindowPaintCanvasState extends State<WindowPaintCanvas> {
  final transformationController = TransformationController();
  final objects = List<DrawObject>();

  @override
  void dispose() {
    transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: transformationController,
      panEnabled: widget.adapter.panEnabled,
      scaleEnabled: widget.adapter.scaleEnabled,
      onInteractionStart: _onInteractionStart,
      onInteractionUpdate: _onInteractionUpdate,
      onInteractionEnd: _onInteractionEnd,
      child: CustomPaint(
        foregroundPainter: WindowPaintPainter(
          objects: objects,
        ),
        child: widget.child,
      ),
    );
  }

  void _onInteractionStart(ScaleStartDetails details) {
    final focalPoint =
        transformationController.toScene(details.localFocalPoint);
    setState(() {
      final object = widget.adapter.start(focalPoint, widget.color);
      objects.add(object);
    });
  }

  void _onInteractionUpdate(ScaleUpdateDetails details) {
    final object = objects.last;
    final focalPoint = details.localFocalPoint;
    final repaint = widget.adapter.update(object, focalPoint, widget.color);
    if (repaint) {
      setState(() {});
    }
  }

  void _onInteractionEnd(ScaleEndDetails details) {
    final object = objects.last;
    setState(() {
      final keep = widget.adapter.end(object, widget.color);
      if (!keep) {
        objects.removeLast();
      }
    });
  }
}
