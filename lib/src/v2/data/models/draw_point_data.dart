import 'dart:ui';

/// Data model for representing a point in the drawing space.
/// 
/// This provides a clean, serializable representation of drawing points
/// that can be easily converted to/from JSON for server-side processing.
class DrawPointData {
  const DrawPointData({
    required this.x,
    required this.y,
    required this.scale,
    this.pressure = 1.0,
    this.timestamp,
  });

  /// X coordinate (normalized to canvas size)
  final double x;
  
  /// Y coordinate (normalized to canvas size)
  final double y;
  
  /// Scale factor at the time this point was created
  final double scale;
  
  /// Pressure information (for pressure-sensitive input)
  final double pressure;
  
  /// Timestamp when this point was created
  final DateTime? timestamp;

  /// Creates a DrawPointData from an Offset and scale
  factory DrawPointData.fromOffset(
    Offset offset, 
    double scale, {
    double pressure = 1.0,
    DateTime? timestamp,
  }) {
    return DrawPointData(
      x: offset.dx,
      y: offset.dy,
      scale: scale,
      pressure: pressure,
      timestamp: timestamp ?? DateTime.now(),
    );
  }

  /// Converts this point to an Offset
  Offset toOffset() => Offset(x, y);

  /// Creates a copy with modified properties
  DrawPointData copyWith({
    double? x,
    double? y,
    double? scale,
    double? pressure,
    DateTime? timestamp,
  }) {
    return DrawPointData(
      x: x ?? this.x,
      y: y ?? this.y,
      scale: scale ?? this.scale,
      pressure: pressure ?? this.pressure,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Converts to JSON representation
  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'scale': scale,
      'pressure': pressure,
      if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
    };
  }

  /// Creates from JSON representation
  factory DrawPointData.fromJson(Map<String, dynamic> json) {
    return DrawPointData(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      scale: (json['scale'] as num).toDouble(),
      pressure: (json['pressure'] as num?)?.toDouble() ?? 1.0,
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'] as String)
          : null,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DrawPointData &&
        other.x == x &&
        other.y == y &&
        other.scale == scale &&
        other.pressure == pressure &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return Object.hash(x, y, scale, pressure, timestamp);
  }

  @override
  String toString() {
    return 'DrawPointData(x: $x, y: $y, scale: $scale, pressure: $pressure, timestamp: $timestamp)';
  }
}