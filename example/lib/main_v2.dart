import 'package:flutter/material.dart';
import 'package:window_paint/window_paint_v2.dart';

/// Example demonstrating the new window_paint v2.0 architecture.
/// 
/// This example shows how to use the improved v2 API with better
/// state management, type safety, and extensibility.
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Window Paint v2.0 Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Window Paint v2.0 Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late WindowPaintController _controller;
  late Map<DrawToolType, IDrawingTool> _tools;

  @override
  void initState() {
    super.initState();
    
    // Initialize drawing tools
    _tools = {
      DrawToolType.panZoom: PanZoomDrawingTool(),
      DrawToolType.pencil: PencilDrawingTool(
        defaultStrokeWidth: 2.0,
        autoSimplify: true,
      ),
      DrawToolType.rectangle: RectangleDrawingTool(
        defaultStrokeWidth: 2.0,
        filled: false,
      ),
      // Add more tools here as they're implemented
    };
    
    // Initialize controller
    _controller = WindowPaintController(
      initialState: const WindowPaintState(
        activeTool: DrawToolType.panZoom,
        activeColor: Colors.red,
        strokeWidth: 2.0,
      ),
      tools: _tools,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleObjectAdded(String objectId) {
    print('Object added: $objectId');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added object: $objectId')),
    );
  }

  void _handleObjectModified(String objectId, Map<String, dynamic> changes) {
    print('Object modified: $objectId');
  }

  void _handleObjectRemoved(String objectId) {
    print('Object removed: $objectId');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Removed object: $objectId')),
    );
  }

  void _handleStateChanged(WindowPaintState state) {
    // React to state changes if needed
    print('State changed: ${state.objects.length} objects');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.undo),
            onPressed: _controller.canUndo ? _controller.undo : null,
          ),
          IconButton(
            icon: Icon(Icons.redo),
            onPressed: _controller.canRedo ? _controller.redo : null,
          ),
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              _controller.clearAllObjects();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Tool selection bar
          _buildToolBar(),
          
          // Drawing area
          Expanded(
            child: Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: WindowPaintV2(
                controller: _controller,
                tools: _tools,
                onObjectAdded: _handleObjectAdded,
                onObjectModified: _handleObjectModified,
                onObjectRemoved: _handleObjectRemoved,
                onStateChanged: _handleStateChanged,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.grey[100],
                  child: Center(
                    child: Text(
                      'Draw here with the new v2.0 architecture!',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Status bar
          _buildStatusBar(),
        ],
      ),
    );
  }

  Widget _buildToolBar() {
    return ValueListenableBuilder<WindowPaintState>(
      valueListenable: _controller,
      builder: (context, state, child) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            border: Border(bottom: BorderSide(color: Colors.grey)),
          ),
          child: Row(
            children: [
              // Tool selection
              Text('Tool: '),
              SizedBox(width: 8),
              DropdownButton<DrawToolType>(
                value: state.activeTool,
                onChanged: (tool) {
                  if (tool != null) {
                    _controller.setActiveTool(tool);
                  }
                },
                items: _tools.keys.map((tool) {
                  return DropdownMenuItem(
                    value: tool,
                    child: Text(tool.id),
                  );
                }).toList(),
              ),
              
              SizedBox(width: 24),
              
              // Color selection
              Text('Color: '),
              SizedBox(width: 8),
              GestureDetector(
                onTap: _showColorPicker,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: state.activeColor,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              
              SizedBox(width: 24),
              
              // Stroke width
              Text('Width: '),
              SizedBox(width: 8),
              SizedBox(
                width: 100,
                child: Slider(
                  value: state.strokeWidth,
                  min: 1.0,
                  max: 10.0,
                  divisions: 9,
                  label: state.strokeWidth.round().toString(),
                  onChanged: (value) {
                    _controller.setStrokeWidth(value);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBar() {
    return ValueListenableBuilder<WindowPaintState>(
      valueListenable: _controller,
      builder: (context, state, child) {
        return Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(top: BorderSide(color: Colors.grey)),
          ),
          child: Row(
            children: [
              Text('Objects: ${state.objects.length}'),
              SizedBox(width: 16),
              if (state.hasSelection)
                Text('Selected: ${state.selectedObjectId}'),
              if (state.isDrawing)
                Text(' | Drawing...'),
              Spacer(),
              Text('v2.0 Architecture'),
            ],
          ),
        );
      },
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Choose Color'),
          content: Wrap(
            children: [
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.yellow,
              Colors.purple,
              Colors.orange,
              Colors.black,
              Colors.grey,
            ].map((color) {
              return GestureDetector(
                onTap: () {
                  _controller.setActiveColor(color);
                  Navigator.of(context).pop();
                },
                child: Container(
                  width: 40,
                  height: 40,
                  margin: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}