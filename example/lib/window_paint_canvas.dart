import 'package:example/draw/draw_point.dart';
import 'package:example/draw/objects/draw_pencil.dart';
import 'package:example/window_paint_painter.dart';
import 'package:flutter/widgets.dart';

class WindowPaintCanvas extends StatefulWidget {
  final bool panEnabled;
  final bool scaleEnabled;
  final bool paintEnabled;
  final Color color;
  final Widget child;

  const WindowPaintCanvas({
    Key key,
    this.panEnabled = true,
    this.scaleEnabled = true,
    this.paintEnabled = false,
    this.color = const Color(0xFF000000),
    @required this.child,
  })  : assert(panEnabled != null),
        assert(scaleEnabled != null),
        assert(paintEnabled != null),
        assert(color != null),
        assert(child != null),
        super(key: key);

  @override
  _WindowPaintCanvasState createState() => _WindowPaintCanvasState();
}

class _WindowPaintCanvasState extends State<WindowPaintCanvas> {
  final pencilObjects = List<DrawPencil>();

  @override
  void initState() {
    super.initState();
    _startNewPencilObject();
  }

  void _startNewPencilObject() {
    if (pencilObjects.isNotEmpty) {
      pencilObjects.last.finalize();
    }
    pencilObjects.add(DrawPencil());
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      panEnabled: widget.panEnabled,
      scaleEnabled: widget.scaleEnabled,
      onInteractionUpdate: widget.paintEnabled
          ? (details) {
              setState(() {
                final point = _createPoint(details.localFocalPoint);
                pencilObjects.last.addPoint(point);
              });
            }
          : null,
      onInteractionEnd: widget.paintEnabled
          ? (details) {
              setState(() {
                _startNewPencilObject();
              });
            }
          : null,
      child: CustomPaint(
        foregroundPainter: WindowPaintPainter(
          objects: pencilObjects,
        ),
        child: widget.child,
      ),
    );
  }

  DrawPoint _createPoint(Offset offset) {
    return DrawPoint(
      offset: offset,
      paint: Paint()
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true
        ..color = widget.color
        ..strokeWidth = 4,
    );
  }
}
