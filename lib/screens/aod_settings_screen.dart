import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/device_state_notifier.dart';
import '../models/device_state.dart';
import '../models/custom_widget_state.dart';
import 'dashboard_screen.dart'; // Import DashboardScreen to access allWidgetCards

class AodSettingsScreen extends ConsumerStatefulWidget {
  const AodSettingsScreen({super.key});

  @override
  ConsumerState<AodSettingsScreen> createState() => _AodSettingsScreenState();
}

class _AodSettingsScreenState extends ConsumerState<AodSettingsScreen> {
  // Assume for now that allWidgetCards is globally accessible as it was moved outside
  // the DashboardScreen class. If not, it needs to be passed here.

  @override
  Widget build(BuildContext context) {
    final deviceState = ref.watch(deviceStateNotifierProvider);
    final notifier = ref.read(deviceStateNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AOD Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SwitchListTile(
            title: const Text('Enable Always-On Display'),
            value: deviceState.aod.enabled,
            onChanged: (bool value) {
              notifier.setAODEnabled(value);
            },
          ),
          ListTile(
            title: const Text('AOD Background'),
            subtitle: const Text('Choose a background for AOD mode'),
            trailing: Icon(Icons.arrow_forward_ios),
            onTap: () {
              // TODO: Implement background selection for AOD
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('AOD Background selection not yet implemented.')),
              );
            },
          ),
          _buildAODWidgetsSection(deviceState, notifier),
        ],
      ),
    );
  }

  Widget _buildAODWidgetsSection(DeviceState deviceState, DeviceStateNotifier notifier) {
    // Filter widgets that are suitable for AOD (e.g., time, battery)
    // For simplicity, let's assume all widgets can be AOD widgets for now
    final availableAODWidgets = allWidgetCards; // Use the globally available allWidgetCards

    return ExpansionTile(
      title: const Text('AOD Widgets'),
      subtitle: const Text('Select widgets to display in AOD mode'),
      children: availableAODWidgets.map((widgetCard) {
        final isSelected = deviceState.aod.widgets.any((w) => w.id == widgetCard.id);
        return CheckboxListTile(
          title: Text(widgetCard.title),
          value: isSelected,
          onChanged: (bool? value) {
            if (value == true) {
              notifier.updateDeviceState(deviceState.copyWith(
                aod: deviceState.aod.copyWith(
                  widgets: [...deviceState.aod.widgets, CustomWidgetState(id: widgetCard.id)]
                )
              ));
            } else {
              notifier.updateDeviceState(deviceState.copyWith(
                aod: deviceState.aod.copyWith(
                  widgets: deviceState.aod.widgets.where((w) => w.id != widgetCard.id).toList()
                )
              ));
            }
          },
        );
      }).toList(),
    );
  }
}