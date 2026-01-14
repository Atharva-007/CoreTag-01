import 'package:flutter/material.dart';
import '../../models/device_state.dart';
import '../../models/custom_widget_state.dart';

class WeatherOptionsPanel extends StatelessWidget {
  final DeviceState deviceState;
  final Function(DeviceState) onUpdate;

  const WeatherOptionsPanel({
    super.key,
    required this.deviceState,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    bool hasWeatherWidget = deviceState.widgets.any((w) => w.id.startsWith('weather-'));

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
                  'Show Weather Widget',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Switch(
                  value: hasWeatherWidget,
                  onChanged: (bool newValue) {
                    List<CustomWidgetState> updatedWidgets = List.from(deviceState.widgets);
                    if (newValue) {
                      // Add default weather widget if not present
                      if (!hasWeatherWidget) {
                        updatedWidgets.add(CustomWidgetState(id: 'weather-icon')); // Default weather widget
                      }
                    } else {
                      // Remove all weather widgets
                      updatedWidgets.removeWhere((w) => w.id.startsWith('weather-'));
                    }
                    onUpdate(deviceState.copyWith(widgets: updatedWidgets));
                  },
                ),
              ],
            ),
          ),
          // Add more weather customization options here if needed
        ],
      ),
    );
  }
}
