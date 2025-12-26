import 'package:flutter/material.dart';
import '../models/device_state.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:io';

class DevicePreview extends StatelessWidget {
  final DeviceState deviceState;
  final VoidCallback? onTap;

  const DevicePreview({
    super.key,
    required this.deviceState,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = deviceState.theme == 'dark';
    final currentTime = DateFormat('HH:mm').format(DateTime.now());

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        height: 400,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
            width: 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 30,
              offset: const Offset(0, 15),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              // Background image if present
              if (deviceState.backgroundImage != null)
                Positioned.fill(
                  child: Image.file(
                    File(deviceState.backgroundImage!),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              // Solid color background
              if (deviceState.backgroundImage == null)
                Container(
                  color: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                ),
              // Semi-transparent overlay for readability when image is present
              if (deviceState.backgroundImage != null)
                Container(
                  color: isDark 
                      ? Colors.black.withOpacity(0.4) 
                      : Colors.white.withOpacity(0.5),
                ),
              // Content - with scrolling
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: SizedBox(
                  height: 360, // Constrain height to prevent overflow
                  child: Center(
                    child: _buildMainContent(currentTime, isDark),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBar(String time, bool isDark) {
    // Empty status bar - no time, no battery
    return const SizedBox.shrink();
  }

  Widget _buildMainContent(String time, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black;
    final hasBackground = deviceState.backgroundImage != null;
    
    List<Widget> widgetList = [];
    bool hasNavFull = deviceState.widgets.contains('nav-full') && deviceState.navigation.ridingMode;
    bool hasNavigation = deviceState.widgets.any((w) => w.startsWith('nav-') && deviceState.navigation.ridingMode);

    // If nav-full is active, show ONLY time and navigation
    if (hasNavFull) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Time display at top
          Text(
            time,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 1.2,
              shadows: hasBackground
                  ? [
                      Shadow(
                        color: isDark ? Colors.black : Colors.white,
                        blurRadius: 8,
                        offset: const Offset(0, 0),
                      ),
                      Shadow(
                        color: isDark ? Colors.black : Colors.white,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 24),
          // Navigation widget centered
          _buildNavigationWidget('nav-full', textColor, hasBackground),
        ],
      );
    }

    // Build widgets based on selection (normal mode)
    for (var widget in deviceState.widgets) {
      if (widget.startsWith('time-')) {
        widgetList.add(_buildTimeWidget(widget, time, textColor, hasBackground));
      } else if (widget.startsWith('weather-')) {
        widgetList.add(_buildWeatherWidget(widget, textColor, hasBackground));
      } else if (widget.startsWith('music-')) {
        widgetList.add(_buildMusicWidget(widget, textColor, hasBackground));
      } else if (widget.startsWith('battery-')) {
        widgetList.add(_buildBatteryWidget(widget, textColor, hasBackground));
      } else if (widget.startsWith('photo-')) {
        widgetList.add(_buildPhotoWidget(widget, textColor, hasBackground));
      } else if (widget.startsWith('nav-')) {
        widgetList.add(_buildNavigationWidget(widget, textColor, hasBackground));
      }
    }

    if (widgetList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.widgets_outlined,
              size: 42,
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
            ),
            const SizedBox(height: 10),
            Text(
              'No widgets selected',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // If navigation is active (but not nav-full), show time at top with widgets below
    if (hasNavigation) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Time display at top
          Text(
            time,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
              letterSpacing: 1.0,
              shadows: hasBackground
                  ? [
                      Shadow(
                        color: isDark ? Colors.black : Colors.white,
                        blurRadius: 8,
                        offset: const Offset(0, 0),
                      ),
                      Shadow(
                        color: isDark ? Colors.black : Colors.white,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          // Widgets
          ...widgetList.map((widget) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: widget,
          )),
        ],
      );
    }

    // Default centered layout for non-navigation widgets
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: widgetList.map((widget) => Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: widget,
      )).toList(),
    );
  }

  Widget _buildTimeWidget(String widgetType, String time, Color textColor, bool hasBackground) {
    final shadows = hasBackground ? [
      Shadow(
        color: deviceState.theme == 'dark' ? Colors.black : Colors.white,
        blurRadius: 8,
        offset: const Offset(0, 0),
      ),
      Shadow(
        color: deviceState.theme == 'dark' ? Colors.black : Colors.white,
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ] : null;

    switch (widgetType) {
      case 'time-digital-large':
        return Text(
          time,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w700,
            color: textColor,
            letterSpacing: 2.0,
            height: 1.0,
            shadows: shadows,
          ),
        );
      case 'time-digital-small':
        return Text(
          time,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w600,
            color: textColor,
            letterSpacing: 1.5,
            shadows: shadows,
          ),
        );
      case 'time-analog-small':
        return _buildAnalogClock(50, textColor);
      case 'time-analog-large':
        return _buildAnalogClock(75, textColor);
      case 'time-text-date':
        return Column(
          children: [
            Text(
              time,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w700,
                color: textColor,
                letterSpacing: 1.5,
                shadows: shadows,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              DateFormat('EEE, MMM d').format(DateTime.now()),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor.withOpacity(0.85),
                letterSpacing: 0.5,
                shadows: shadows,
              ),
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildAnalogClock(double size, Color color) {
    final now = DateTime.now();
    final hour = now.hour % 12;
    final minute = now.minute;
    final second = now.second;

    return CustomPaint(
      size: Size(size, size),
      painter: AnalogClockPainter(
        hour: hour,
        minute: minute,
        second: second,
        color: color,
      ),
    );
  }

  Widget _buildWeatherWidget(String widgetType, Color textColor, bool hasBackground) {
    final shadows = hasBackground ? [
      Shadow(
        color: deviceState.theme == 'dark' ? Colors.black : Colors.white,
        blurRadius: 8,
        offset: const Offset(0, 0),
      ),
      Shadow(
        color: deviceState.theme == 'dark' ? Colors.black : Colors.white,
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ] : null;

    switch (widgetType) {
      case 'weather-icon':
        return Text(
          _getWeatherIcon(deviceState.weather.condition),
          style: const TextStyle(fontSize: 40),
        );
      case 'weather-temp-icon':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${deviceState.weather.temperature}°',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: textColor,
                shadows: shadows,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _getWeatherIcon(deviceState.weather.condition),
              style: const TextStyle(fontSize: 30),
            ),
          ],
        );
      case 'weather-full':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _getWeatherIcon(deviceState.weather.condition),
              style: const TextStyle(fontSize: 44),
            ),
            const SizedBox(height: 10),
            Text(
              '${deviceState.weather.temperature}°',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: textColor,
                shadows: shadows,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              deviceState.weather.condition,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: textColor.withOpacity(0.85),
                shadows: shadows,
              ),
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildMusicWidget(String widgetType, Color textColor, bool hasBackground) {
    final shadows = hasBackground ? [
      Shadow(
        color: deviceState.theme == 'dark' ? Colors.black : Colors.white,
        blurRadius: 8,
        offset: const Offset(0, 0),
      ),
      Shadow(
        color: deviceState.theme == 'dark' ? Colors.black : Colors.white,
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ] : null;

    switch (widgetType) {
      case 'music-mini':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: textColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                deviceState.music.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                color: textColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 100),
                child: Text(
                  deviceState.music.trackTitle,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    shadows: shadows,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      case 'music-full':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: textColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.music_note_rounded,
                color: textColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 150),
              child: Text(
                deviceState.music.trackTitle,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  shadows: shadows,
                ),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              deviceState.music.artist,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: textColor.withOpacity(0.75),
                shadows: shadows,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
            const SizedBox(height: 10),
            Icon(
              deviceState.music.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: textColor,
              size: 28,
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildBatteryWidget(String widgetType, Color textColor, bool hasBackground) {
    final shadows = hasBackground ? [
      Shadow(
        color: deviceState.theme == 'dark' ? Colors.black : Colors.white,
        blurRadius: 8,
        offset: const Offset(0, 0),
      ),
      Shadow(
        color: deviceState.theme == 'dark' ? Colors.black : Colors.white,
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ] : null;
    final batteryColor = deviceState.battery > 20 ? Colors.green : Colors.red;

    switch (widgetType) {
      case 'battery-status':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: textColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.battery_charging_full_rounded,
                size: 20,
                color: batteryColor,
              ),
              const SizedBox(width: 6),
              Text(
                '${deviceState.battery}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  shadows: shadows,
                ),
              ),
            ],
          ),
        );
      case 'battery-bar':
        return Column(
          children: [
            Container(
              width: 110,
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                border: Border.all(color: textColor.withOpacity(0.3), width: 2),
                color: textColor.withOpacity(0.05),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: FractionallySizedBox(
                  widthFactor: deviceState.battery / 100,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [batteryColor, batteryColor.withOpacity(0.7)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '${deviceState.battery}%',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
                shadows: shadows,
              ),
            ),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildPhotoWidget(String widgetType, Color textColor, bool hasBackground) {
    // Photo widget is just for enabling background image
    // The actual photo is shown as background, not as a widget
    return const SizedBox.shrink();
  }

  Widget _buildNavigationWidget(String widgetType, Color textColor, bool hasBackground) {
    if (!deviceState.navigation.ridingMode) return const SizedBox();

    // Get direction icon
    IconData getDirectionIcon() {
      switch (deviceState.navigation.direction.toLowerCase()) {
        case 'turn left':
          return Icons.turn_left;
        case 'turn right':
          return Icons.turn_right;
        case 'keep straight':
          return Icons.arrow_upward;
        case 'u-turn':
          return Icons.u_turn_left;
        case 'slight left':
          return Icons.turn_slight_left;
        case 'slight right':
          return Icons.turn_slight_right;
        case 'sharp left':
          return Icons.turn_sharp_left;
        case 'sharp right':
          return Icons.turn_sharp_right;
        default:
          return Icons.navigation;
      }
    }

    switch (widgetType) {
      case 'nav-compact':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A73E8), Color(0xFF0E62C7)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1A73E8).withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(getDirectionIcon(), color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                deviceState.navigation.distance,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        );
      case 'nav-full':
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: textColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                getDirectionIcon(),
                color: textColor,
                size: 38,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              deviceState.navigation.direction,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: textColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.straighten, color: textColor, size: 14),
                  const SizedBox(width: 5),
                  Text(
                    deviceState.navigation.distance,
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Icon(Icons.access_time, color: textColor, size: 14),
                  const SizedBox(width: 5),
                  Text(
                    deviceState.navigation.eta,
                    style: TextStyle(
                      fontSize: 12,
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
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

// Custom painter for analog clock
class AnalogClockPainter extends CustomPainter {
  final int hour;
  final int minute;
  final int second;
  final Color color;

  AnalogClockPainter({
    required this.hour,
    required this.minute,
    required this.second,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw circle
    final circlePaint = Paint()
      ..color = color.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, circlePaint);

    // Draw hour hand
    final hourAngle = (hour * 30 + minute * 0.5) * math.pi / 180;
    final hourPaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * 0.5 * math.sin(hourAngle),
        center.dy - radius * 0.5 * math.cos(hourAngle),
      ),
      hourPaint,
    );

    // Draw minute hand
    final minuteAngle = minute * 6 * math.pi / 180;
    final minutePaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * 0.7 * math.sin(minuteAngle),
        center.dy - radius * 0.7 * math.cos(minuteAngle),
      ),
      minutePaint,
    );

    // Draw center dot
    canvas.drawCircle(center, 3, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
