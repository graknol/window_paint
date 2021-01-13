import 'dart:async';
import 'dart:ui';

import 'package:example/draw/objects/draw_text.dart';
import 'package:flutter/material.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';
import 'package:window_paint/src/draw/draw_point.dart';

class DrawTextAdapter extends DrawObjectAdapter<DrawText> {
  const DrawTextAdapter();

  @override
  FutureOr<DrawText?> start(
    BuildContext context,
    Offset focalPoint,
    Color color,
    Matrix4 transform,
  ) async {
    final point = _createPoint(focalPoint, color);
    final text = await showInputDialog(context);
    if (text != null && text.isNotEmpty) {
      return DrawText(
        anchor: point,
        text: text,
        fontSize: 16.0 / transform.getMaxScaleOnAxis(),
      );
    }
    return null;
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
      paint: Paint()..color = color,
    );
  }

  Future<String?> showInputDialog(BuildContext context) async {
    var text = '';
    return await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Text input'),
          content: TextField(
            onChanged: (value) => text = value.trim(),
          ),
          actions: [
            FlatButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop('');
              },
            ),
            FlatButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(text);
              },
            ),
          ],
        );
      },
    );
  }
}