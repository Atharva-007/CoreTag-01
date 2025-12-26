import 'package:flutter/material.dart';
import '../models/device_state.dart';

class NavigationScreen extends StatelessWidget {
  final DeviceState deviceState;
  final Function(DeviceState) onUpdate;

  const NavigationScreen({
    super.key,
    required this.deviceState,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Navigation'),
      ),
      body: const Center(
        child: Text('Navigation Screen'),
      ),
    );
  }
}
