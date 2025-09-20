import 'dart:ui';
import 'package:flutter/foundation.dart';

/// Simplified data model for drawable objects with direct JSON serialization
@immutable
class DrawableObjectData {
  const DrawableObjectData({
    required this.id,
    required this.toolType,
    required this.color,
    required this.strokeWidth,
    required this.data,
    this.metadata = const {},
  });

  final String id;
  final String toolType;
  final int color;
  final double strokeWidth;
  final Map<String, dynamic> data;
  final Map<String, dynamic> metadata;

  Color get colorValue => Color(color);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'toolType': toolType,
      'color': color,
      'strokeWidth': strokeWidth,
      'data': data,
      'metadata': metadata,
    };
  }

  factory DrawableObjectData.fromJson(Map<String, dynamic> json) {
    return DrawableObjectData(
      id: json['id'] as String,
      toolType: json['toolType'] as String,
      color: json['color'] as int,
      strokeWidth: (json['strokeWidth'] as num).toDouble(),
      data: json['data'] as Map<String, dynamic>,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );
  }

  DrawableObjectData copyWith({
    String? id,
    String? toolType,
    int? color,
    double? strokeWidth,
    Map<String, dynamic>? data,
    Map<String, dynamic>? metadata,
  }) {
    return DrawableObjectData(
      id: id ?? this.id,
      toolType: toolType ?? this.toolType,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      data: data ?? this.data,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DrawableObjectData &&
        other.id == id &&
        other.toolType == toolType &&
        other.color == color &&
        other.strokeWidth == strokeWidth &&
        mapEquals(other.data, data) &&
        mapEquals(other.metadata, metadata);
  }

  @override
  int get hashCode => Object.hash(id, toolType, color, strokeWidth, Object.hashAll(data.entries), Object.hashAll(metadata.entries));
}