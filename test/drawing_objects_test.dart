import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:window_paint/window_paint_simple.dart';

void main() {
  group('PencilDrawing', () {
    test('should create with initial point', () {
      final pencil = PencilDrawing.start(
        point: const Offset(0.5, 0.5),
        color: Colors.red.value,
        strokeWidth: 2.0,
      );

      expect(pencil.type, equals('pencil'));
      expect(pencil.color, equals(Colors.red.value));
      expect(pencil.strokeWidth, equals(2.0));
      expect(pencil.points, hasLength(1));
      expect(pencil.points.first, equals(const Offset(0.5, 0.5)));
      expect(pencil.id, isNotEmpty);
    });

    test('should add points when updated', () {
      final pencil = PencilDrawing.start(
        point: const Offset(0.1, 0.1),
        color: Colors.blue.value,
        strokeWidth: 1.0,
      );

      pencil.update(const Offset(0.2, 0.2));
      pencil.update(const Offset(0.3, 0.3));

      expect(pencil.points, hasLength(3));
      expect(pencil.points[1], equals(const Offset(0.2, 0.2)));
      expect(pencil.points[2], equals(const Offset(0.3, 0.3)));
    });

    test('should be valid with 2 or more points', () {
      final pencil = PencilDrawing.start(
        point: const Offset(0.1, 0.1),
        color: Colors.black.value,
        strokeWidth: 1.0,
      );

      expect(pencil.isValid(), isFalse); // Only 1 point

      pencil.update(const Offset(0.2, 0.2));
      expect(pencil.isValid(), isTrue); // 2 points
    });

    test('should detect point containment', () {
      final pencil = PencilDrawing.start(
        point: const Offset(0.5, 0.5),
        color: Colors.black.value,
        strokeWidth: 1.0,
      );

      expect(pencil.containsPoint(const Offset(0.5, 0.5)), isTrue);
      expect(pencil.containsPoint(const Offset(0.9, 0.9)), isFalse);
    });

    test('should serialize and deserialize correctly', () {
      final original = PencilDrawing.start(
        point: const Offset(0.1, 0.2),
        color: Colors.red.value,
        strokeWidth: 3.0,
      );
      original.update(const Offset(0.3, 0.4));

      final json = original.toJson();
      final deserialized = PencilDrawing.fromJson(json);

      expect(deserialized.id, equals(original.id));
      expect(deserialized.type, equals(original.type));
      expect(deserialized.color, equals(original.color));
      expect(deserialized.strokeWidth, equals(original.strokeWidth));
      expect(deserialized.points, hasLength(2));
      expect(deserialized.points[0], equals(const Offset(0.1, 0.2)));
      expect(deserialized.points[1], equals(const Offset(0.3, 0.4)));
    });
  });

  group('RectangleDrawing', () {
    test('should create with start point', () {
      final rectangle = RectangleDrawing.start(
        point: const Offset(0.2, 0.3),
        color: Colors.green.value,
        strokeWidth: 4.0,
      );

      expect(rectangle.type, equals('rectangle'));
      expect(rectangle.color, equals(Colors.green.value));
      expect(rectangle.strokeWidth, equals(4.0));
      expect(rectangle.startPoint, equals(const Offset(0.2, 0.3)));
      expect(rectangle.endPoint, equals(const Offset(0.2, 0.3))); // Same as start initially
      expect(rectangle.id, isNotEmpty);
    });

    test('should update end point', () {
      final rectangle = RectangleDrawing.start(
        point: const Offset(0.1, 0.1),
        color: Colors.blue.value,
        strokeWidth: 2.0,
      );

      rectangle.update(const Offset(0.5, 0.7));

      expect(rectangle.endPoint, equals(const Offset(0.5, 0.7)));
      expect(rectangle.startPoint, equals(const Offset(0.1, 0.1))); // Unchanged
    });

    test('should be valid when size is above minimum', () {
      final rectangle = RectangleDrawing.start(
        point: const Offset(0.1, 0.1),
        color: Colors.red.value,
        strokeWidth: 1.0,
      );

      expect(rectangle.isValid(), isFalse); // No size

      rectangle.update(const Offset(0.2, 0.2)); // Small but valid size
      expect(rectangle.isValid(), isTrue);
    });

    test('should detect point containment on borders', () {
      final rectangle = RectangleDrawing.start(
        point: const Offset(0.1, 0.1),
        color: Colors.black.value,
        strokeWidth: 1.0,
      );
      rectangle.update(const Offset(0.9, 0.9));

      // Points on borders should be contained
      expect(rectangle.containsPoint(const Offset(0.1, 0.5)), isTrue); // Left border
      expect(rectangle.containsPoint(const Offset(0.9, 0.5)), isTrue); // Right border
      expect(rectangle.containsPoint(const Offset(0.5, 0.1)), isTrue); // Top border
      expect(rectangle.containsPoint(const Offset(0.5, 0.9)), isTrue); // Bottom border
      
      // Points inside should not be contained (stroke-only)
      expect(rectangle.containsPoint(const Offset(0.5, 0.5)), isFalse); // Center
      
      // Points far outside should not be contained
      expect(rectangle.containsPoint(const Offset(0.0, 0.0)), isFalse);
    });

    test('should serialize and deserialize correctly', () {
      final original = RectangleDrawing.start(
        point: const Offset(0.2, 0.3),
        color: Colors.purple.value,
        strokeWidth: 5.0,
      );
      original.update(const Offset(0.8, 0.7));

      final json = original.toJson();
      final deserialized = RectangleDrawing.fromJson(json);

      expect(deserialized.id, equals(original.id));
      expect(deserialized.type, equals(original.type));
      expect(deserialized.color, equals(original.color));
      expect(deserialized.strokeWidth, equals(original.strokeWidth));
      expect(deserialized.startPoint, equals(const Offset(0.2, 0.3)));
      expect(deserialized.endPoint, equals(const Offset(0.8, 0.7)));
    });
  });

  group('CircleDrawing', () {
    test('should create with center point', () {
      final circle = CircleDrawing.start(
        point: const Offset(0.5, 0.5),
        color: Colors.orange.value,
        strokeWidth: 3.0,
      );

      expect(circle.type, equals('circle'));
      expect(circle.color, equals(Colors.orange.value));
      expect(circle.strokeWidth, equals(3.0));
      expect(circle.center, equals(const Offset(0.5, 0.5)));
      expect(circle.radius, equals(0.0)); // Initially no radius
      expect(circle.id, isNotEmpty);
    });

    test('should update radius based on distance from center', () {
      final circle = CircleDrawing.start(
        point: const Offset(0.5, 0.5),
        color: Colors.yellow.value,
        strokeWidth: 2.0,
      );

      circle.update(const Offset(0.8, 0.5)); // 0.3 units horizontally

      expect(circle.radius, closeTo(0.3, 0.001));
      expect(circle.center, equals(const Offset(0.5, 0.5))); // Unchanged
    });

    test('should be valid when radius is above minimum', () {
      final circle = CircleDrawing.start(
        point: const Offset(0.5, 0.5),
        color: Colors.blue.value,
        strokeWidth: 1.0,
      );

      expect(circle.isValid(), isFalse); // Zero radius

      circle.update(const Offset(0.6, 0.5)); // 0.1 radius
      expect(circle.isValid(), isTrue);
    });

    test('should detect point containment on circumference', () {
      final circle = CircleDrawing.start(
        point: const Offset(0.5, 0.5),
        color: Colors.black.value,
        strokeWidth: 1.0,
      );
      circle.update(const Offset(0.8, 0.5)); // Radius 0.3

      // Points on circumference should be contained
      expect(circle.containsPoint(const Offset(0.8, 0.5)), isTrue); // Right edge
      expect(circle.containsPoint(const Offset(0.2, 0.5)), isTrue); // Left edge
      
      // Points inside or outside should not be contained (stroke-only)
      expect(circle.containsPoint(const Offset(0.5, 0.5)), isFalse); // Center
      expect(circle.containsPoint(const Offset(0.1, 0.1)), isFalse); // Far outside
    });

    test('should serialize and deserialize correctly', () {
      final original = CircleDrawing.start(
        point: const Offset(0.3, 0.4),
        color: Colors.cyan.value,
        strokeWidth: 4.0,
      );
      original.update(const Offset(0.6, 0.8)); // Distance = 0.5

      final json = original.toJson();
      final deserialized = CircleDrawing.fromJson(json);

      expect(deserialized.id, equals(original.id));
      expect(deserialized.type, equals(original.type));
      expect(deserialized.color, equals(original.color));
      expect(deserialized.strokeWidth, equals(original.strokeWidth));
      expect(deserialized.center, equals(const Offset(0.3, 0.4)));
      expect(deserialized.radius, closeTo(0.5, 0.001));
    });
  });

  group('DrawingObject Factory', () {
    test('should create correct drawing types from JSON', () {
      final pencilJson = {
        'type': 'pencil',
        'id': 'test1',
        'color': Colors.red.value,
        'strokeWidth': 2.0,
        'points': [
          {'x': 0.1, 'y': 0.2},
          {'x': 0.3, 'y': 0.4},
        ],
      };

      final rectangleJson = {
        'type': 'rectangle',
        'id': 'test2',
        'color': Colors.blue.value,
        'strokeWidth': 3.0,
        'startPoint': {'x': 0.1, 'y': 0.1},
        'endPoint': {'x': 0.9, 'y': 0.9},
      };

      final circleJson = {
        'type': 'circle',
        'id': 'test3',
        'color': Colors.green.value,
        'strokeWidth': 4.0,
        'center': {'x': 0.5, 'y': 0.5},
        'radius': 0.3,
      };

      final lineJson = {
        'type': 'line',
        'id': 'test4',
        'color': Colors.orange.value,
        'strokeWidth': 2.0,
        'startPoint': {'x': 0.0, 'y': 0.0},
        'endPoint': {'x': 1.0, 'y': 1.0},
      };

      final arrowJson = {
        'type': 'arrow',
        'id': 'test5',
        'color': Colors.purple.value,
        'strokeWidth': 3.0,
        'startPoint': {'x': 0.2, 'y': 0.2},
        'endPoint': {'x': 0.8, 'y': 0.8},
      };

      final pencil = DrawingObject.fromJson(pencilJson);
      final rectangle = DrawingObject.fromJson(rectangleJson);
      final circle = DrawingObject.fromJson(circleJson);
      final line = DrawingObject.fromJson(lineJson);
      final arrow = DrawingObject.fromJson(arrowJson);

      expect(pencil, isA<PencilDrawing>());
      expect(rectangle, isA<RectangleDrawing>());
      expect(circle, isA<CircleDrawing>());
      expect(line, isA<LineDrawing>());
      expect(arrow, isA<ArrowDrawing>());

      expect(pencil!.id, equals('test1'));
      expect(rectangle!.id, equals('test2'));
      expect(circle!.id, equals('test3'));
      expect(line!.id, equals('test4'));
      expect(arrow!.id, equals('test5'));
    });

    test('should return null for invalid JSON', () {
      final invalidJson = {
        'type': 'unknown',
        'id': 'test',
      };

      final result = DrawingObject.fromJson(invalidJson);
      expect(result, isNull);
    });

    test('should handle malformed JSON gracefully', () {
      final malformedJson = {
        'type': 'pencil',
        // Missing required fields
      };

      final result = DrawingObject.fromJson(malformedJson);
      expect(result, isNull);
    });
  });

  group('LineDrawing', () {
    test('should create with start and end points', () {
      final line = LineDrawing.start(
        point: const Offset(0.1, 0.2),
        color: Colors.red.value,
        strokeWidth: 2.0,
      );

      expect(line.type, equals('line'));
      expect(line.color, equals(Colors.red.value));
      expect(line.strokeWidth, equals(2.0));
      expect(line.startPoint, equals(const Offset(0.1, 0.2)));
      expect(line.endPoint, equals(const Offset(0.1, 0.2))); // Same as start initially
      expect(line.id, isNotEmpty);
    });

    test('should update end point', () {
      final line = LineDrawing.start(
        point: const Offset(0.0, 0.0),
        color: Colors.blue.value,
        strokeWidth: 1.0,
      );

      line.update(const Offset(1.0, 1.0));

      expect(line.endPoint, equals(const Offset(1.0, 1.0)));
      expect(line.startPoint, equals(const Offset(0.0, 0.0))); // Unchanged
    });

    test('should be valid when length is above minimum', () {
      final line = LineDrawing.start(
        point: const Offset(0.0, 0.0),
        color: Colors.black.value,
        strokeWidth: 1.0,
      );

      expect(line.isValid(), isFalse); // Zero length

      line.update(const Offset(0.1, 0.1));
      expect(line.isValid(), isTrue); // Has length
    });

    test('should serialize and deserialize correctly', () {
      final original = LineDrawing.start(
        point: const Offset(0.2, 0.3),
        color: Colors.green.value,
        strokeWidth: 3.0,
      );
      original.update(const Offset(0.8, 0.7));

      final json = original.toJson();
      final deserialized = LineDrawing.fromJson(json);

      expect(deserialized.id, equals(original.id));
      expect(deserialized.type, equals(original.type));
      expect(deserialized.color, equals(original.color));
      expect(deserialized.strokeWidth, equals(original.strokeWidth));
      expect(deserialized.startPoint, equals(const Offset(0.2, 0.3)));
      expect(deserialized.endPoint, equals(const Offset(0.8, 0.7)));
    });
  });

  group('ArrowDrawing', () {
    test('should create with start and end points', () {
      final arrow = ArrowDrawing.start(
        point: const Offset(0.3, 0.4),
        color: Colors.orange.value,
        strokeWidth: 4.0,
      );

      expect(arrow.type, equals('arrow'));
      expect(arrow.color, equals(Colors.orange.value));
      expect(arrow.strokeWidth, equals(4.0));
      expect(arrow.startPoint, equals(const Offset(0.3, 0.4)));
      expect(arrow.endPoint, equals(const Offset(0.3, 0.4))); // Same as start initially
      expect(arrow.id, isNotEmpty);
    });

    test('should update end point', () {
      final arrow = ArrowDrawing.start(
        point: const Offset(0.2, 0.2),
        color: Colors.purple.value,
        strokeWidth: 2.0,
      );

      arrow.update(const Offset(0.8, 0.8));

      expect(arrow.endPoint, equals(const Offset(0.8, 0.8)));
      expect(arrow.startPoint, equals(const Offset(0.2, 0.2))); // Unchanged
    });

    test('should be valid when length is above minimum', () {
      final arrow = ArrowDrawing.start(
        point: const Offset(0.5, 0.5),
        color: Colors.cyan.value,
        strokeWidth: 1.0,
      );

      expect(arrow.isValid(), isFalse); // Zero length

      arrow.update(const Offset(0.7, 0.7));
      expect(arrow.isValid(), isTrue); // Has length
    });

    test('should serialize and deserialize correctly', () {
      final original = ArrowDrawing.start(
        point: const Offset(0.1, 0.1),
        color: Colors.teal.value,
        strokeWidth: 5.0,
      );
      original.update(const Offset(0.9, 0.9));

      final json = original.toJson();
      final deserialized = ArrowDrawing.fromJson(json);

      expect(deserialized.id, equals(original.id));
      expect(deserialized.type, equals(original.type));
      expect(deserialized.color, equals(original.color));
      expect(deserialized.strokeWidth, equals(original.strokeWidth));
      expect(deserialized.startPoint, equals(const Offset(0.1, 0.1)));
      expect(deserialized.endPoint, equals(const Offset(0.9, 0.9)));
    });
  });

  group('Custom Tool Factories', () {
    test('should create line tool factory', () {
      final lineTool = createLineTool();
      
      expect(lineTool.id, equals('line'));
      expect(lineTool.name, equals('Line'));
      
      final drawing = lineTool.factory(
        point: const Offset(0.1, 0.2),
        color: Colors.red.value,
        strokeWidth: 3.0,
      );
      
      expect(drawing, isA<LineDrawing>());
      expect(drawing.color, equals(Colors.red.value));
      expect(drawing.strokeWidth, equals(3.0));
    });

    test('should create arrow tool factory', () {
      final arrowTool = createArrowTool();
      
      expect(arrowTool.id, equals('arrow'));
      expect(arrowTool.name, equals('Arrow'));
      
      final drawing = arrowTool.factory(
        point: const Offset(0.3, 0.4),
        color: Colors.blue.value,
        strokeWidth: 2.0,
      );
      
      expect(drawing, isA<ArrowDrawing>());
      expect(drawing.color, equals(Colors.blue.value));
      expect(drawing.strokeWidth, equals(2.0));
    });
  });
}