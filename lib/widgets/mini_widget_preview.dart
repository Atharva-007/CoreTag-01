import 'package:flutter/material.dart';
import '../models/device_state.dart';
import 'package:intl/intl.dart';
import 'painters/modern_analog_clock_painter.dart';

class MiniWidgetPreview extends StatelessWidget {
  final String widgetId;
  final DeviceState deviceState; // Context for rendering, e.g., theme, weather, music data
  final double size; // Overall size of the mini preview

  const MiniWidgetPreview({
    super.key,
    required this.widgetId,
    required this.deviceState,
    this.size = 60, // Default size for the mini preview
  });

  @override
  Widget build(BuildContext context) {
    final isDark = deviceState.theme == 'dark';
    final textColor = isDark ? Colors.white : Colors.black;
    final currentTime = DateFormat('HH:mm').format(DateTime.now());
    final shadows = (deviceState.backgroundImage != null)
        ? [
            Shadow(color: isDark ? Colors.black : Colors.white, blurRadius: 4, offset: const Offset(0, 0)),
          ]
        : null;

    Widget content;

    if (widgetId.startsWith('time-')) {
      content = _buildTimeWidgetContent(widgetId, currentTime, textColor, shadows, 0.5, 1, false, DateTime.now());
    } else if (widgetId.startsWith('weather-')) {
      content = _buildWeatherWidgetContent(widgetId, textColor, shadows, 0.5, 1, false);
    } else if (widgetId.startsWith('music-')) {
      content = _buildMusicWidgetContent(widgetId, textColor, shadows, 1);
    } else if (widgetId.startsWith('battery-')) {
      final batteryColor = deviceState.battery > 20 ? Colors.green : Colors.red;
      content = _buildBatteryWidgetContent(widgetId, textColor, shadows, 0.5, false, batteryColor);
    } else {
      content = const Icon(Icons.widgets, size: 20); // Default icon for unknown widgets
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withValues(alpha: 0.05) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade300,
          width: 0.5,
        ),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: SizedBox(
            width: size * 0.8,
            height: size * 0.8,
            child: content,
          ),
        ),
      ),
    );
  }

  // --- Helper methods adapted from DevicePreview ---
  // These methods are simplified and adapted to render miniature versions
  // of the widgets. They don't include interactive elements or full adaptive logic.

  Widget _buildTimeWidgetContent(String widgetType, String time, Color textColor, List<Shadow>? shadows, double scale, int widgetCount, bool hasWeather, DateTime now) {
    switch (widgetType) {
      case 'time-digital-large':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('MMMd').format(now),
              style: TextStyle(fontSize: 8, color: textColor.withValues(alpha: 0.8), shadows: shadows),
            ),
            Text(
              time,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: textColor, shadows: shadows, fontFeatures: const [FontFeature.tabularFigures()]),
            ),
          ],
        );
      case 'time-digital-small':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              time,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: textColor, shadows: shadows, fontFeatures: const [FontFeature.tabularFigures()]),
            ),
            Text(
              DateFormat('EEE').format(now),
              style: TextStyle(fontSize: 7, color: textColor.withValues(alpha: 0.7), shadows: shadows),
            ),
          ],
        );
      case 'time-analog-small':
        return SizedBox(
          width: size * 0.7,
          height: size * 0.7,
          child: _buildModernAnalogClock(size * 0.7, textColor, false),
        );
      case 'time-analog-large':
        return SizedBox(
          width: size * 0.8,
          height: size * 0.8,
          child: _buildModernAnalogClock(size * 0.8, textColor, true),
        );
      case 'time-text-date':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              time,
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: textColor, shadows: shadows, fontFeatures: const [FontFeature.tabularFigures()]),
            ),
            Text(
              DateFormat('MMM d').format(now),
              style: TextStyle(fontSize: 8, color: textColor.withValues(alpha: 0.8), shadows: shadows),
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildModernAnalogClock(double size, Color color, bool showMarkers) {
    final now = DateTime.now();
    final hour = now.hour % 12;
    final minute = now.minute;

    return CustomPaint(
      size: Size(size, size),
      painter: ModernAnalogClockPainter(
        hour: hour,
        minute: minute,
        second: 0, // No seconds hand for mini preview
        color: color,
        showMarkers: showMarkers,
      ),
    );
  }

  Widget _buildWeatherWidgetContent(String widgetType, Color textColor, List<Shadow>? shadows, double weatherScale, int widgetCount, bool hasTime) {
    final weatherCondition = deviceState.weather.condition;
    final weatherTemp = deviceState.weather.temperature;
    final weatherIcon = _getWeatherIcon(weatherCondition);

    switch (widgetType) {
      case 'weather-icon':
        return Text(
          weatherIcon,
          style: TextStyle(fontSize: 20, shadows: shadows),
        );
      case 'weather-temp-icon':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              weatherIcon,
              style: TextStyle(fontSize: 16, shadows: shadows),
            ),
            const SizedBox(width: 4),
            Text(
              '$weatherTemp°',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: textColor, shadows: shadows, fontFeatures: const [FontFeature.tabularFigures()]),
            ),
          ],
        );
      case 'weather-full':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              weatherIcon,
              style: TextStyle(fontSize: 18, shadows: shadows),
            ),
            Text(
              '$weatherTemp°',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: textColor, shadows: shadows, fontFeatures: const [FontFeature.tabularFigures()]),
            ),
            Text(
              weatherCondition,
              style: TextStyle(fontSize: 7, color: textColor.withValues(alpha: 0.7), shadows: shadows),
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildMusicWidgetContent(String widgetType, Color textColor, List<Shadow>? shadows, int widgetCount) {
    switch (widgetType) {
      case 'music-mini':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.music_note, size: 18, color: textColor),
            Text(
              deviceState.music.trackTitle,
              style: TextStyle(fontSize: 7, color: textColor, shadows: shadows),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              deviceState.music.artist,
              style: TextStyle(fontSize: 6, color: textColor.withValues(alpha: 0.7), shadows: shadows),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        );
      case 'music-full':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.music_note_rounded, size: 20, color: textColor),
            Text(
              deviceState.music.trackTitle,
              style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: textColor, shadows: shadows),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              deviceState.music.artist,
              style: TextStyle(fontSize: 7, color: textColor.withValues(alpha: 0.7), shadows: shadows),
              overflow: TextOverflow.ellipsis,
            ),
            Icon(
              deviceState.music.isPlaying ? Icons.pause : Icons.play_arrow,
              size: 14,
              color: textColor,
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildBatteryWidgetContent(String widgetType, Color textColor, List<Shadow>? shadows, double scale, bool compact, Color batteryColor) {
    switch (widgetType) {
      case 'battery-status':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.battery_full, size: 14, color: batteryColor),
            Text(
              '${deviceState.battery}%',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textColor, shadows: shadows),
            ),
          ],
        );
      case 'battery-bar':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size * 0.7,
              height: 5,
              child: LinearProgressIndicator(
                value: deviceState.battery / 100,
                backgroundColor: textColor.withValues(alpha: 0.2),
                valueColor: AlwaysStoppedAnimation<Color>(batteryColor),
              ),
            ),
            Text(
              '${deviceState.battery}%',
              style: TextStyle(fontSize: 9, color: textColor, shadows: shadows),
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  String _getWeatherIcon(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return '☀️';
      case 'cloudy':
      case 'partly cloudy':
        return '⛅';
      case 'rainy':
      case 'rain':
        return '🌧️';
      case 'stormy':
      case 'thunderstorm':
        return '⛈️';
      case 'snowy':
      case 'snow':
        return '❄️';
      default:
        return '🌤️';
    }
  }
}