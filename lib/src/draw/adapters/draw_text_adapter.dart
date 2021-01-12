import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';
import 'package:window_paint/src/draw/draw_point.dart';
import 'package:window_paint/src/draw/objects/draw_text.dart';

class DrawTextAdapter extends DrawObjectAdapter<DrawText> {
  const DrawTextAdapter();

  @override
  FutureOr<DrawText?> start(
      BuildContext context, Offset focalPoint, Color color) async {
    final point = _createPoint(focalPoint, color);
    final _textEditingController = TextEditingController();
    final text = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Text input'),
            content: TextField(
              controller: _textEditingController,
            ),
            actions: [
              FlatButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop(null);
                },
              ),
              FlatButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop(_textEditingController.text);
                },
              ),
            ],
          );
        });
    _textEditingController.dispose();
    if (text == null || text.isEmpty) {
      return null;
    }
    return DrawText(
      anchor: point,
      text: text,
    );
  }

  @override
  bool update(DrawText object, Offset focalPoint, Color color) {
    return false;
  }

  @override
  bool end(DrawText object, Color color) {
    return true;
  }

  DrawPoint _createPoint(Offset offset, Color color) {
    return DrawPoint(
      offset: offset,
      paint: Paint()
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
  }
}
