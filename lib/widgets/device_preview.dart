import 'package:flutter/material.dart';
import '../models/device_state.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import '../models/custom_widget_state.dart';
import '../models/widget_card.dart';
import 'painters/modern_analog_clock_painter.dart'; 

class DevicePreview extends StatelessWidget {
  final DeviceState deviceState;
  final String? selectedWidgetId;
  final Function(String?)? onWidgetSelected;
  final double width;
  final List<WidgetCard> allWidgetCards;

  const DevicePreview({
    super.key,
    required this.deviceState,
    this.selectedWidgetId,
    this.onWidgetSelected,
    this.width = 150,
    required this.allWidgetCards,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = deviceState.theme == 'dark';
    final currentTime = DateFormat('HH:mm').format(DateTime.now());

    return RepaintBoundary(
      child: SizedBox(
        width: width,
        child: AspectRatio(
          aspectRatio: 9 / 19.5,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1F1F1F), const Color(0xFF121212)]
                    : [Colors.white, Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? Colors.grey.shade700 : Colors.grey.shade300,
                width: 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (deviceState.backgroundImage != null)
                    Positioned.fill(
                      child: RepaintBoundary(
                        child: ClipRect(
                          child: Image.file(
                            File(deviceState.backgroundImage!),
                            fit: BoxFit.cover,
                            cacheWidth: 300,
                            cacheHeight: 650,
                            filterQuality: FilterQuality.low,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (deviceState.backgroundImage == null)
                    Container(
                      color: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isDark
                              ? [
                                  Colors.black.withOpacity(0.25),
                                  Colors.black.withOpacity(0.45),
                                  Colors.black.withOpacity(0.25),
                                ]
                              : [
                                  Colors.black.withOpacity(0.15),
                                  Colors.black.withOpacity(0.15),
                                  Colors.black.withOpacity(0.15),
                                ],
                        ),
                      ),
                    ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                      child: RepaintBoundary(
                        child: _buildMainContent(currentTime, isDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(String time, bool isDark) {
    final textColor = isDark ? Colors.white : Colors.black;
    final hasBackground = deviceState.backgroundImage != null;
    
    List<Widget> widgetsToDisplay = [];

    // Check if music is playing
    final bool isMusicPlaying = deviceState.music.isPlaying;
    
    // Check if navigation is active
    final bool isNavigating = deviceState.navigation.isNavigating;

    // Get selected widget types
    final hasLargeMusicWidget = deviceState.widgets.any((w) => w.id == 'music-full');
    final hasLargeNavWidget = deviceState.widgets.any((w) => w.id == 'nav-full');

    // NEW PRIORITY LOGIC:
    // 1. Large music widget selected + music playing → Show ONLY music + time
    // 2. Large navigation selected + NOT music playing → Show large navigation + time
    // 3. Mini navigation + music playing → Show time + music + mini navigation
    // 4. Navigation active → Auto-show navigation
    // 5. Default → Show all enabled widgets

    // Rule 1: Large music widget with music playing
    if (hasLargeMusicWidget && isMusicPlaying) {
      // Show ONLY large music + time
      for (var widgetState in deviceState.widgets) {
        if (widgetState.id == 'music-full') {
          widgetsToDisplay.add(_buildMusicWidget(widgetState, textColor, hasBackground, isDark));
        } else if (widgetState.id.startsWith('time-')) {
          widgetsToDisplay.add(_buildTimeWidget(widgetState, time, textColor, hasBackground, isDark));
        }
      }
    }
    // Rule 2: Large navigation widget when music NOT playing
    else if (hasLargeNavWidget && !isMusicPlaying) {
      // Show large navigation + time
      for (var widgetState in deviceState.widgets) {
        if (widgetState.id == 'nav-full') {
          widgetsToDisplay.add(_buildNavigationWidget(widgetState, textColor, hasBackground, isDark));
        } else if (widgetState.id.startsWith('time-')) {
          widgetsToDisplay.add(_buildTimeWidget(widgetState, time, textColor, hasBackground, isDark));
        }
      }
    }
    // Rule 3: Navigation is active (auto-show navigation)
    else if (isNavigating) {
      final navCustomWidgetState = deviceState.widgets.firstWhere(
        (state) => state.id.startsWith('nav-'),
        orElse: () => CustomWidgetState(id: 'nav-compact'),
      );
      widgetsToDisplay.add(_buildNavigationWidget(navCustomWidgetState, textColor, hasBackground, isDark));
      
      // Add music widget if music is playing
      for (var widgetState in deviceState.widgets) {
        if (widgetState.id.startsWith('music-') && isMusicPlaying) {
          widgetsToDisplay.add(_buildMusicWidget(widgetState, textColor, hasBackground, isDark));
        }
      }
    }
    // Rule 4: Default mode - show all enabled widgets
    else {
      for (var widgetState in deviceState.widgets) {
        if (widgetState.id.startsWith('time-')) {
          widgetsToDisplay.add(_buildTimeWidget(widgetState, time, textColor, hasBackground, isDark));
        } else if (widgetState.id.startsWith('weather-')) {
          widgetsToDisplay.add(_buildWeatherWidget(widgetState, textColor, hasBackground, isDark));
        } else if (widgetState.id.startsWith('music-')) {
          if (isMusicPlaying) {
            widgetsToDisplay.add(_buildMusicWidget(widgetState, textColor, hasBackground, isDark));
          }
        } else if (widgetState.id.startsWith('nav-')) {
          widgetsToDisplay.add(_buildNavigationWidget(widgetState, textColor, hasBackground, isDark));
        } else if (widgetState.id.startsWith('battery-')) {
          widgetsToDisplay.add(_buildBatteryWidget(widgetState, textColor, hasBackground, isDark));
        } else if (widgetState.id.startsWith('photo-')) {
          widgetsToDisplay.add(_buildPhotoWidget(widgetState, textColor, hasBackground, isDark));
        }
      }
    }

    if (widgetsToDisplay.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.widgets_outlined,
              size: 42,
            ),
            SizedBox(height: 10),
            Text(
              'No widgets selected',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Build the main content column
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Widgets display (centered)
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: widgetsToDisplay
                .map((widget) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: widget,
                    ))
                .toList(),
          ),
        ),
        // Custom name at bottom
        if (deviceState.customName.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              deviceState.customName,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: textColor.withValues(alpha: 0.7),
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildInteractiveWidget({
    required String widgetId,
    required Widget child,
  }) {
    final isSelected = selectedWidgetId == widgetId;
    return GestureDetector(
      onTap: () => onWidgetSelected?.call(widgetId),
      onDoubleTap: () {
        if (selectedWidgetId == null) return;

        final currentWidget = allWidgetCards.firstWhere((w) => w.id == selectedWidgetId, orElse: () => allWidgetCards.first);
        final categoryPrefix = currentWidget.id.split('-').first;
        final categoryWidgets = allWidgetCards.where((w) => w.id.startsWith(categoryPrefix)).toList();
        
        final currentIndex = categoryWidgets.indexWhere((w) => w.id == selectedWidgetId);
        if (currentIndex == -1) return;

        final nextIndex = (currentIndex + 1) % categoryWidgets.length;
        onWidgetSelected?.call(categoryWidgets[nextIndex].id);
      },
      onHorizontalDragEnd: (details) {
        if (selectedWidgetId == null) return;

        final currentWidget = allWidgetCards.firstWhere((w) => w.id == selectedWidgetId, orElse: () => allWidgetCards.first);
        final categoryPrefix = currentWidget.id.split('-').first;
        final categoryWidgets = allWidgetCards.where((w) => w.id.startsWith(categoryPrefix)).toList();
        
        final currentIndex = categoryWidgets.indexWhere((w) => w.id == selectedWidgetId);
        if (currentIndex == -1) return;

        if (details.primaryVelocity! > 0) {
          // Swipe right
          final nextIndex = (currentIndex + 1) % categoryWidgets.length;
          onWidgetSelected?.call(categoryWidgets[nextIndex].id);
        } else if (details.primaryVelocity! < 0) {
          // Swipe left
          final prevIndex = (currentIndex - 1 + categoryWidgets.length) % categoryWidgets.length;
          onWidgetSelected?.call(categoryWidgets[prevIndex].id);
        }
      },
      child: Container(
        decoration: isSelected
            ? BoxDecoration(
                border: Border.all(color: Colors.blue.shade300, width: 2),
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: child,
      ),
    );
  }
  
  Widget _buildTimeWidget(CustomWidgetState widgetState, String time, Color textColor, bool hasBackground, bool isDark) {
    // scale, widgetCount, hasWeather are hardcoded or derived from context
    final double scale = 1.0; 
    final int widgetCount = 1; // Simplified for now
    final bool hasWeather = false; // Simplified for now

    return _buildInteractiveWidget(
      widgetId: widgetState.id,
      child: Opacity(
        opacity: widgetState.opacity,
        child: Transform.scale(
          scale: widgetState.size,
          child: _buildTimeWidgetContent(
            widgetState.id, 
            time, 
            widgetState.color, // Pass widgetState.color here
            null, 
            scale, 
            widgetCount, 
            hasWeather, 
            DateTime.now(), 
            isDark
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherWidget(CustomWidgetState widgetState, Color textColor, bool hasBackground, bool isDark) {
    // scale, widgetCount, hasTime are hardcoded or derived from context
    final double scale = 1.0; // Simplified for now
    final int widgetCount = 1; // Simplified for now
    final bool hasTime = false; // Simplified for now

    return _buildInteractiveWidget(
      widgetId: widgetState.id,
      child: Opacity(
        opacity: widgetState.opacity,
        child: Transform.scale(
          scale: widgetState.size,
          child: _buildWeatherWidgetContent(
            widgetState.id, 
            widgetState.color, // Pass widgetState.color here
            null, 
            scale, 
            widgetCount, 
            hasTime, 
            isDark
          ),
        ),
      ),
    );
  }

  Widget _buildMusicWidget(CustomWidgetState widgetState, Color textColor, bool hasBackground, bool isDark) {
    // widgetCount is simplified for now
    final int widgetCount = 1; // Simplified for now

    return _buildInteractiveWidget(
      widgetId: widgetState.id,
      child: Opacity(
        opacity: widgetState.opacity,
        child: Transform.scale(
          scale: widgetState.size,
          child: _buildMusicWidgetContent(
            widgetState.id, 
            widgetState.color, // Pass widgetState.color here
            null, 
            widgetCount, 
            isDark
          ),
        ),
      ),
    );
  }

  Widget _buildBatteryWidget(CustomWidgetState widgetState, Color textColor, bool hasBackground, bool isDark) {
    // scale, compact are simplified for now
    final double scale = 1.0; // Simplified for now
    final bool compact = false; // Simplified for now
    final batteryColor = deviceState.battery > 20 ? Colors.green : Colors.red;

    return _buildInteractiveWidget(
      widgetId: widgetState.id,
      child: Opacity(
        opacity: widgetState.opacity,
        child: Transform.scale(
          scale: widgetState.size,
          child: _buildBatteryWidgetContent(
            widgetState.id, 
            widgetState.color, // Pass widgetState.color here
            null, 
            scale, 
            compact, 
            batteryColor, 
            isDark
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoWidget(CustomWidgetState widgetState, Color textColor, bool hasBackground, bool isDark) {
    return const SizedBox.shrink();
  }

  Widget _buildNavigationWidget(CustomWidgetState widgetState, Color textColor, bool hasBackground, bool isDark) {
    if (!deviceState.navigation.ridingMode && !deviceState.navigation.isNavigating) return const SizedBox();
    
    IconData getDirectionIcon() {
      final direction = deviceState.navigation.direction.toLowerCase();
      if (direction.contains('left')) return Icons.turn_left;
      if (direction.contains('right')) return Icons.turn_right;
      return Icons.arrow_upward;
    }

    // widgetCount is simplified for now
    final int widgetCount = 1; // Simplified for now

    return _buildInteractiveWidget(
      widgetId: widgetState.id,
      child: Opacity(
        opacity: widgetState.opacity,
        child: Transform.scale(
          scale: widgetState.size,
          child: _buildNavigationWidgetContent(
            widgetState.id, 
            widgetState.color, // Pass widgetState.color here
            null, 
            widgetCount, 
            getDirectionIcon, 
            isDark
          ),
        ),
      ),
    );
  }

  Widget _buildTimeWidgetContent(String widgetType, String time, Color contentTextColor, List<Shadow>? shadows, double scale, int widgetCount, bool hasWeather, DateTime now, bool isDark) {
    switch (widgetType) {
      case 'time-digital-large':
        return SizedBox(
          width: 168,
          height: hasWeather && widgetCount == 2 ? 85 : (widgetCount == 1 ? 120 : (widgetCount == 2 ? 95 : 80)),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: 168,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEEE, MMMM d').format(now),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: hasWeather && widgetCount == 2 ? 10 : 12,
                      fontWeight: FontWeight.w500,
                      color: contentTextColor.withValues(alpha: 0.95),
                      letterSpacing: 0.3,
                      height: 1.2,
                      shadows: shadows,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: hasWeather && widgetCount == 2 ? 4 : 6),
                  Text(
                    time,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: hasWeather && widgetCount == 2 ? 40 : (widgetCount == 1 ? 60 : (widgetCount == 2 ? 50 : 42)),
                      fontWeight: FontWeight.w200,
                      color: contentTextColor,
                      letterSpacing: -1.2,
                      height: 1.0,
                      shadows: shadows,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      case 'time-digital-small':
        return SizedBox(
          width: 155,
          height: hasWeather && widgetCount == 2 ? 70 : (widgetCount == 1 ? 95 : (widgetCount == 2 ? 75 : 65)),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              width: 155,
              padding: EdgeInsets.symmetric(
                horizontal: 16, 
                vertical: hasWeather && widgetCount == 2 ? 8 : 10
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          contentTextColor.withValues(alpha: 0.15),
                          contentTextColor.withValues(alpha: 0.08),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.8),
                          Colors.white.withValues(alpha: 0.6),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? contentTextColor.withValues(alpha: 0.25)
                      : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    time,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: hasWeather && widgetCount == 2 ? 32 : 38,
                      fontWeight: FontWeight.w300,
                      color: contentTextColor,
                      letterSpacing: -0.8,
                      height: 1.0,
                      shadows: shadows,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  SizedBox(height: hasWeather && widgetCount == 2 ? 2 : 4),
                  Text(
                    DateFormat('EEE, MMM d').format(now),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: hasWeather && widgetCount == 2 ? 10 : 12,
                      fontWeight: FontWeight.w500,
                      color: contentTextColor.withValues(alpha: 0.85),
                      letterSpacing: 0.3,
                      shadows: shadows,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      case 'time-analog-small':
        return SizedBox(
          width: hasWeather && widgetCount == 2 ? 55 : (widgetCount == 1 ? 100 : (widgetCount == 2 ? 75 : 60)),
          height: hasWeather && widgetCount == 2 ? 55 : (widgetCount == 1 ? 100 : (widgetCount == 2 ? 75 : 60)),
          child: _buildModernAnalogClock(
            hasWeather && widgetCount == 2 ? 55 : (widgetCount == 1 ? 100 : (widgetCount == 2 ? 75 : 60)),
            contentTextColor,
            false,
            isDark,
          ),
        );
      case 'time-analog-large':
        return SizedBox(
          width: hasWeather && widgetCount == 2 ? 80 : (widgetCount == 1 ? 130 : (widgetCount == 2 ? 105 : 85)),
          height: hasWeather && widgetCount == 2 ? 80 : (widgetCount == 1 ? 130 : (widgetCount == 2 ? 105 : 85)),
          child: _buildModernAnalogClock(
            hasWeather && widgetCount == 2 ? 80 : (widgetCount == 1 ? 130 : (widgetCount == 2 ? 105 : 85)),
            contentTextColor,
            true,
            isDark,
          ),
        );
      case 'time-text-date':
        return SizedBox(
          width: 168,
          height: hasWeather && widgetCount == 2 ? 80 : (widgetCount == 1 ? 110 : (widgetCount == 2 ? 90 : 75)),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: 168,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    time,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: hasWeather && widgetCount == 2 ? 36 : (widgetCount == 1 ? 54 : (widgetCount == 2 ? 44 : 36)),
                      fontWeight: FontWeight.w200,
                      color: contentTextColor.withValues(alpha: 0.95),
                      letterSpacing: -1.0,
                      height: 0.95,
                      shadows: shadows,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  SizedBox(height: hasWeather && widgetCount == 2 ? 4 : 8),
                  Text(
                    DateFormat('EEEE').format(now),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: hasWeather && widgetCount == 2 ? 13 : 16,
                      fontWeight: FontWeight.w600,
                      color: contentTextColor.withValues(alpha: 0.95),
                      letterSpacing: 0.6,
                      shadows: shadows,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: hasWeather && widgetCount == 2 ? 1 : 2),
                  Text(
                    DateFormat('MMMM d, y').format(now),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: hasWeather && widgetCount == 2 ? 9 : 12,
                      fontWeight: FontWeight.w400,
                      color: contentTextColor.withValues(alpha: 0.85),
                      letterSpacing: 0.3,
                      shadows: shadows,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildModernAnalogClock(double size, Color color, bool showMarkers, bool isDark) {
    final now = DateTime.now();
    final hour = now.hour % 12;
    final minute = now.minute;
    final second = now.second;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: isDark
              ? [
                  color.withValues(alpha: 0.12),
                  color.withValues(alpha: 0.06),
                ]
              : [
                  Colors.white.withValues(alpha: 0.8),
                  Colors.white.withValues(alpha: 0.6),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isDark
              ? color.withValues(alpha: 0.2)
              : Colors.grey.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: ModernAnalogClockPainter(
          hour: hour,
          minute: minute,
          second: second,
          color: color,
          showMarkers: showMarkers,
        ),
      ),
    );
  }

  Widget _buildWeatherWidgetContent(String widgetType, Color textColor, List<Shadow>? shadows, double weatherScale, int widgetCount, bool hasTime, bool isDark) {
    switch (widgetType) {
      case 'weather-icon':
        return SizedBox(
          width: 60,
          height: widgetCount == 1 ? 62 : (widgetCount == 2 ? 52 : 44),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? textColor.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark
                      ? textColor.withValues(alpha: 0.15)
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Text(
                _getWeatherIcon(deviceState.weather.condition),
                style: TextStyle(
                  fontSize: 42 * weatherScale,
                  shadows: shadows,
                ),
              ),
            ),
          ),
        );
      case 'weather-temp-icon':
        return SizedBox(
          width: 155,
          height: widgetCount == 1 ? 72 : (widgetCount == 2 ? 60 : 50),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: isDark
                    ? textColor.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? textColor.withValues(alpha: 0.12)
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? textColor.withValues(alpha: 0.08)
                          : Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? textColor.withValues(alpha: 0.15)
                            : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getWeatherIcon(deviceState.weather.condition),
                      style: TextStyle(
                        fontSize: hasTime && widgetCount == 2 ? 30 : 38 * weatherScale,
                      ),
                    ),
                  ),
                  SizedBox(width: 14 * weatherScale),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${deviceState.weather.temperature}°',
                        style: TextStyle(
                          fontSize: hasTime && widgetCount == 2 ? 28 : 36 * weatherScale,
                          fontWeight: FontWeight.w900,
                          color: textColor,
                          letterSpacing: -1.5,
                          height: 1.0,
                          shadows: shadows,
                        ),
                      ),
                      Text(
                        deviceState.weather.condition,
                        style: TextStyle(
                          fontSize: 10 * weatherScale,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? textColor.withValues(alpha: 0.6)
                              : Colors.black54,
                          letterSpacing: 0.2,
                          shadows: shadows,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      case 'weather-full':
        return SizedBox(
          width: 160,
          height: hasTime && widgetCount == 2 ? 105 : (widgetCount == 1 ? 145 : 120),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              width: 160,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark
                    ? textColor.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: isDark
                      ? textColor.withValues(alpha: 0.12)
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(hasTime && widgetCount == 2 ? 14 : 18 * weatherScale),
                    decoration: BoxDecoration(
                      color: isDark
                          ? textColor.withValues(alpha: 0.08)
                          : Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: isDark
                            ? textColor.withValues(alpha: 0.15)
                            : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getWeatherIcon(deviceState.weather.condition),
                      style: TextStyle(
                        fontSize: hasTime && widgetCount == 2 ? 42 : 52 * weatherScale,
                        shadows: shadows,
                      ),
                    ),
                  ),
                  SizedBox(height: hasTime && widgetCount == 2 ? 10 : 14),
                  Text(
                    '${deviceState.weather.temperature}°',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: hasTime && widgetCount == 2 ? 38 : 48 * weatherScale,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                      letterSpacing: -2.0,
                      height: 1.0,
                      shadows: shadows,
                    ),
                  ),
                  SizedBox(height: 6 * weatherScale),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14 * weatherScale,
                      vertical: 6 * weatherScale,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? textColor.withValues(alpha: 0.08)
                          : Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? textColor.withValues(alpha: 0.15)
                            : Colors.grey.shade200,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      deviceState.weather.condition,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: hasTime && widgetCount == 2 ? 12 : 13 * weatherScale,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? textColor.withValues(alpha: 0.85)
                            : Colors.black87,
                        letterSpacing: 0.5,
                        shadows: shadows,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildMusicWidgetContent(String widgetType, Color textColor, List<Shadow>? shadows, int widgetCount, bool isDark) {
    switch (widgetType) {
      case 'music-mini':
        return SizedBox(
          width: 115,
          height: widgetCount == 1 ? 115 : (widgetCount == 2 ? 100 : 90),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              width: 115,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          textColor.withValues(alpha: 0.18),
                          textColor.withValues(alpha: 0.10),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.8),
                          Colors.white.withValues(alpha: 0.6),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? textColor.withValues(alpha: 0.25)
                      : Colors.grey.shade300,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (deviceState.music.albumArt != null)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          File(deviceState.music.albumArt!),
                          width: 42,
                          height: 42,
                          fit: BoxFit.cover,
                          cacheWidth: 84,
                          cacheHeight: 84,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? textColor.withValues(alpha: 0.2)
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.album_rounded,
                              color: isDark ? textColor : Colors.grey.shade700,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isDark
                            ? textColor.withValues(alpha: 0.2)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.album_rounded,
                        color: isDark ? textColor : Colors.grey.shade700,
                        size: 20,
                      ),
                    ),
                  const SizedBox(height: 7),
                  SizedBox(
                    width: 100,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          deviceState.music.trackTitle,
                          style: TextStyle(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                            color: textColor,
                            letterSpacing: 0.2,
                            shadows: shadows,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 1.5),
                        Text(
                          deviceState.music.artist,
                          style: TextStyle(
                            fontSize: 7,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? textColor.withValues(alpha: 0.7)
                                : Colors.black54,
                            shadows: shadows,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Icon(
                    deviceState.music.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: textColor,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        );
      case 'music-full':
        return SizedBox(
          width: 160,
          height: widgetCount == 1 ? 170 : (widgetCount == 2 ? 145 : 125),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              width: 160,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [
                          textColor.withValues(alpha: 0.12),
                          textColor.withValues(alpha: 0.06),
                        ]
                      : [
                          Colors.white.withValues(alpha: 0.8),
                          Colors.white.withValues(alpha: 0.6),
                        ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? textColor.withValues(alpha: 0.15)
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (deviceState.music.albumArt != null)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.file(
                          File(deviceState.music.albumArt!),
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          cacheWidth: 160,
                          cacheHeight: 160,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? textColor.withValues(alpha: 0.15)
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.music_note_rounded,
                              color: isDark ? textColor : Colors.grey.shade700,
                              size: 32,
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: isDark
                            ? textColor.withValues(alpha: 0.15)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.music_note_rounded,
                        color: isDark ? textColor : Colors.grey.shade700,
                        size: 32,
                      ),
                    ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: 145,
                    child: Text(
                      deviceState.music.trackTitle,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        letterSpacing: 0.2,
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
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? textColor.withValues(alpha: 0.7)
                          : Colors.black54,
                      shadows: shadows,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 9),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.skip_previous_rounded,
                          color: isDark
                              ? textColor.withValues(alpha: 0.75)
                              : Colors.grey.shade600,
                          size: 22,
                        ),
                        const SizedBox(width: 11),
                        Icon(
                          deviceState.music.isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded,
                          color: textColor,
                          size: 38,
                        ),
                        const SizedBox(width: 11),
                        Icon(
                          Icons.skip_next_rounded,
                          color: isDark
                              ? textColor.withValues(alpha: 0.75)
                              : Colors.grey.shade600,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildBatteryWidgetContent(String widgetType, Color textColor, List<Shadow>? shadows, double scale, bool compact, Color batteryColor, bool isDark) {
    switch (widgetType) {
      case 'battery-status':
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 * scale : 12 * scale, 
            vertical: compact ? 6 * scale : 8 * scale
          ),
          decoration: BoxDecoration(
            color: isDark
                ? textColor.withValues(alpha: 0.1)
                : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(18 * scale),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.battery_charging_full_rounded,
                size: compact ? 18 * scale : 20 * scale,
                color: batteryColor,
              ),
              SizedBox(width: 6 * scale),
              Text(
                '${deviceState.battery}%',
                style: TextStyle(
                  fontSize: compact ? 12 * scale : 14 * scale,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  shadows: shadows,
                ),
              ),
            ],
          ),
        );
      case 'battery-bar':
        final double barWidth = compact ? 90 * scale : 110 * scale;
        
        return Column(
          children: [
            Container(
              width: barWidth,
              height: 10 * scale,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5 * scale),
                border: Border.all(
                  color: isDark
                      ? textColor.withValues(alpha: 0.3)
                      : Colors.grey.shade400,
                  width: 2,
                ),
                color: isDark
                    ? textColor.withValues(alpha: 0.05)
                    : Colors.white,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3 * scale),
                child: FractionallySizedBox(
                  widthFactor: deviceState.battery / 100,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [batteryColor, batteryColor.withValues(alpha: 0.7)],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 6 * scale),
            Text(
              '${deviceState.battery}%',
              style: TextStyle(
                fontSize: compact ? 11 * scale : 13 * scale,
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

  Widget _buildNavigationWidgetContent(String widgetType, Color textColor, List<Shadow>? shadows, int widgetCount, IconData Function() getDirectionIcon, bool isDark) {
    switch (widgetType) {
      case 'nav-compact':
        return SizedBox(
          width: 155,
          height: widgetCount == 1 ? 85 : (widgetCount == 2 ? 72 : 60),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? textColor.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark
                      ? textColor.withValues(alpha: 0.15)
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? textColor.withValues(alpha: 0.12)
                              : Colors.white.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? textColor.withValues(alpha: 0.2)
                                : Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          getDirectionIcon(),
                          color: textColor,
                          size: 32,
                          shadows: shadows,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 70),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              deviceState.navigation.distance,
                              style: TextStyle(
                                fontSize: 22,
                                color: textColor,
                                fontWeight: FontWeight.w900,
                                height: 1.0,
                                letterSpacing: -0.8,
                                shadows: shadows,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'ahead',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark
                                    ? textColor.withValues(alpha: 0.7)
                                    : Colors.black54,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                                shadows: shadows,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (deviceState.navigation.destination != null && deviceState.navigation.destination!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isDark
                            ? textColor.withValues(alpha: 0.06)
                            : Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 9,
                            color: isDark
                                ? textColor.withValues(alpha: 0.6)
                                : Colors.black54,
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              deviceState.navigation.destination!,
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? textColor.withValues(alpha: 0.7)
                                    : Colors.black54,
                                height: 1.1,
                                letterSpacing: 0.1,
                                shadows: shadows,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
            case 'nav-full':
              return SizedBox(
                width: 165,
                height: widgetCount == 1 ? 165 : (widgetCount == 2 ? 140 : 120),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Container(
                    width: 165,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? textColor.withValues(alpha: 0.08)
                          : Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isDark
                            ? textColor.withValues(alpha: 0.15)
                            : Colors.grey.shade300,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? textColor.withValues(alpha: 0.12)
                                : Colors.white.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            getDirectionIcon(),
                            color: textColor,
                            size: 36,
                            shadows: shadows,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: 145,
                          child: Text(
                            deviceState.navigation.direction,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: textColor,
                              height: 1.1,
                              letterSpacing: 0.2,
                              shadows: shadows,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          deviceState.navigation.distance,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: textColor,
                            height: 1.0,
                            letterSpacing: -0.5,
                            shadows: shadows,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? textColor.withValues(alpha: 0.1)
                                    : Colors.white.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.access_time_rounded,
                                    size: 10,
                                    color: isDark
                                        ? textColor.withValues(alpha: 0.7)
                                        : Colors.black54,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    deviceState.navigation.eta,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? textColor.withValues(alpha: 0.8)
                                          : Colors.black87,
                                      height: 1.1,
                                      shadows: shadows,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ],
                              ),
                            ),
                            if (deviceState.navigation.currentSpeed != null) ...[
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? textColor.withValues(alpha: 0.1)
                                      : Colors.white.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.speed_rounded,
                                      size: 10,
                                      color: isDark
                                          ? textColor.withValues(alpha: 0.7)
                                          : Colors.black54,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${deviceState.navigation.currentSpeed!.toStringAsFixed(0)} km/h',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? textColor.withValues(alpha: 0.8)
                                            : Colors.black87,
                                        height: 1.1,
                                        shadows: shadows,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );      default:
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