import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:window_paint/window_paint_simple.dart';

// Extension to access private members for testing
extension WindowPaintControllerTesting on WindowPaintController {
  List<DrawingObject> get testDrawings => drawings;
  Size get testCanvasSize => _canvasSize;
  set testCanvasSize(Size size) => _canvasSize = size;
  
  void addTestDrawing(DrawingObject drawing) {
    _drawings.add(drawing);
    notifyListeners();
  }
  
  void setTestSelectedId(String? id) {
    _selectedId = id;
    notifyListeners();
  }
}

void main() {
  group('DrawingTool enum', () {
    test('should have all expected tools', () {
      expect(DrawingTool.values, hasLength(5)); // Updated count
      expect(DrawingTool.values, contains(DrawingTool.pan));
      expect(DrawingTool.values, contains(DrawingTool.pencil));
      expect(DrawingTool.values, contains(DrawingTool.rectangle));
      expect(DrawingTool.values, contains(DrawingTool.circle));
      expect(DrawingTool.values, contains(DrawingTool.custom));
    });
  });

  group('WindowPaintController', () {
    late WindowPaintController controller;

    setUp(() {
      controller = WindowPaintController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('should initialize with default values', () {
      expect(controller.tool, equals(DrawingTool.pencil));
      expect(controller.color, equals(const Color(0xFF000000)));
      expect(controller.strokeWidth, equals(2.0));
      expect(controller.drawings, isEmpty);
      expect(controller.selectedId, isNull);
    });

    test('should update tool and notify listeners', () {
      bool notified = false;
      controller.addListener(() => notified = true);

      controller.setTool(DrawingTool.rectangle);

      expect(controller.tool, equals(DrawingTool.rectangle));
      expect(notified, isTrue);
    });

    test('should update color and notify listeners', () {
      bool notified = false;
      controller.addListener(() => notified = true);

      controller.setColor(Colors.red);

      expect(controller.color, equals(Colors.red));
      expect(notified, isTrue);
    });

    test('should update stroke width and notify listeners', () {
      bool notified = false;
      controller.addListener(() => notified = true);

      controller.setStrokeWidth(5.0);

      expect(controller.strokeWidth, equals(5.0));
      expect(notified, isTrue);
    });

    test('should clear selection when changing tools', () {
      // Setup: create a drawing and select it
      final pencil = PencilDrawing.start(
        point: const Offset(0.5, 0.5),
        color: Colors.red.value,
        strokeWidth: 2.0,
      );
      controller.addTestDrawing(pencil);
      controller.setTestSelectedId(pencil.id);

      // Change tool
      controller.setTool(DrawingTool.rectangle);

      // Selection should be cleared
      expect(controller.selectedId, isNull);
    });

    test('should delete selected drawing', () {
      final pencil = PencilDrawing.start(
        point: const Offset(0.5, 0.5),
        color: Colors.red.value,
        strokeWidth: 2.0,
      );
      controller.addTestDrawing(pencil);
      controller.setTestSelectedId(pencil.id);

      controller.deleteSelected();

      expect(controller.drawings, isEmpty);
      expect(controller.selectedId, isNull);
    });

    test('should clear all drawings', () {
      final pencil = PencilDrawing.start(
        point: const Offset(0.5, 0.5),
        color: Colors.red.value,
        strokeWidth: 2.0,
      );
      final rectangle = RectangleDrawing.start(
        point: const Offset(0.3, 0.3),
        color: Colors.blue.value,
        strokeWidth: 3.0,
      );
      
      controller.addTestDrawing(pencil);
      controller.addTestDrawing(rectangle);
      controller.setTestSelectedId(pencil.id);

      controller.clearAll();

      expect(controller.drawings, isEmpty);
      expect(controller.selectedId, isNull);
    });

    group('Custom Tools', () {
      test('should register and unregister custom tools', () {
        final customTool = CustomTool(
          id: 'test',
          name: 'Test Tool',
          factory: ({required point, required color, required strokeWidth}) {
            return PencilDrawing.start(
              point: point,
              color: color,
              strokeWidth: strokeWidth,
            );
          },
        );

        expect(controller.customTools, isEmpty);

        controller.registerCustomTool(customTool);
        expect(controller.customTools, hasLength(1));
        expect(controller.customTools['test'], equals(customTool));

        controller.unregisterCustomTool('test');
        expect(controller.customTools, isEmpty);
      });

      test('should switch to custom tool', () {
        final customTool = CustomTool(
          id: 'line',
          name: 'Line Tool',
          factory: ({required point, required color, required strokeWidth}) {
            return LineDrawing.start(
              point: point,
              color: color,
              strokeWidth: strokeWidth,
            );
          },
        );

        controller.registerCustomTool(customTool);
        controller.setCustomTool('line');

        expect(controller.tool, equals(DrawingTool.custom));
        expect(controller.activeCustomToolId, equals('line'));
        expect(controller.activeCustomTool, equals(customTool));
      });

      test('should throw error for unregistered custom tool', () {
        expect(
          () => controller.setCustomTool('nonexistent'),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should clear custom tool when switching to built-in tool', () {
        final customTool = CustomTool(
          id: 'test',
          name: 'Test',
          factory: ({required point, required color, required strokeWidth}) {
            return PencilDrawing.start(
              point: point,
              color: color,
              strokeWidth: strokeWidth,
            );
          },
        );

        controller.registerCustomTool(customTool);
        controller.setCustomTool('test');
        expect(controller.activeCustomToolId, equals('test'));

        controller.setTool(DrawingTool.pencil);
        expect(controller.activeCustomToolId, isNull);
      });

      test('should revert to pencil when active custom tool is unregistered', () {
        final customTool = CustomTool(
          id: 'temp',
          name: 'Temp Tool',
          factory: ({required point, required color, required strokeWidth}) {
            return PencilDrawing.start(
              point: point,
              color: color,
              strokeWidth: strokeWidth,
            );
          },
        );

        controller.registerCustomTool(customTool);
        controller.setCustomTool('temp');
        expect(controller.tool, equals(DrawingTool.custom));

        controller.unregisterCustomTool('temp');
        expect(controller.tool, equals(DrawingTool.pencil));
        expect(controller.activeCustomToolId, isNull);
      });
    });
  });

  group('JSON Serialization', () {
    test('should serialize and deserialize controller state', () {
      final controller = WindowPaintController();
      
      // Add some drawings
      final pencil = PencilDrawing.start(
        point: const Offset(0.1, 0.2),
        color: Colors.red.value,
        strokeWidth: 2.0,
      );
      pencil.points.add(const Offset(0.3, 0.4));
      
      final rectangle = RectangleDrawing.start(
        point: const Offset(0.5, 0.6),
        color: Colors.blue.value,
        strokeWidth: 3.0,
      );
      rectangle.endPoint = const Offset(0.7, 0.8);

      controller.addTestDrawing(pencil);
      controller.addTestDrawing(rectangle);

      // Serialize
      final json = controller.toJson();
      expect(json, hasLength(2));

      // Deserialize into new controller
      final newController = WindowPaintController();
      newController.fromJson(json);

      expect(newController.drawings, hasLength(2));
      
      final deserializedPencil = newController.drawings[0] as PencilDrawing;
      expect(deserializedPencil.type, equals('pencil'));
      expect(deserializedPencil.color, equals(Colors.red.value));
      expect(deserializedPencil.points, hasLength(2));

      final deserializedRectangle = newController.drawings[1] as RectangleDrawing;
      expect(deserializedRectangle.type, equals('rectangle'));
      expect(deserializedRectangle.color, equals(Colors.blue.value));

      controller.dispose();
      newController.dispose();
    });
  });
}