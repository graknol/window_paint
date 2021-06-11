import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:window_paint/src/draw/draw_object.dart';
import 'package:window_paint/src/draw/rect_paint.dart';

mixin SelectOutlineMixin on DrawObject {
  var _selected = false;

  bool? _paintedSelected;

  /// The dimensions and appearance of the outline to render when this
  /// is selected.
  RectPaint get selectOutline;

  /// Must be called in [shouldRepaint()].
  @protected
  bool shouldRepaintSelectOutline() => _selected != _paintedSelected;

  /// Paints the select outline if [showSelectOutline()] has been called.
  void paintSelectOutline(Canvas canvas, Size size) {
    if (_selected) {
      _paintOutline(canvas, selectOutline);
    }
    _paintedSelected = _selected;
  }

  void _paintOutline(Canvas canvas, RectPaint outline) {
    canvas.drawRect(outline.rect, outline.paint);
  }

  /// Shows the select outline.
  void showSelectOutline() {
    _selected = true;
  }

  /// Hides the select outline.
  void hideSelectOutline() {
    _selected = false;
  }
}
