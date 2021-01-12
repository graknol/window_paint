import 'package:window_paint/draw/adapters/draw_pencil_adapter.dart';
import 'package:window_paint/draw/adapters/draw_rectangle_adapter.dart';
import 'package:window_paint/draw/adapters/draw_rectangle_cross_adapter.dart';
import 'package:window_paint/draw/adapters/pan_zoom_adapter.dart';
import 'package:window_paint/draw/draw_object_adapter.dart';
import 'package:window_paint/window_paint_canvas.dart';
import 'package:window_paint/window_paint_controller.dart';
import 'package:flutter/widgets.dart';

class WindowPaint extends StatefulWidget {
  final Widget child;
  final WindowPaintController? controller;
  final Map<String, DrawObjectAdapter> adapters;

  WindowPaint({
    Key? key,
    this.controller,
    this.adapters = const {
      'pan_zoom': PanZoomAdapter(),
      'pencil': DrawPencilAdapter(),
      'rectangle': DrawRectangleAdapter(),
      'rectangle_cross': DrawRectangleCrossAdapter(),
    },
    required this.child,
  }) : super(key: key);

  @override
  _WindowPaintState createState() => _WindowPaintState();
}

class _WindowPaintState extends State<WindowPaint> {
  late WindowPaintController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? WindowPaintController();

    _controller.addListener(() {
      setState(() {
        // Trigger rebuild due to change in enabled controls.
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: WindowPaintCanvas(
        color: _controller.color,
        adapter: widget.adapters[_controller.mode]!,
        child: widget.child,
      ),
    );
  }
}
