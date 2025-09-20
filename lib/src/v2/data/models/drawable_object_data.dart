import 'dart:ui';
import 'package:window_paint/src/v2/data/models/draw_point_data.dart';

/// Base data model for all drawable objects.
/// 
/// This provides a clean, serializable representation that can be easily
/// converted to/from JSON for server-side rendering with iTextSharp.
abstract class DrawableObjectData {
  const DrawableObjectData({
    required this.id,
    required this.toolType,
    required this.color,
    required this.strokeWidth,
    this.metadata = const {},
  });

  /// Unique identifier for this object
  final String id;
  
  /// Type of tool that created this object
  final String toolType;
  
  /// Primary color as ARGB integer
  final int color;
  
  /// Stroke width for rendering
  final double strokeWidth;
  
  /// Additional metadata for extensibility
  final Map<String, dynamic> metadata;

  /// Converts color integer to Color object
  Color get colorValue => Color(color);

  /// Converts to JSON representation
  Map<String, dynamic> toJson();

  /// Creates from JSON representation
  static DrawableObjectData fromJson(Map<String, dynamic> json) {
    final toolType = json['toolType'] as String;
    
    switch (toolType) {
      case 'pencil':
        return PencilObjectData.fromJson(json);
      case 'rectangle':
        return RectangleObjectData.fromJson(json);
      case 'rectangle_cross':
        return RectangleCrossObjectData.fromJson(json);
      case 'text':
        return TextObjectData.fromJson(json);
      default:
        throw ArgumentError('Unknown tool type: $toolType');
    }
  }
}

/// Data model for pencil/freehand drawing objects
class PencilObjectData extends DrawableObjectData {
  const PencilObjectData({
    required super.id,
    required super.color,
    required super.strokeWidth,
    required this.points,
    this.simplified = false,
    super.metadata = const {},
  }) : super(toolType: 'pencil');

  /// List of points that make up this pencil stroke
  final List<DrawPointData> points;
  
  /// Whether the points have been simplified for optimization
  final bool simplified;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'toolType': toolType,
      'color': color,
      'strokeWidth': strokeWidth,
      'points': points.map((p) => p.toJson()).toList(),
      'simplified': simplified,
      'metadata': metadata,
    };
  }

  static PencilObjectData fromJson(Map<String, dynamic> json) {
    return PencilObjectData(
      id: json['id'] as String,
      color: json['color'] as int,
      strokeWidth: (json['strokeWidth'] as num).toDouble(),
      points: (json['points'] as List)
          .map((p) => DrawPointData.fromJson(p as Map<String, dynamic>))
          .toList(),
      simplified: json['simplified'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );
  }

  PencilObjectData copyWith({
    String? id,
    int? color,
    double? strokeWidth,
    List<DrawPointData>? points,
    bool? simplified,
    Map<String, dynamic>? metadata,
  }) {
    return PencilObjectData(
      id: id ?? this.id,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      points: points ?? this.points,
      simplified: simplified ?? this.simplified,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Data model for rectangle objects
class RectangleObjectData extends DrawableObjectData {
  const RectangleObjectData({
    required super.id,
    required super.color,
    required super.strokeWidth,
    required this.startPoint,
    required this.endPoint,
    this.filled = false,
    super.metadata = const {},
  }) : super(toolType: 'rectangle');

  /// Starting point of the rectangle
  final DrawPointData startPoint;
  
  /// Ending point of the rectangle
  final DrawPointData endPoint;
  
  /// Whether the rectangle should be filled
  final bool filled;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'toolType': toolType,
      'color': color,
      'strokeWidth': strokeWidth,
      'startPoint': startPoint.toJson(),
      'endPoint': endPoint.toJson(),
      'filled': filled,
      'metadata': metadata,
    };
  }

  static RectangleObjectData fromJson(Map<String, dynamic> json) {
    return RectangleObjectData(
      id: json['id'] as String,
      color: json['color'] as int,
      strokeWidth: (json['strokeWidth'] as num).toDouble(),
      startPoint: DrawPointData.fromJson(json['startPoint'] as Map<String, dynamic>),
      endPoint: DrawPointData.fromJson(json['endPoint'] as Map<String, dynamic>),
      filled: json['filled'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );
  }

  RectangleObjectData copyWith({
    String? id,
    int? color,
    double? strokeWidth,
    DrawPointData? startPoint,
    DrawPointData? endPoint,
    bool? filled,
    Map<String, dynamic>? metadata,
  }) {
    return RectangleObjectData(
      id: id ?? this.id,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      filled: filled ?? this.filled,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Data model for rectangle with cross objects
class RectangleCrossObjectData extends RectangleObjectData {
  const RectangleCrossObjectData({
    required super.id,
    required super.color,
    required super.strokeWidth,
    required super.startPoint,
    required super.endPoint,
    super.filled = false,
    super.metadata = const {},
  }) : super(toolType: 'rectangle_cross');

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    json['toolType'] = 'rectangle_cross';
    return json;
  }

  static RectangleCrossObjectData fromJson(Map<String, dynamic> json) {
    return RectangleCrossObjectData(
      id: json['id'] as String,
      color: json['color'] as int,
      strokeWidth: (json['strokeWidth'] as num).toDouble(),
      startPoint: DrawPointData.fromJson(json['startPoint'] as Map<String, dynamic>),
      endPoint: DrawPointData.fromJson(json['endPoint'] as Map<String, dynamic>),
      filled: json['filled'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );
  }
}

/// Data model for text annotation objects
class TextObjectData extends DrawableObjectData {
  const TextObjectData({
    required super.id,
    required super.color,
    required this.text,
    required this.position,
    required this.fontSize,
    this.fontFamily = 'Arial',
    this.fontWeight = 400,
    this.italic = false,
    super.strokeWidth = 1.0,
    super.metadata = const {},
  }) : super(toolType: 'text');

  /// The text content
  final String text;
  
  /// Position of the text
  final DrawPointData position;
  
  /// Font size
  final double fontSize;
  
  /// Font family name
  final String fontFamily;
  
  /// Font weight (100-900)
  final int fontWeight;
  
  /// Whether the text is italic
  final bool italic;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'toolType': toolType,
      'color': color,
      'strokeWidth': strokeWidth,
      'text': text,
      'position': position.toJson(),
      'fontSize': fontSize,
      'fontFamily': fontFamily,
      'fontWeight': fontWeight,
      'italic': italic,
      'metadata': metadata,
    };
  }

  static TextObjectData fromJson(Map<String, dynamic> json) {
    return TextObjectData(
      id: json['id'] as String,
      color: json['color'] as int,
      strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 1.0,
      text: json['text'] as String,
      position: DrawPointData.fromJson(json['position'] as Map<String, dynamic>),
      fontSize: (json['fontSize'] as num).toDouble(),
      fontFamily: json['fontFamily'] as String? ?? 'Arial',
      fontWeight: json['fontWeight'] as int? ?? 400,
      italic: json['italic'] as bool? ?? false,
      metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
    );
  }

  TextObjectData copyWith({
    String? id,
    int? color,
    double? strokeWidth,
    String? text,
    DrawPointData? position,
    double? fontSize,
    String? fontFamily,
    int? fontWeight,
    bool? italic,
    Map<String, dynamic>? metadata,
  }) {
    return TextObjectData(
      id: id ?? this.id,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      text: text ?? this.text,
      position: position ?? this.position,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      fontWeight: fontWeight ?? this.fontWeight,
      italic: italic ?? this.italic,
      metadata: metadata ?? this.metadata,
    );
  }
}