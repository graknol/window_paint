import 'package:flutter/material.dart';
import 'package:window_paint/window_paint_simple.dart';

/// Simple example using the streamlined window_paint implementation.
/// 
/// This shows how much simpler the API is compared to the full v2 architecture
/// while still providing all the essential drawing functionality.
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Window Paint Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SimplePaintDemo(),
    );
  }
}

class SimplePaintDemo extends StatefulWidget {
  @override
  _SimplePaintDemoState createState() => _SimplePaintDemoState();
}

class _SimplePaintDemoState extends State<SimplePaintDemo> {
  late WindowPaintController _controller;

  @override
  void initState() {
    super.initState();
    // Simple initialization with custom tools
    _controller = WindowPaintController();
    
    // Register custom tools
    _controller.registerCustomTool(createLineTool());
    _controller.registerCustomTool(createArrowTool());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Simple Window Paint'),
        actions: [
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: _controller.clearAll,
          ),
        ],
      ),
      body: Column(
        children: [
          // Simple toolbar
          _buildToolbar(),
          
          // Drawing area
          Expanded(
            child: Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child: WindowPaint(
                controller: _controller,
                onDrawingAdded: (drawing) {
                  print('Drawing added: ${drawing.id}');
                },
                child: Container(
                  color: Colors.grey[50],
                  child: Center(
                    child: Text(
                      'Draw here!\nMuch simpler than the full v2 architecture.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Status
          _buildStatus(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(bottom: BorderSide(color: Colors.grey)),
          ),
          child: Wrap(
            spacing: 16,
            alignment: WrapAlignment.center,
            children: [
              // Built-in tool selection
              _buildToolButton(DrawingTool.pan, Icons.pan_tool, 'Pan'),
              _buildToolButton(DrawingTool.pencil, Icons.edit, 'Pencil'),
              _buildToolButton(DrawingTool.rectangle, Icons.crop_din, 'Rectangle'),
              _buildToolButton(DrawingTool.circle, Icons.circle_outlined, 'Circle'),
              
              // Custom tools
              ..._buildCustomToolButtons(),
              
              SizedBox(width: 16),
              
              // Color picker
              GestureDetector(
                onTap: _showColorPicker,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _controller.color,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
              
              // Stroke width
              Text('Width: ${_controller.strokeWidth.toInt()}'),
              SizedBox(
                width: 100,
                child: Slider(
                  value: _controller.strokeWidth,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChanged: _controller.setStrokeWidth,
                ),
              ),
              
              // Delete selected
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: _controller.selectedId != null 
                    ? _controller.deleteSelected 
                    : null,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildToolButton(DrawingTool tool, IconData icon, String label) {
    final isSelected = _controller.tool == tool && _controller.activeCustomToolId == null;
    
    return GestureDetector(
      onTap: () => _controller.setTool(tool),
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[100] : Colors.transparent,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey[700]),
            SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.blue : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildCustomToolButtons() {
    return _controller.customTools.values.map((tool) {
      final isSelected = _controller.tool == DrawingTool.custom && 
                        _controller.activeCustomToolId == tool.id;
      
      return GestureDetector(
        onTap: () => _controller.setCustomTool(tool.id),
        child: Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.green[100] : Colors.transparent,
            border: Border.all(
              color: isSelected ? Colors.green : Colors.grey,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getIconForCustomTool(tool.id), 
                color: isSelected ? Colors.green : Colors.grey[700],
              ),
              SizedBox(height: 4),
              Text(
                tool.name,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.green : Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  IconData _getIconForCustomTool(String toolId) {
    switch (toolId) {
      case 'line':
        return Icons.remove;
      case 'arrow':
        return Icons.arrow_forward;
      default:
        return Icons.extension;
    }
  }

  Widget _buildStatus() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(top: BorderSide(color: Colors.grey)),
          ),
          child: Row(
            children: [
              Text('Drawings: ${_controller.drawings.length}'),
              SizedBox(width: 16),
              if (_controller.selectedId != null)
                Text('Selected: ${_controller.selectedId}'),
              SizedBox(width: 16),
              if (_controller.tool == DrawingTool.custom && _controller.activeCustomTool != null)
                Text('Custom Tool: ${_controller.activeCustomTool!.name}'),
              Spacer(),
              Text('Simple Architecture + Custom Tools'),
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
              Colors.black,
              Colors.red,
              Colors.blue,
              Colors.green,
              Colors.orange,
              Colors.purple,
              Colors.brown,
              Colors.grey,
            ].map((color) {
              return GestureDetector(
                onTap: () {
                  _controller.setColor(color);
                  Navigator.pop(context);
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