import 'package:flutter_test/flutter_test.dart';

import 'window_paint_simple_test.dart' as window_paint_simple;
import 'drawing_objects_test.dart' as drawing_objects;
import 'widget_test.dart' as widget_tests;
import 'controller_internal_test.dart' as controller_internal;

/// Comprehensive test suite for the simplified window_paint implementation.
/// 
/// This test suite verifies:
/// - Core functionality of drawing tools and objects
/// - JSON serialization and deserialization
/// - Widget integration and UI behavior
/// - Controller state management
/// - Internal helper methods
/// - Error handling and edge cases
void main() {
  group('Window Paint Simple - Complete Test Suite', () {
    group('Controller and Basic Functionality', window_paint_simple.main);
    group('Drawing Objects', drawing_objects.main);
    group('Widget Integration', widget_tests.main);
    group('Controller Internal Methods', controller_internal.main);
  });
}