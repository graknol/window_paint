import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:window_paint/window_paint_simple.dart';

// Extension to access private members for testing
extension WindowPaintControllerTesting on WindowPaintController {
  Size get testCanvasSize => _canvasSize;
  set testCanvasSize(Size size) => _canvasSize = size;
  
  List<DrawingObject> get testDrawings => _drawings;
  DrawingObject? get testCurrentDrawing => _currentDrawing;
  
  void addTestDrawing(DrawingObject drawing) {
    _drawings.add(drawing);
  }
}

void main() {
  group('WindowPaintController Internal Methods', () {
    late WindowPaintController controller;

    setUp(() {
      controller = WindowPaintController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('should normalize points correctly', () {
      controller.testCanvasSize = const Size(200, 400);
      
      final normalized = controller._normalizePoint(const Offset(100, 200));
      
      expect(normalized.dx, closeTo(0.5, 0.001)); // 100/200 = 0.5
      expect(normalized.dy, closeTo(0.5, 0.001)); // 200/400 = 0.5
    });

    test('should handle zero canvas size gracefully', () {
      controller.testCanvasSize = Size.zero;
      
      final point = const Offset(100, 200);
      final normalized = controller._normalizePoint(point);
      
      expect(normalized, equals(point)); // Should return original point
    });

    test('should create pencil drawing correctly', () {
      final params = _DrawingParams(
        point: const Offset(0.5, 0.5),
        color: Colors.red.value,
        strokeWidth: 3.0,
      );

      final pencil = controller._createPencilDrawing(params);

      expect(pencil, isA<PencilDrawing>());
      expect(pencil.color, equals(Colors.red.value));
      expect(pencil.strokeWidth, equals(3.0));
      expect(pencil.points.first, equals(const Offset(0.5, 0.5)));
    });

    test('should create rectangle drawing correctly', () {
      final params = _DrawingParams(
        point: const Offset(0.2, 0.3),
        color: Colors.blue.value,
        strokeWidth: 4.0,
      );

      final rectangle = controller._createRectangleDrawing(params);

      expect(rectangle, isA<RectangleDrawing>());
      expect(rectangle.color, equals(Colors.blue.value));
      expect(rectangle.strokeWidth, equals(4.0));
      expect(rectangle.startPoint, equals(const Offset(0.2, 0.3)));
      expect(rectangle.endPoint, equals(const Offset(0.2, 0.3)));
    });

    test('should create circle drawing correctly', () {
      final params = _DrawingParams(
        point: const Offset(0.7, 0.8),
        color: Colors.green.value,
        strokeWidth: 5.0,
      );

      final circle = controller._createCircleDrawing(params);

      expect(circle, isA<CircleDrawing>());
      expect(circle.color, equals(Colors.green.value));
      expect(circle.strokeWidth, equals(5.0));
      expect(circle.center, equals(const Offset(0.7, 0.8)));
      expect(circle.radius, equals(0.0));
    });

    test('should find drawing at point correctly', () {
      // Add multiple drawings
      final pencil = PencilDrawing.start(
        point: const Offset(0.1, 0.1),
        color: Colors.red.value,
        strokeWidth: 2.0,
      );
      pencil.update(const Offset(0.3, 0.3));

      final rectangle = RectangleDrawing.start(
        point: const Offset(0.5, 0.5),
        color: Colors.blue.value,
        strokeWidth: 2.0,
      );
      rectangle.update(const Offset(0.9, 0.9));

      controller.addTestDrawing(pencil);
      controller.addTestDrawing(rectangle);

      // Should find the last added drawing (rectangle) first
      final found = controller._findDrawingAt(const Offset(0.7, 0.5));
      expect(found, equals(rectangle));

      // Should return null for points not hitting any drawing
      final notFound = controller._findDrawingAt(const Offset(0.0, 0.0));
      expect(notFound, isNull);
    });

    test('should select and clear selection correctly', () {
      final pencil = PencilDrawing.start(
        point: const Offset(0.5, 0.5),
        color: Colors.purple.value,
        strokeWidth: 2.0,
      );

      controller._selectDrawing(pencil);

      expect(controller.selectedId, equals(pencil.id));
      expect(controller.color, equals(Color(pencil.color)));

      controller._clearSelection();

      expect(controller.selectedId, isNull);
    });

    test('should start drawing with different tools', () {
      controller.testCanvasSize = const Size(100, 100);

      // Test pencil
      controller.setTool(DrawingTool.pencil);
      controller._startDrawing(const Offset(50, 50), Matrix4.identity(), const Size(100, 100));
      
      expect(controller.drawings, hasLength(1));
      expect(controller.drawings.first, isA<PencilDrawing>());

      // Clear and test rectangle
      controller.clearAll();
      controller.setTool(DrawingTool.rectangle);
      controller._startDrawing(const Offset(25, 25), Matrix4.identity(), const Size(100, 100));
      
      expect(controller.drawings, hasLength(1));
      expect(controller.drawings.first, isA<RectangleDrawing>());

      // Clear and test circle
      controller.clearAll();
      controller.setTool(DrawingTool.circle);
      controller._startDrawing(const Offset(75, 75), Matrix4.identity(), const Size(100, 100));
      
      expect(controller.drawings, hasLength(1));
      expect(controller.drawings.first, isA<CircleDrawing>());

      // Test pan tool (should not create drawing)
      controller.clearAll();
      controller.setTool(DrawingTool.pan);
      controller._startDrawing(const Offset(50, 50), Matrix4.identity(), const Size(100, 100));
      
      expect(controller.drawings, isEmpty);
    });

    test('should update current drawing', () {
      controller.testCanvasSize = const Size(100, 100);
      controller.setTool(DrawingTool.pencil);
      
      // Start drawing
      controller._startDrawing(const Offset(10, 10), Matrix4.identity(), const Size(100, 100));
      final pencil = controller.drawings.first as PencilDrawing;
      expect(pencil.points, hasLength(1));

      // Update drawing
      controller._updateDrawing(const Offset(20, 20), Matrix4.identity());
      expect(pencil.points, hasLength(2));
      expect(pencil.points.last, equals(const Offset(0.2, 0.2))); // Normalized

      // Update again
      controller._updateDrawing(const Offset(30, 30), Matrix4.identity());
      expect(pencil.points, hasLength(3));
      expect(pencil.points.last, equals(const Offset(0.3, 0.3)));
    });

    test('should end drawing correctly', () {
      controller.testCanvasSize = const Size(100, 100);
      controller.setTool(DrawingTool.rectangle);
      
      // Start drawing
      controller._startDrawing(const Offset(10, 10), Matrix4.identity(), const Size(100, 100));
      controller._updateDrawing(const Offset(50, 50), Matrix4.identity());
      
      expect(controller.drawings, hasLength(1));
      expect(controller.testCurrentDrawing, isNotNull);

      // End drawing
      final completed = controller._endDrawing();
      
      expect(completed, isNotNull);
      expect(completed, isA<RectangleDrawing>());
      expect(controller.testCurrentDrawing, isNull);
    });

    test('should remove invalid drawings when ending', () {
      controller.testCanvasSize = const Size(100, 100);
      controller.setTool(DrawingTool.pencil);
      
      // Start drawing with only one point (invalid)
      controller._startDrawing(const Offset(10, 10), Matrix4.identity(), const Size(100, 100));
      
      expect(controller.drawings, hasLength(1));

      // End drawing without adding more points
      final completed = controller._endDrawing();
      
      expect(completed, isNull); // Should be null because invalid
      expect(controller.drawings, isEmpty); // Should be removed
    });

    test('should clear drawings and load from JSON', () {
      // Add some drawings
      final pencil = PencilDrawing.start(
        point: const Offset(0.1, 0.1),
        color: Colors.red.value,
        strokeWidth: 2.0,
      );
      controller.addTestDrawing(pencil);
      controller._selectedId = pencil.id;

      expect(controller.drawings, hasLength(1));
      expect(controller.selectedId, isNotNull);

      // Clear drawings
      controller._clearDrawings();

      expect(controller.drawings, isEmpty);
      expect(controller.selectedId, isNull);

      // Test loading from JSON
      final jsonData = [
        {
          'type': 'rectangle',
          'id': 'test-rect',
          'color': Colors.blue.value,
          'strokeWidth': 3.0,
          'startPoint': {'x': 0.2, 'y': 0.2},
          'endPoint': {'x': 0.8, 'y': 0.8},
        },
      ];

      controller._loadDrawingsFromJson(jsonData);

      expect(controller.drawings, hasLength(1));
      expect(controller.drawings.first, isA<RectangleDrawing>());
      expect(controller.drawings.first.id, equals('test-rect'));
    });

    test('should handle invalid JSON gracefully', () {
      final invalidJsonData = [
        {
          'type': 'unknown',
          'id': 'invalid',
        },
        {
          'type': 'pencil',
          // Missing required fields
        },
      ];

      controller._loadDrawingsFromJson(invalidJsonData);

      // Should not add any drawings for invalid JSON
      expect(controller.drawings, isEmpty);
    });
  });
}