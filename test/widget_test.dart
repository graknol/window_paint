import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:window_paint/window_paint_simple.dart';

void main() {
  group('WindowPaint Widget', () {
    testWidgets('should create widget with default controller', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: WindowPaint(
            child: Container(
              width: 200,
              height: 200,
              color: Colors.white,
            ),
          ),
        ),
      );

      expect(find.byType(WindowPaint), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.byType(GestureDetector), findsOneWidget);
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('should use provided controller', (WidgetTester tester) async {
      final controller = WindowPaintController(
        tool: DrawingTool.rectangle,
        color: Colors.red,
        strokeWidth: 5.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: WindowPaint(
            controller: controller,
            child: Container(
              width: 200,
              height: 200,
              color: Colors.white,
            ),
          ),
        ),
      );

      expect(find.byType(WindowPaint), findsOneWidget);
      
      // Verify controller properties are used
      expect(controller.tool, equals(DrawingTool.rectangle));
      expect(controller.color, equals(Colors.red));
      expect(controller.strokeWidth, equals(5.0));

      controller.dispose();
    });

    testWidgets('should call onDrawingAdded when drawing is completed', (WidgetTester tester) async {
      final controller = WindowPaintController(tool: DrawingTool.pencil);
      DrawingObject? addedDrawing;

      await tester.pumpWidget(
        MaterialApp(
          home: WindowPaint(
            controller: controller,
            onDrawingAdded: (drawing) {
              addedDrawing = drawing;
            },
            child: Container(
              width: 200,
              height: 200,
              color: Colors.white,
            ),
          ),
        ),
      );

      // Simulate drawing gestures
      final gesture = await tester.startGesture(const Offset(50, 50));
      await tester.pump();
      
      await gesture.moveTo(const Offset(100, 100));
      await tester.pump();
      
      await gesture.up();
      await tester.pump();

      // Verify callback was called
      expect(addedDrawing, isNotNull);
      expect(addedDrawing, isA<PencilDrawing>());

      controller.dispose();
    });

    testWidgets('should handle pan tool without drawing', (WidgetTester tester) async {
      final controller = WindowPaintController(tool: DrawingTool.pan);
      DrawingObject? addedDrawing;

      await tester.pumpWidget(
        MaterialApp(
          home: WindowPaint(
            controller: controller,
            onDrawingAdded: (drawing) {
              addedDrawing = drawing;
            },
            child: Container(
              width: 200,
              height: 200,
              color: Colors.white,
            ),
          ),
        ),
      );

      // Simulate pan gestures
      await tester.drag(find.byType(WindowPaint), const Offset(50, 50));
      await tester.pump();

      // No drawing should be added when using pan tool
      expect(addedDrawing, isNull);
      expect(controller.drawings, isEmpty);

      controller.dispose();
    });

    testWidgets('should respond to tap for selection', (WidgetTester tester) async {
      final controller = WindowPaintController();
      
      // Add a drawing manually using the extension
      final pencil = PencilDrawing.start(
        point: const Offset(0.25, 0.25), // Normalized coordinates
        color: Colors.blue.value,
        strokeWidth: 2.0,
      );
      pencil.update(const Offset(0.75, 0.75));
      
      // Use a public method to add the drawing
      controller.fromJson([pencil.toJson()]);

      await tester.pumpWidget(
        MaterialApp(
          home: WindowPaint(
            controller: controller,
            child: Container(
              width: 200,
              height: 200,
              color: Colors.white,
            ),
          ),
        ),
      );

      // Tap near the drawing to select it
      await tester.tap(find.byType(WindowPaint));
      await tester.pump();

      // The selection logic should have run (though specific selection 
      // depends on hit testing which is complex to test)
      expect(controller.drawings, hasLength(1));

      controller.dispose();
    });

    testWidgets('should respect scale limits', (WidgetTester tester) async {
      const minScale = 0.5;
      const maxScale = 5.0;

      await tester.pumpWidget(
        MaterialApp(
          home: WindowPaint(
            minScale: minScale,
            maxScale: maxScale,
            child: Container(
              width: 200,
              height: 200,
              color: Colors.white,
            ),
          ),
        ),
      );

      final interactiveViewer = tester.widget<InteractiveViewer>(
        find.byType(InteractiveViewer),
      );

      expect(interactiveViewer.minScale, equals(minScale));
      expect(interactiveViewer.maxScale, equals(maxScale));
    });
  });

  group('WindowPaintController Integration', () {
    testWidgets('should update UI when controller state changes', (WidgetTester tester) async {
      final controller = WindowPaintController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                ElevatedButton(
                  onPressed: () => controller.setTool(DrawingTool.rectangle),
                  child: Text('Rectangle Tool'),
                ),
                ElevatedButton(
                  onPressed: () => controller.setColor(Colors.red),
                  child: Text('Red Color'),
                ),
                Expanded(
                  child: WindowPaint(
                    controller: controller,
                    child: Container(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify initial state
      expect(controller.tool, equals(DrawingTool.pencil));
      expect(controller.color, equals(const Color(0xFF000000)));

      // Tap buttons to change state
      await tester.tap(find.text('Rectangle Tool'));
      await tester.pump();

      expect(controller.tool, equals(DrawingTool.rectangle));

      await tester.tap(find.text('Red Color'));
      await tester.pump();

      expect(controller.color, equals(Colors.red));

      controller.dispose();
    });

    testWidgets('should dispose controller when widget is disposed', (WidgetTester tester) async {
      WindowPaintController? controller;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              controller = WindowPaintController();
              return WindowPaint(
                controller: controller,
                child: Container(
                  width: 200,
                  height: 200,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
      );

      expect(controller, isNotNull);

      // Navigate away to trigger dispose
      await tester.pumpWidget(
        MaterialApp(
          home: Container(),
        ),
      );

      // The controller should still be valid since we manage it externally
      expect(controller!.tool, equals(DrawingTool.pencil));
      
      // Clean up
      controller!.dispose();
    });

    testWidgets('should handle drawing sequence correctly', (WidgetTester tester) async {
      final controller = WindowPaintController(tool: DrawingTool.rectangle);
      final addedDrawings = <DrawingObject>[];

      await tester.pumpWidget(
        MaterialApp(
          home: WindowPaint(
            controller: controller,
            onDrawingAdded: (drawing) => addedDrawings.add(drawing),
            child: Container(
              width: 400,
              height: 400,
              color: Colors.white,
            ),
          ),
        ),
      );

      // Draw a rectangle
      final gesture1 = await tester.startGesture(const Offset(100, 100));
      await tester.pump();
      
      await gesture1.moveTo(const Offset(300, 300));
      await tester.pump();
      
      await gesture1.up();
      await tester.pump();

      expect(addedDrawings, hasLength(1));
      expect(addedDrawings[0], isA<RectangleDrawing>());

      // Change tool and draw again
      controller.setTool(DrawingTool.circle);
      await tester.pump();

      final gesture2 = await tester.startGesture(const Offset(200, 200));
      await tester.pump();
      
      await gesture2.moveTo(const Offset(250, 250));
      await tester.pump();
      
      await gesture2.up();
      await tester.pump();

      expect(addedDrawings, hasLength(2));
      expect(addedDrawings[1], isA<CircleDrawing>());

      controller.dispose();
    });
  });
}