import 'package:flutter_test/flutter_test.dart';
import 'package:coretag/models/custom_widget_state.dart';
import 'package:flutter/material.dart';

/// Unit tests for CustomWidgetState model
void main() {
  group('CustomWidgetState', () {
    test('should create CustomWidgetState with default values', () {
      final widget = CustomWidgetState(id: 'test-widget');

      expect(widget.id, 'test-widget');
      expect(widget.color, Colors.white);
      expect(widget.size, 1.0);
      expect(widget.opacity, 1.0);
    });

    test('should create CustomWidgetState with custom values', () {
      final widget = CustomWidgetState(
        id: 'custom-widget',
        color: Colors.blue,
        size: 1.5,
        opacity: 0.8,
      );

      expect(widget.id, 'custom-widget');
      expect(widget.color, Colors.blue);
      expect(widget.size, 1.5);
      expect(widget.opacity, 0.8);
    });

    test('should update widget properties', () {
      final widget = CustomWidgetState(id: 'widget-1');

      widget.color = Colors.red;
      widget.size = 2.0;
      widget.opacity = 0.5;

      expect(widget.color, Colors.red);
      expect(widget.size, 2.0);
      expect(widget.opacity, 0.5);
    });
  });
}
