import 'package:example/window_paint_canvas.dart';
import 'package:example/window_paint_control.dart';
import 'package:example/window_paint_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class WindowPaint extends StatefulWidget {
  final Widget child;
  final WindowPaintController controller;

  WindowPaint({
    Key key,
    this.controller,
    @required this.child,
  })  : assert(child != null),
        super(key: key);

  @override
  _WindowPaintState createState() => _WindowPaintState();
}

class _WindowPaintState extends State<WindowPaint> {
  WindowPaintController _controller;

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
    return Column(
      children: [
        WindowPaintControl(
          controller: _controller,
        ),
        ClipRect(
          child: WindowPaintCanvas(
            panEnabled: _controller.panEnabled,
            scaleEnabled: _controller.scaleEnabled,
            paintEnabled: _controller.paintEnabled,
            color: _controller.color,
            child: widget.child,
          ),
        ),
      ],
    );
  }
}
