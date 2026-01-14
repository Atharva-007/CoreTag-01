import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:coretag/state/device_state_notifier.dart';
import 'package:coretag/models/device_state.dart';
import 'package:coretag/models/custom_widget_state.dart';

/// Unit tests for DeviceStateNotifier
void main() {
  group('DeviceStateNotifier', () {
    late ProviderContainer container;
    late DeviceStateNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(deviceStateNotifierProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with default state', () {
      final state = container.read(deviceStateNotifierProvider);

      expect(state.isConnected, true);
      expect(state.battery, 85);
      expect(state.theme, 'dark');
      expect(state.widgets.length, 1);
    });

    test('should update battery level', () {
      notifier.setBattery(50);
      final state = container.read(deviceStateNotifierProvider);

      expect(state.battery, 50);
    });

    test('should update theme', () {
      notifier.setTheme('light');
      final state = container.read(deviceStateNotifierProvider);

      expect(state.theme, 'light');
    });

    test('should update device mode', () {
      notifier.setDeviceMode('watch');
      final state = container.read(deviceStateNotifierProvider);

      expect(state.deviceMode, 'watch');
    });

    test('should enable/disable AOD', () {
      notifier.setAODEnabled(true);
      var state = container.read(deviceStateNotifierProvider);
      expect(state.aod.enabled, true);

      notifier.setAODEnabled(false);
      state = container.read(deviceStateNotifierProvider);
      expect(state.aod.enabled, false);
    });

    test('should update music state', () {
      notifier.updateMusicState(
        trackTitle: 'Test Song',
        artist: 'Test Artist',
        isPlaying: true,
      );

      final state = container.read(deviceStateNotifierProvider);
      expect(state.music.trackTitle, 'Test Song');
      expect(state.music.artist, 'Test Artist');
      expect(state.music.isPlaying, true);
    });

    test('should update navigation state', () {
      notifier.updateNavigationState(
        isNavigating: true,
        direction: 'Turn Right',
        distance: '500m',
      );

      final state = container.read(deviceStateNotifierProvider);
      expect(state.navigation.isNavigating, true);
      expect(state.navigation.direction, 'Turn Right');
      expect(state.navigation.distance, '500m');
    });

    test('should update weather state', () {
      notifier.updateWeatherState(
        condition: 'Cloudy',
        temperature: 20,
        location: 'London',
      );

      final state = container.read(deviceStateNotifierProvider);
      expect(state.weather.condition, 'Cloudy');
      expect(state.weather.temperature, 20);
      expect(state.weather.location, 'London');
    });

    test('should add widget', () {
      final widget = CustomWidgetState(id: 'new-widget');
      final initialCount = container.read(deviceStateNotifierProvider).widgets.length;

      notifier.addWidget(widget);
      final state = container.read(deviceStateNotifierProvider);

      expect(state.widgets.length, initialCount + 1);
      expect(state.widgets.last.id, 'new-widget');
    });

    test('should remove widget', () {
      final initialState = container.read(deviceStateNotifierProvider);
      final widgetId = initialState.widgets.first.id;

      notifier.removeWidget(widgetId);
      final state = container.read(deviceStateNotifierProvider);

      expect(state.widgets.where((w) => w.id == widgetId), isEmpty);
    });

    test('should update widget', () {
      final state = container.read(deviceStateNotifierProvider);
      final widgetId = state.widgets.first.id;
      
      final updatedWidget = CustomWidgetState(
        id: widgetId,
        size: 2.0,
      );

      notifier.updateWidget(updatedWidget);
      final newState = container.read(deviceStateNotifierProvider);
      final widget = newState.widgets.firstWhere((w) => w.id == widgetId);

      expect(widget.size, 2.0);
    });

    test('should set custom name', () {
      notifier.setCustomName('My Device');
      final state = container.read(deviceStateNotifierProvider);

      expect(state.customName, 'My Device');
    });
  });
}
