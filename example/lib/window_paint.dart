import 'package:example/custom_radio.dart';
import 'package:example/custom_radio_controller.dart';
import 'package:example/window_paint_canvas.dart';
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
  CustomRadioController _customRadioController;

  bool _panEnabled;
  bool _scaleEnabled;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? WindowPaintController();
    _customRadioController = CustomRadioController();

    _customRadioController.addListener(_updateInteractivity);
    _updateInteractivity();
  }

  void _updateInteractivity() {
    setState(() {
      _panEnabled = _scaleEnabled = _customRadioController.currentIndex == 0;
    });
  }

  @override
  void dispose() {
    _customRadioController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(color: Color(0xFFEFEFEF)),
          child: CustomRadio(
            controller: _customRadioController,
            itemCount: 2,
            itemBuilder: (context, index, isActive) {
              return Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isActive ? Colors.grey : Colors.transparent,
                ),
                child: Icon(
                  index == 0 ? Icons.pan_tool : Icons.edit,
                  color: Colors.black,
                ),
              );
            },
          ),
        ),
        ClipRect(
          child: InteractiveViewer(
            // child: WindowPaintCanvas(
            child: widget.child,
            // ),
            panEnabled: _panEnabled,
            scaleEnabled: _scaleEnabled,
          ),
        ),
      ],
    );
  }
}
