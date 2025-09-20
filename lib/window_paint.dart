/// Window Paint v1.x (Legacy) - Original implementation
/// 
/// This is the original window_paint implementation. While functional,
/// it has some architectural limitations. For new projects, consider
/// using the simple version or v2.0 which provide better architecture,
/// type safety, and extensibility.
/// 
/// Simple version: `import 'package:window_paint/window_paint_simple.dart';`
/// Full v2.0: `import 'package:window_paint/window_paint_v2.dart';`

export 'package:window_paint/src/draw/adapters/draw_pencil_adapter.dart';
export 'package:window_paint/src/draw/adapters/draw_rectangle_adapter.dart';
export 'package:window_paint/src/draw/adapters/draw_rectangle_cross_adapter.dart';
export 'package:window_paint/src/draw/adapters/pan_zoom_adapter.dart';
export 'package:window_paint/src/draw/draw_object.dart';
export 'package:window_paint/src/draw/draw_object_adapter.dart';
export 'package:window_paint/src/draw/draw_point.dart';
export 'package:window_paint/src/draw/rect_paint.dart';
export 'package:window_paint/src/geometry/line.dart';
export 'package:window_paint/src/mixins/drag_handle_mixin.dart';
export 'package:window_paint/src/mixins/select_outline_mixin.dart';
export 'package:window_paint/src/utils/draw_object_serialization.dart';
export 'package:window_paint/src/utils/simplify_utils.dart';
export 'package:window_paint/src/window_paint.dart';
export 'package:window_paint/src/window_paint_controller.dart';
export 'package:window_paint/src/window_paint_painter.dart';
