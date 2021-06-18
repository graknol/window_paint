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
      title: 'Window Paint Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Window Paint Demo Page'),
      restorationScopeId: 'root',
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

class _MyHomePageState extends State<MyHomePage> with RestorationMixin {
  static const debugHitboxes = false;

  final adapters = <DrawObjectAdapter>[
    PanZoomAdapter(),
    DrawPencilAdapter(
      width: 2.0,
      debugHitboxes: debugHitboxes,
    ),
    DrawRectangleAdapter(
      width: 2.0,
      debugHitboxes: debugHitboxes,
    ),
    DrawRectangleCrossAdapter(
      width: 2.0,
      debugHitboxes: debugHitboxes,
    ),
    DrawTextAdapter(),
  ];

  late final RestorableWindowPaintController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RestorableWindowPaintController(
      adapters,
      initialColor: Colors.red,
    );
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_controller, 'controller');
  }

  @override
  String? get restorationId => 'main_page';

  @override
  void dispose() {
    _controller.dispose();
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
                controller: _controller.value,
              ),
              WindowPaint(
                controller: _controller.value,
                maxScale: 10.0,
                adapters: adapters,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                  ),
                  height: 400,
                ),
                onAdd: (object) {
                  print('###ADD###');
                  print(object.toJSON());
                  print('~~~END~~~');
                },
                onChange: (from, to) {
                  print('###CHANGE###');
                  print(from.toJSON());
                  print('###TO###');
                  print(to.toJSON());
                  print('~~~END~~~');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
