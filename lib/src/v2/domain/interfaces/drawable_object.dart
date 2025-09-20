import 'dart:ui';

/// Base interface for all drawable objects in the window paint system.
/// 
/// This interface defines the contract that all drawable objects must implement.
/// It provides better separation of concerns compared to the original DrawObject class.
abstract interface class IDrawableObject {
  /// Unique identifier for this object
  String get id;
  
  /// The type of tool that created this object
  String get toolType;
  
  /// Primary color of this object
  Color get primaryColor;
  
  /// Renders this object to the given canvas
  void render(Canvas canvas, Size size, Offset Function(Offset) denormalize);
  
  /// Checks if the given point intersects with this object
  bool containsPoint(Offset point, Size size);
  
  /// Returns the bounding box of this object
  Rect getBounds();
  
  /// Creates a deep copy of this object
  IDrawableObject clone();
  
  /// Converts this object to a JSON representation
  Map<String, dynamic> toJson();
  
  /// Whether this object should be repainted
  bool shouldRepaint();
}