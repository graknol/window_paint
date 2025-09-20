import 'dart:ui';

/// Simple data class for transformation information
class TransformationData {
  const TransformationData({
    this.translation = Offset.zero,
    this.scale = 1.0,
    this.rotation = 0.0,
  });

  final Offset translation;
  final double scale;
  final double rotation;

  Matrix4 toMatrix4() {
    return Matrix4.identity()
      ..translate(translation.dx, translation.dy)
      ..scale(scale)
      ..rotateZ(rotation);
  }

  factory TransformationData.fromMatrix4(Matrix4 matrix) {
    // Extract transformation components from matrix
    final translation = Offset(matrix.getTranslation().x, matrix.getTranslation().y);
    final scale = matrix.getMaxScaleOnAxis();
    
    return TransformationData(
      translation: translation,
      scale: scale,
      rotation: 0.0, // Rotation extraction is more complex, skip for now
    );
  }

  @override
  String toString() {
    return 'TransformationData(translation: $translation, scale: $scale, rotation: $rotation)';
  }
}