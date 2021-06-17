import 'dart:async';
import 'dart:ui';

import 'package:example/draw/objects/draw_text.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:window_paint/src/draw/draw_object_adapter.dart';
import 'package:window_paint/src/draw/draw_point.dart';

class DrawTextAdapter extends DrawObjectAdapter<DrawText> {
  const DrawTextAdapter();

  /// Used to generate unique IDs for each [DrawPencil].
  final _uuid = const Uuid();

  @override
  String get typeId => 'text';

  @override
  FutureOr<DrawText?> start(
    BuildContext context,
    Offset focalPoint,
    Color color,
    Matrix4 transform,
    Size size,
  ) async {
    final point = _createPoint(focalPoint, transform);
    final text = await showInputDialog(context);
    if (text != null && text.isNotEmpty) {
      return DrawText(
        adapter: this,
        id: _uuid.v4(),
        anchor: point,
        text: text,
        color: color,
        fontSize: 16.0 / transform.getMaxScaleOnAxis(),
      );
    }
    return null;
  }

  @override
  bool update(
    DrawText object,
    Offset focalPoint,
    Color color,
    Matrix4 transform,
    Size size,
  ) {
    return false;
  }

  @override
  bool end(
    DrawText object,
    Color color,
    Size size,
  ) {
    return true;
  }

  @override
  bool querySelect(
    DrawText object,
    Offset focalPoint,
    Matrix4 transform,
    Size size,
  ) {
    return object
        .getHitboxes(size)
        .any((hitbox) => hitbox.contains(focalPoint));
  }

  @override
  void select(DrawText object) {
    object.showSelectOutline();
  }

  @override
  void cancelSelect(DrawText object) {
    object.hideSelectOutline();
  }

  @override
  bool selectedStart(
    DrawText object,
    Offset focalPoint,
    Matrix4 transform,
    Size size,
  ) {
    if (object.getHitboxes(size).any((hitbox) => hitbox.contains(focalPoint))) {
      object.prepareDragHandle(focalPoint);
      return true;
    }
    return false;
  }

  @override
  bool selectedUpdate(
    DrawText object,
    Offset focalPoint,
    Matrix4 transform,
    Size size,
  ) {
    object.updateDragHandle(focalPoint);
    return true;
  }

  @override
  bool selectedEnd(DrawText object) {
    object.finalizeDragHandle();
    return true;
  }

  @override
  void selectUpdateColor(DrawText object, Color color) {
    object.color = color;
  }

  @override
  DrawText fromJSON(Map encoded) => DrawText.fromJSON(this, encoded);

  DrawPoint _createPoint(Offset offset, Matrix4 transform) {
    return DrawPoint(
      offset: offset,
      scale: transform.getMaxScaleOnAxis(),
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
