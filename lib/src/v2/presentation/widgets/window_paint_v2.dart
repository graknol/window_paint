import 'package:flutter/widgets.dart';
import 'package:window_paint/src/v2/domain/entities/draw_tool_type.dart';
import 'package:window_paint/src/v2/domain/interfaces/drawing_tool.dart';
import 'package:window_paint/src/v2/presentation/state/window_paint_controller.dart';
import 'package:window_paint/src/v2/presentation/state/window_paint_state.dart';

/// The main window paint widget for version 2.0.
/// 
/// This widget provides a clean, extensible API following Flutter best practices.
/// It offers improved state management, better separation of concerns, and 
/// enhanced extensibility compared to the original implementation.
class WindowPaintV2 extends StatefulWidget {
  const WindowPaintV2({
    super.key,
    this.controller,
    this.tools = const {},
    this.onObjectAdded,
    this.onObjectModified,
    this.onObjectRemoved,
    this.onStateChanged,
    required this.child,
    this.maxScale = 2.5,
    this.minScale = 0.1,
    this.transformationController,
  });

  /// Controller for managing the window paint state
  final WindowPaintController? controller;

  /// Map of available drawing tools
  final Map<DrawToolType, IDrawingTool> tools;

  /// Callback when an object is added interactively
  final void Function(String objectId)? onObjectAdded;

  /// Callback when an object is modified interactively
  final void Function(String objectId, Map<String, dynamic> changes)? onObjectModified;

  /// Callback when an object is removed interactively
  final void Function(String objectId)? onObjectRemoved;

  /// Callback when the state changes
  final void Function(WindowPaintState state)? onStateChanged;

  /// The child widget to paint over
  final Widget child;

  /// Maximum scale factor for zooming
  final double maxScale;

  /// Minimum scale factor for zooming
  final double minScale;

  /// Optional transformation controller for external control
  final TransformationController? transformationController;

  @override
  State<WindowPaintV2> createState() => _WindowPaintV2State();
}

class _WindowPaintV2State extends State<WindowPaintV2> {
  late WindowPaintController _controller;
  late TransformationController _transformationController;
  bool _controllerCreated = false;

  @override
  void initState() {
    super.initState();
    
    _controller = widget.controller ?? WindowPaintController(tools: widget.tools);
    _controllerCreated = widget.controller == null;
    
    _transformationController = widget.transformationController ?? TransformationController();
    
    // Set up callbacks
    _controller.onObjectAdded = _handleObjectAdded;
    _controller.onObjectModified = _handleObjectModified;
    _controller.onObjectRemoved = _handleObjectRemoved;
    
    // Register tools if not already registered
    widget.tools.forEach((type, tool) {
      _controller.registerTool(type, tool);
    });
    
    // Listen to state changes
    _controller.addListener(_handleStateChanged);
  }

  @override
  void didUpdateWidget(WindowPaintV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update tools if they changed
    if (widget.tools != oldWidget.tools) {
      widget.tools.forEach((type, tool) {
        _controller.registerTool(type, tool);
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleStateChanged);
    
    if (_controllerCreated) {
      _controller.dispose();
    }
    
    if (widget.transformationController == null) {
      _transformationController.dispose();
    }
    
    super.dispose();
  }

  void _handleObjectAdded(object) {
    widget.onObjectAdded?.call(object.id);
  }

  void _handleObjectModified(oldObject, newObject) {
    // Calculate changes between old and new object
    final changes = <String, dynamic>{
      'old': oldObject.toJson(),
      'new': newObject.toJson(),
    };
    widget.onObjectModified?.call(newObject.id, changes);
  }

  void _handleObjectRemoved(object) {
    widget.onObjectRemoved?.call(object.id);
  }

  void _handleStateChanged() {
    widget.onStateChanged?.call(_controller.value);
  }

  void _handlePanStart(ScaleStartDetails details) {
    final localPosition = details.localFocalPoint;
    final transform = _transformationController.value;
    
    if (_controller.activeTool == DrawToolType.panZoom) {
      // Handle pan/zoom start
      return;
    }
    
    // Handle drawing start
    _controller.startDrawing(
      context: context,
      point: localPosition,
      transform: transform,
    );
  }

  void _handlePanUpdate(ScaleUpdateDetails details) {
    final localPosition = details.localFocalPoint;
    final transform = _transformationController.value;
    
    if (_controller.activeTool == DrawToolType.panZoom) {
      // Handle pan/zoom update
      return;
    }
    
    // Handle drawing update
    if (_controller.isDrawing) {
      _controller.updateDrawing(
        point: localPosition,
        transform: transform,
      );
    }
  }

  void _handlePanEnd(ScaleEndDetails details) {
    if (_controller.activeTool == DrawToolType.panZoom) {
      // Handle pan/zoom end
      return;
    }
    
    // Handle drawing end
    if (_controller.isDrawing) {
      _controller.endDrawing();
    }
  }

  void _handleTap(TapDownDetails details) {
    final localPosition = details.localPosition;
    final transform = _transformationController.value;
    
    // Try to select an object
    _controller.selectObjectAt(
      point: localPosition,
      transform: transform,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<WindowPaintState>(
      valueListenable: _controller,
      builder: (context, state, child) {
        return InteractiveViewer(
          transformationController: _transformationController,
          maxScale: widget.maxScale,
          minScale: widget.minScale,
          child: GestureDetector(
            onScaleStart: _handlePanStart,
            onScaleUpdate: _handlePanUpdate,
            onScaleEnd: _handlePanEnd,
            onTapDown: _handleTap,
            child: CustomPaint(
              painter: _WindowPaintV2Painter(state),
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

/// Custom painter for rendering drawable objects
class _WindowPaintV2Painter extends CustomPainter {
  const _WindowPaintV2Painter(this.state);

  final WindowPaintState state;

  @override
  void paint(Canvas canvas, Size size) {
    // Create denormalization function
    Offset denormalize(Offset normalized) {
      return Offset(
        normalized.dx * size.width,
        normalized.dy * size.height,
      );
    }

    // Render all objects
    for (final object in state.objects) {
      try {
        object.render(canvas, size, denormalize);
      } catch (e) {
        debugPrint('Error rendering object ${object.id}: $e');
      }
    }
  }

  @override
  bool shouldRepaint(covariant _WindowPaintV2Painter oldDelegate) {
    return oldDelegate.state != state ||
        state.objects.any((obj) => obj.shouldRepaint());
  }
}