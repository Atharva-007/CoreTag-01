import 'package:flutter/material.dart';

class CustomWidgetState {
  String id;
  Color color;
  double size;
  double opacity;

  CustomWidgetState({
    required this.id,
    this.color = Colors.white,
    this.size = 1.0,
    this.opacity = 1.0,
  });
}
