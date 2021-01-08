import 'package:example/draw_point.dart';
import 'package:example/window_paint_painter.dart';
import 'package:flutter/widgets.dart';

class WindowPaintCanvas extends StatefulWidget {
  final Widget child;

  const WindowPaintCanvas({
    Key key,
    @required this.child,
  })  : assert(child != null),
        super(key: key);

  @override
  _WindowPaintCanvasState createState() => _WindowPaintCanvasState();
}

class _WindowPaintCanvasState extends State<WindowPaintCanvas> {
  final points = List<DrawPoint>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          final renderBox = context.findRenderObject() as RenderBox;
          final offset = renderBox.globalToLocal(details.globalPosition);
          points.add(_createPoint(offset));
        });
      },
      onPanStart: (details) {
        setState(() {
          final renderBox = context.findRenderObject() as RenderBox;
          final offset = renderBox.globalToLocal(details.globalPosition);
          points.add(_createPoint(offset));
        });
      },
      onPanEnd: (details) {
        setState(() {
          points.add(null);
        });
      },
      child: CustomPaint(
        foregroundPainter: WindowPaintPainter(
          points: points,
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
        ..color = Color(0xFFFF0000)
        ..strokeWidth = 4,
    );
  }
}
