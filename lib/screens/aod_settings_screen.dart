import 'package:flutter/material.dart';
import '../models/device_state.dart';

class AODSettingsScreen extends StatelessWidget {
  final DeviceState deviceState;
  final Function(DeviceState) onUpdate;

  const AODSettingsScreen({
    super.key,
    required this.deviceState,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Time & Display'),
      ),
      body: const Center(
        child: Text('AOD Settings Screen'),
      ),
    );
  }
}
