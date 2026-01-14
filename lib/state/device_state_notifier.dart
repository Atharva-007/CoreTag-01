import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/device_state.dart';
import '../models/custom_widget_state.dart';

/// A [StateNotifier] that manages the global [DeviceState] for the application.
///
/// This notifier holds the current state of the connected hardware device,
/// including its connection status, battery level, theme, active widgets,
/// music playback information, navigation data, weather, and AOD settings.
class DeviceStateNotifier extends StateNotifier<DeviceState> {
  /// Initializes the [DeviceStateNotifier] with a default [DeviceState].
  DeviceStateNotifier() : super(
    DeviceState(
      isConnected: true,
      battery: 85,
      theme: 'dark',
      widgets: [CustomWidgetState(id: 'time-digital-large')],
      music: const MusicState(
        isPlaying: false,
        trackTitle: 'Song Title',
        artist: 'Artist Name',
      ),
      navigation: const NavigationState(),
      weather: const WeatherState(
        condition: 'Sunny',
        temperature: 24,
        location: 'San Francisco',
      ),
      aod: const AODState(enabled: false),
    ),
  );

  /// Updates the entire [DeviceState] with a [newState].
  void updateDeviceState(DeviceState newState) {
    state = newState;
  }

  /// Updates the device's battery level.
  void setBattery(int battery) {
    state = state.copyWith(battery: battery);
  }

  /// Updates the device's theme (e.g., 'dark' or 'light').
  void setTheme(String theme) {
    state = state.copyWith(theme: theme);
  }

  /// Updates the device mode (e.g., 'tag', 'carry', or 'watch').
  void setDeviceMode(String mode) {
    state = state.copyWith(deviceMode: mode);
  }

  /// Toggles the Always-On Display (AOD) enabled status.
  void setAODEnabled(bool enabled) {
    state = state.copyWith(aod: state.aod.copyWith(enabled: enabled));
  }

  /// Updates specific fields of the [MusicState].
  void updateMusicState({String? trackTitle, String? artist, bool? isPlaying, String? albumArt}) {
    state = state.copyWith(
      music: state.music.copyWith(
        trackTitle: trackTitle,
        artist: artist,
        isPlaying: isPlaying,
        albumArt: albumArt,
      ),
    );
  }

  /// Updates specific fields of the [NavigationState].
  void updateNavigationState({bool? isNavigating, String? direction, String? distance, String? eta, double? currentSpeed, String? destination, bool? ridingMode}) {
    state = state.copyWith(
      navigation: state.navigation.copyWith(
        isNavigating: isNavigating,
        direction: direction,
        distance: distance,
        eta: eta,
        currentSpeed: currentSpeed,
        destination: destination,
        ridingMode: ridingMode,
      ),
    );
  }

  /// Updates specific fields of the [WeatherState].
  void updateWeatherState({String? condition, int? temperature, String? location}) {
    state = state.copyWith(
      weather: state.weather.copyWith(
        condition: condition,
        temperature: temperature,
        location: location,
      ),
    );
  }

  /// Adds a [CustomWidgetState] to the list of active widgets.
  void addWidget(CustomWidgetState widget) {
    state = state.copyWith(widgets: [...state.widgets, widget]);
  }

  /// Removes a widget from the list of active widgets by its [widgetId].
  void removeWidget(String widgetId) {
    state = state.copyWith(widgets: state.widgets.where((w) => w.id != widgetId).toList());
  }

  /// Updates an existing widget in the list of active widgets.
  /// If the [updatedWidget] matches an existing one by ID, it replaces it.
  void updateWidget(CustomWidgetState updatedWidget) {
    state = state.copyWith(
      widgets: state.widgets.map((widget) => widget.id == updatedWidget.id ? updatedWidget : widget).toList(),
    );
  }

  /// Sets the custom device name.
  void setCustomName(String name) {
    state = state.copyWith(customName: name);
  }
}

/// A [StateNotifierProvider] that provides the [DeviceStateNotifier].
///
/// Widgets can use `ref.watch(deviceStateNotifierProvider)` to listen to
/// changes in the [DeviceState] and `ref.read(deviceStateNotifierProvider.notifier)`
/// to access methods for modifying the state.
final deviceStateNotifierProvider = StateNotifierProvider<DeviceStateNotifier, DeviceState>((ref) {
  return DeviceStateNotifier();
});