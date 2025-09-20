/// Window Paint v2.0 - A modern, extensible drawing widget for Flutter
/// 
/// This is a complete rewrite of the original window_paint library following
/// Flutter best practices with clean architecture, proper state management,
/// and enhanced extensibility.
/// 
/// ## Key Improvements in v2.0:
/// 
/// ### Clean Architecture
/// - Proper separation of concerns with domain, data, and presentation layers
/// - Interface-based design for better testability and extensibility
/// - Immutable state management following Flutter best practices
/// 
/// ### Type Safety
/// - Enum-based tool types instead of error-prone strings
/// - Strongly typed interfaces and data models
/// - Better error handling and validation
/// 
/// ### Extensibility
/// - Plugin-based architecture for adding new drawing tools
/// - Clean interfaces for implementing custom drawable objects
/// - Configurable tool settings and behavior
/// 
/// ### Better Serialization
/// - Well-structured JSON schema for easy server-side rendering
/// - Separate data models for clean serialization
/// - Metadata support for future extensions
/// 
/// ### Modern State Management
/// - Command pattern for undo/redo functionality
/// - Reactive state updates with ValueNotifier
/// - Proper disposal and memory management
/// 
/// ## Basic Usage:
/// 
/// ```dart
/// import 'package:window_paint/window_paint_v2.dart';
/// 
/// class MyPaintWidget extends StatelessWidget {
///   @override
///   Widget build(BuildContext context) {
///     final controller = WindowPaintController();
///     final tools = {
///       DrawToolType.pencil: PencilDrawingTool(),
///       DrawToolType.rectangle: RectangleDrawingTool(),
///     };
/// 
///     return WindowPaintV2(
///       controller: controller,
///       tools: tools,
///       child: Container(
///         width: 400,
///         height: 300,
///         color: Colors.white,
///       ),
///       onObjectAdded: (objectId) => print('Added: $objectId'),
///     );
///   }
/// }
/// ```
/// 
/// ## Adding Custom Tools:
/// 
/// ```dart
/// class MyCustomTool implements IDrawingTool {
///   @override
///   DrawToolType get toolType => DrawToolType.custom;
///   
///   // Implement the required methods...
/// }
/// ```
/// 
/// ## JSON Serialization:
/// 
/// ```dart
/// // Export drawing data
/// final jsonData = controller.exportToJson();
/// 
/// // Load drawing data
/// controller.loadFromJson(jsonData);
/// ```

library window_paint_v2;

// Domain layer exports
export 'src/v2/domain/entities/draw_tool_type.dart';
export 'src/v2/domain/interfaces/drawable_object.dart';
export 'src/v2/domain/interfaces/drawing_tool.dart';
export 'src/v2/domain/entities/pencil_drawable_object.dart';

// Data layer exports
export 'src/v2/data/models/draw_point_data.dart';
export 'src/v2/data/models/drawable_object_data.dart';

// Presentation layer exports
export 'src/v2/presentation/state/window_paint_state.dart';
export 'src/v2/presentation/state/window_paint_controller.dart';
export 'src/v2/presentation/widgets/window_paint_v2.dart';

// Tools exports
export 'src/v2/tools/pencil_drawing_tool.dart';