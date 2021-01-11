import 'package:flutter/widgets.dart';

abstract class DrawObject {
  void paint(Canvas canvas, Size size);
  bool shouldRepaint();
  void finalize();
}
