import 'package:flutter/material.dart';
import '../models/device_state.dart';

class ThemesWidgetsScreen extends StatelessWidget {
  final DeviceState deviceState;
  final Function(DeviceState) onUpdate;

  const ThemesWidgetsScreen({
    super.key,
    required this.deviceState,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Themes & Widgets'),
      ),
      body: const Center(
        child: Text('Themes & Widgets Screen'),
      ),
    );
  }
}
