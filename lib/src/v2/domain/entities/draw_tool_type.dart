/// Enumeration of available drawing tool types.
/// 
/// This replaces the string-based mode system for better type safety.
enum DrawToolType {
  /// Pan and zoom tool for navigation
  panZoom('pan_zoom'),
  
  /// Pencil tool for free-hand drawing
  pencil('pencil'),
  
  /// Rectangle drawing tool
  rectangle('rectangle'),
  
  /// Rectangle with cross drawing tool
  rectangleCross('rectangle_cross'),
  
  /// Text annotation tool
  text('text');

  const DrawToolType(this.id);

  /// The unique identifier for this tool type
  final String id;

  /// Creates a DrawToolType from a string ID
  static DrawToolType? fromId(String id) {
    for (final type in DrawToolType.values) {
      if (type.id == id) {
        return type;
      }
    }
    return null;
  }
}