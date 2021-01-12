import 'package:example/custom_radio.dart';
import 'package:example/custom_radio_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:window_paint/window_paint.dart';

class WindowPaintControl extends StatefulWidget {
  final WindowPaintController controller;

  const WindowPaintControl({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  _WindowPaintControlState createState() => _WindowPaintControlState();
}

class _WindowPaintControlState extends State<WindowPaintControl> {
  final _customRadioController = CustomRadioController();

  @override
  void initState() {
    super.initState();
    _customRadioController.addListener(_updateInteractivity);
    _updateInteractivity();
  }

  void _updateInteractivity() {
    setState(() {
      switch (_customRadioController.index) {
        case 0:
          widget.controller.mode = 'pan_zoom';
          break;
        case 1:
          widget.controller.mode = 'pencil';
          break;
        case 2:
          widget.controller.mode = 'rectangle';
          break;
        case 3:
          widget.controller.mode = 'rectangle_cross';
          break;
      }
    });
  }

  @override
  void dispose() {
    _customRadioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controls = _buildControls(context).toList();
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CustomRadio(
            controller: _customRadioController,
            itemCount: controls.length,
            itemBuilder: (context, index, isActive) {
              return Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: isActive ? Color(0xFFDFDFDF) : Colors.transparent,
                ),
                child: controls[index],
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.color_lens, color: widget.controller.color),
            onPressed: _showColorPicker,
          ),
        ],
      ),
    );
  }

  Iterable<Widget> _buildControls(BuildContext context) sync* {
    yield Icon(Icons.pan_tool, color: Colors.black);
    yield Icon(Icons.edit, color: Colors.black);
    yield Icon(Icons.crop_square, color: Colors.black);
    yield Stack(
      alignment: Alignment.center,
      children: [
        Icon(Icons.crop_square, color: Colors.black),
        Icon(Icons.close, color: Colors.black),
      ],
    );
  }

  Future<void> _showColorPicker() async {
    var pickedColor = widget.controller.color;
    final confirmed = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: widget.controller.color,
              onColorChanged: (color) {
                pickedColor = color;
              },
            ),
          ),
          actions: [
            FlatButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            FlatButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
    if (confirmed) {
      widget.controller.color = pickedColor;
    }
  }
}
