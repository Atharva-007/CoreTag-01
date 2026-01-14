import 'package:flutter/material.dart';
import '../../models/device_state.dart';
import '../../models/custom_widget_state.dart';

class MusicOptionsPanel extends StatelessWidget {
  final DeviceState deviceState;
  final Function(DeviceState) onUpdate;

  const MusicOptionsPanel({
    super.key,
    required this.deviceState,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    bool hasMusicWidget = deviceState.widgets.any((w) => w.id.startsWith('music-'));

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0), // Added padding for text
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Show Music Widget',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Switch(
                  value: hasMusicWidget,
                  onChanged: (bool newValue) {
                    List<CustomWidgetState> updatedWidgets = List.from(deviceState.widgets);
                    if (newValue) {
                      // Add default music widget if not present
                      if (!hasMusicWidget) {
                        updatedWidgets.add(CustomWidgetState(id: 'music-mini')); // Default music widget
                      }
                    } else {
                      // Remove all music widgets
                      updatedWidgets.removeWhere((w) => w.id.startsWith('music-'));
                    }
                    onUpdate(deviceState.copyWith(widgets: updatedWidgets));
                  },
                ),
              ],
            ),
          ),
          // Add more music customization options here if needed
        ],
      ),
    );
  }
}
