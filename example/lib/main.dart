import 'package:example/draw/adapters/draw_text_adapter.dart';
import 'package:example/window_paint_control.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_paint/window_paint.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _windowPaintController = WindowPaintController(
    initialColor: Colors.red,
  );

  var debugHitboxes = false;

  @override
  void dispose() {
    _windowPaintController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      resizeToAvoidBottomInset: false,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              WindowPaintControl(
                controller: _windowPaintController,
              ),
              WindowPaint(
                controller: _windowPaintController,
                maxScale: 10.0,
                adapters: {
                  'pan_zoom': PanZoomAdapter(),
                  'pencil': DrawPencilAdapter(
                    width: 2.0,
                    debugHitboxes: debugHitboxes,
                  ),
                  'rectangle': DrawRectangleAdapter(
                    width: 2.0,
                    debugHitboxes: debugHitboxes,
                  ),
                  'rectangle_cross': DrawRectangleCrossAdapter(
                    width: 2.0,
                    debugHitboxes: debugHitboxes,
                  ),
                  'text': DrawTextAdapter(),
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                  ),
                  height: 400,
                ),
              ),
              RaisedButton(
                onPressed: () {
                  setState(() {
                    debugHitboxes = !debugHitboxes;
                  });
                },
                color: debugHitboxes ? Colors.green : Colors.amber,
                child: SizedBox(
                  width: 92.0,
                  child: Center(
                    child: Text('Hitboxes ${debugHitboxes ? 'ON' : 'OFF'}'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
