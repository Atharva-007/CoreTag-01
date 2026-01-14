import 'package:flutter_test/flutter_test.dart';
import 'package:coretag/models/device_state.dart';

/// Unit tests for DeviceState model
void main() {
  group('DeviceState', () {
    test('should create default DeviceState', () {
      final state = DeviceState(
        music: const MusicState(),
        navigation: const NavigationState(),
        weather: const WeatherState(),
        aod: const AODState(),
      );

      expect(state.isConnected, false);
      expect(state.battery, 85);
      expect(state.theme, 'dark');
      expect(state.deviceMode, 'tag');
      expect(state.widgets, isEmpty);
    });

    test('should copy DeviceState with new values', () {
      final original = DeviceState(
        battery: 50,
        theme: 'light',
        music: const MusicState(),
        navigation: const NavigationState(),
        weather: const WeatherState(),
        aod: const AODState(),
      );

      final copied = original.copyWith(
        battery: 75,
        theme: 'dark',
      );

      expect(copied.battery, 75);
      expect(copied.theme, 'dark');
      expect(original.battery, 50); // Original unchanged
    });

    test('should update device mode', () {
      final state = DeviceState(
        deviceMode: 'tag',
        music: const MusicState(),
        navigation: const NavigationState(),
        weather: const WeatherState(),
        aod: const AODState(),
      );

      final updated = state.copyWith(deviceMode: 'watch');
      expect(updated.deviceMode, 'watch');
    });
  });

  group('MusicState', () {
    test('should create default MusicState', () {
      const state = MusicState();

      expect(state.isPlaying, false);
      expect(state.trackTitle, 'No Track');
      expect(state.artist, 'Unknown');
      expect(state.albumArt, null);
    });

    test('should copy MusicState with new values', () {
      const original = MusicState(
        trackTitle: 'Song 1',
        artist: 'Artist 1',
      );

      final copied = original.copyWith(
        trackTitle: 'Song 2',
        isPlaying: true,
      );

      expect(copied.trackTitle, 'Song 2');
      expect(copied.artist, 'Artist 1');
      expect(copied.isPlaying, true);
    });
  });

  group('NavigationState', () {
    test('should create default NavigationState', () {
      const state = NavigationState();

      expect(state.ridingMode, false);
      expect(state.isNavigating, false);
      expect(state.direction, 'Turn Left');
      expect(state.distance, '500m');
    });

    test('should update navigation state', () {
      const original = NavigationState(isNavigating: false);
      final updated = original.copyWith(
        isNavigating: true,
        direction: 'Turn Right',
        distance: '1km',
      );

      expect(updated.isNavigating, true);
      expect(updated.direction, 'Turn Right');
      expect(updated.distance, '1km');
    });
  });

  group('WeatherState', () {
    test('should create default WeatherState', () {
      const state = WeatherState();

      expect(state.condition, 'Sunny');
      expect(state.temperature, 24);
      expect(state.location, 'City');
    });

    test('should update weather values', () {
      const original = WeatherState();
      final updated = original.copyWith(
        condition: 'Rainy',
        temperature: 18,
        location: 'New York',
      );

      expect(updated.condition, 'Rainy');
      expect(updated.temperature, 18);
      expect(updated.location, 'New York');
    });
  });

  group('AODState', () {
    test('should create default AODState', () {
      const state = AODState();

      expect(state.enabled, false);
      expect(state.timeout, 'always');
      expect(state.widgets, isEmpty);
    });

    test('should enable AOD', () {
      const original = AODState(enabled: false);
      final updated = original.copyWith(enabled: true);

      expect(updated.enabled, true);
    });
  });
}
