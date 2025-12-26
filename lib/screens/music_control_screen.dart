import 'package:flutter/material.dart';
import '../models/device_state.dart';

class MusicControlScreen extends StatelessWidget {
  final DeviceState deviceState;
  final Function(DeviceState) onUpdate;

  const MusicControlScreen({
    super.key,
    required this.deviceState,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Control'),
      ),
      body: const Center(
        child: Text('Music Control Screen'),
      ),
    );
  }
}
