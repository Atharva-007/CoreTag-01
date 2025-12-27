import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../models/device_state.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'dart:io';

class DevicePreview extends StatelessWidget {
  final DeviceState deviceState;
  final VoidCallback? onTap;
  final double widgetSizeScale;
  final double widgetOpacity;
  final double widgetFontSize;
  final Color widgetColor;

  const DevicePreview({
    super.key,
    required this.deviceState,
    this.onTap,
    this.widgetSizeScale = 1.0,
    this.widgetOpacity = 1.0,
    this.widgetFontSize = 14.0,
    this.widgetColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = deviceState.theme == 'dark';
    final currentTime = DateFormat('HH:mm').format(DateTime.now());

    return RepaintBoundary(
      child: GestureDetector(
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
                spreadRadius: 1,
                offset: const Offset(0, 15),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                spreadRadius: 0,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background image if present
                if (deviceState.backgroundImage != null)
                  Positioned.fill(
                    child: RepaintBoundary(
                      child: ClipRect(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: Image.file(
                            File(deviceState.backgroundImage!),
                            cacheWidth: 400,
                            cacheHeight: 800,
                            filterQuality: FilterQuality.high,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: isDark ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
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
                                Colors.white.withOpacity(0.35),
                                Colors.white.withOpacity(0.55),
                                Colors.white.withOpacity(0.35),
                              ],
                      ),
                    ),
                  ),
                // Content - without scrolling, adaptive layout
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
    bool hasMusicWidget = deviceState.widgets.any((w) => w.startsWith('music-'));
    bool isMusicPlaying = deviceState.music.isPlaying;

    // If nav-full is active, show ONLY time and navigation
    if (hasNavFull) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                maxHeight: constraints.maxHeight,
                maxWidth: constraints.maxWidth,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Time display at top
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        letterSpacing: 1.2,
                        height: 1.2,
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
                    // Navigation widget centered - wrapped to prevent overflow
                    Flexible(
                      child: _buildNavigationWidget('nav-full', textColor, hasBackground),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    // Build widgets based on selection with smart filtering
    for (var widget in deviceState.widgets) {
      // Smart filtering: When ANY music widget is selected OR navigation is active, disable weather and clock/time
      if (hasMusicWidget || hasNavigation) {
        // Skip ALL weather widgets when music widget is present or navigation is active
        if (widget.startsWith('weather-')) {
          continue;
        }
        // Skip ALL clock/time widgets when music widget is present or navigation is active
        if (widget.startsWith('time-')) {
          continue;
        }
      }
      
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

    // Calculate adaptive spacing and sizing based on widget count
    final config = _getAdaptiveConfig();
    final double spacing = (config['spacing'] as num).toDouble();
    final double topPadding = (config['padding'] as num).toDouble();
    final bool isCompact = config['compact'] as bool;

    // If navigation is active (but not nav-full), show time at top with widgets below
    if (hasNavigation) {
      return LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
                maxHeight: constraints.maxHeight,
                maxWidth: constraints.maxWidth,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Time display at top with adaptive size
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        time,
                        style: TextStyle(
                          fontSize: isCompact ? 14.0 : 16.0,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                          letterSpacing: 1.0,
                          height: 1.2,
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
                    ),
                    SizedBox(height: topPadding),
                    // Widgets with adaptive spacing - constrained to prevent overflow
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: widgetList.map((widget) => Padding(
                            padding: EdgeInsets.only(bottom: spacing),
                            child: widget,
                          )).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    // Default centered layout for non-navigation widgets with adaptive spacing
    final widgetCount = widgetList.length;
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              maxHeight: constraints.maxHeight,
              maxWidth: constraints.maxWidth,
            ),
            child: IntrinsicHeight(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: widgetList.map((widget) {
                    return Flexible(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: widgetCount == 1 ? 0 : spacing),
                        child: widget,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper function to get adaptive scale factor based on widget count
  double _getScaleFactor() {
    final widgetCount = deviceState.widgets.length;
    if (widgetCount == 1) return 1.0;
    if (widgetCount == 2) return 0.85;
    if (widgetCount == 3) return 0.75;
    if (widgetCount == 4) return 0.65;
    if (widgetCount >= 5) return 0.6;
    return 1.0;
  }

  // Helper to check if specific widget types are present
  bool _hasWidgetType(String prefix) {
    return deviceState.widgets.any((w) => w.startsWith(prefix));
  }

  // Helper to get adaptive sizing based on widget types combination
  Map<String, dynamic> _getAdaptiveConfig() {
    final hasMusicWidget = _hasWidgetType('music-');
    final isMusicPlaying = deviceState.music.isPlaying;
    final hasNav = _hasWidgetType('nav-') && deviceState.navigation.ridingMode;
    
    // Calculate actual visible widget count after filtering
    int visibleWidgetCount = 0;
    for (var widget in deviceState.widgets) {
      // Apply same filtering logic - disable ALL weather when ANY music widget is selected or nav is active
      if (hasMusicWidget || hasNav) {
        if (widget.startsWith('weather-')) {
          continue; // Skip weather widgets completely
        }
      }
      visibleWidgetCount++;
    }
    
    final widgetCount = visibleWidgetCount > 0 ? visibleWidgetCount : deviceState.widgets.length;
    final hasTime = _hasWidgetType('time-');
    final hasMusic = _hasWidgetType('music-');
    final hasWeather = _hasWidgetType('weather-');
    final hasBattery = _hasWidgetType('battery-');
    final hasPhoto = _hasWidgetType('photo-');
    
    // Calculate base scale with smoother transitions and overflow prevention
    double baseScale;
    if (widgetCount == 1) {
      // Single widget - make clock MUCH larger, navigation huge
      if (hasNav) {
        baseScale = 1.5; // Navigation widgets - reduced to prevent overflow
      } else if (hasTime) {
        baseScale = 1.6; // Clock widget - reduced to prevent overflow
      } else if (hasMusic) {
        baseScale = 1.5; // Music widget
      } else {
        baseScale = 1.4; // Other single widgets
      }
    } else if (widgetCount == 2) {
      if (hasNav) {
        baseScale = 1.0; // Navigation with 2 widgets
      } else if (hasTime && hasMusic) {
        baseScale = 1.0; // Time + Music
      } else if (hasTime) {
        baseScale = 1.15; // Clock with another widget
      } else {
        baseScale = 1.0;
      }
    } else if (widgetCount == 3) {
      baseScale = 0.85;
    } else if (widgetCount == 4) {
      baseScale = 0.72;
    } else if (widgetCount == 5) {
      baseScale = 0.65;
    } else {
      baseScale = 0.58; // 6+ widgets
    }
    
    // Determine priority based on widget combinations
    bool musicPriority = hasMusic && !hasPhoto && widgetCount <= 3;
    bool timePriority = hasTime && widgetCount <= 2 && !hasMusic && !hasNav;
    bool navPriority = hasNav;
    bool photoPriority = hasPhoto;
    bool weatherPriority = hasWeather && !hasTime && !hasMusic && widgetCount <= 2;
    
    // Adaptive spacing based on widget count and types - increased for better separation
    double spacing;
    if (widgetCount == 1) {
      spacing = 0.0; // Single widget centered
    } else if (widgetCount == 2) {
      // Special handling for clock + weather combination
      if (hasTime && hasWeather) {
        spacing = 6.0; // Reduced spacing for clock + weather
      } else if (hasMusic || hasNav) {
        spacing = 8.0;
      } else {
        spacing = 10.0;
      }
    } else if (widgetCount == 3) {
      spacing = 5.0;
    } else if (widgetCount == 4) {
      spacing = 3.5;
    } else {
      spacing = 2.5; // Compact for 5+ widgets
    }
    
    // Adaptive padding
    double padding;
    if (widgetCount == 1) {
      padding = 0.0;
    } else if (widgetCount == 2) {
      padding = 12.0;
    } else if (widgetCount == 3) {
      padding = 10.0;
    } else if (widgetCount == 4) {
      padding = 6.0;
    } else {
      padding = 4.0;
    }
    
    return {
      'scale': baseScale,
      'spacing': spacing,
      'padding': padding,
      'musicPriority': musicPriority,
      'timePriority': timePriority,
      'navPriority': navPriority,
      'photoPriority': photoPriority,
      'weatherPriority': weatherPriority,
      'compact': widgetCount >= 4,
      'widgetCount': widgetCount,
      'hasMusic': hasMusic,
      'hasTime': hasTime,
      'hasWeather': hasWeather,
      'hasBattery': hasBattery,
      'hasNav': hasNav,
    };
  }

  Widget _buildTimeWidget(String widgetType, String time, Color textColor, bool hasBackground) {
    final isDark = deviceState.theme == 'dark';
    final shadows = hasBackground ? [
      Shadow(
        color: isDark ? Colors.black.withOpacity(0.9) : Colors.white.withOpacity(0.9),
        blurRadius: 16,
        offset: const Offset(0, 0),
      ),
      Shadow(
        color: isDark ? Colors.black.withOpacity(0.7) : Colors.white.withOpacity(0.7),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ] : null;

    final config = _getAdaptiveConfig();
    final bool timePriority = config['timePriority'] as bool;
    final bool compact = config['compact'] as bool;
    final int widgetCount = config['widgetCount'] as int;
    final bool hasWeather = config['hasWeather'] as bool;
    final double baseScale = (config['scale'] as num).toDouble();
    final double scale = timePriority ? baseScale * 1.05 : baseScale;
    final now = DateTime.now();

    switch (widgetType) {
      case 'time-digital-large':
        // iOS-style large digital clock with date - fully constrained
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
                  // Day and Date
                  Text(
                    DateFormat('EEEE, MMMM d').format(now),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: hasWeather && widgetCount == 2 ? 10 : 12,
                      fontWeight: FontWeight.w500,
                      color: textColor.withOpacity(0.95),
                      letterSpacing: 0.3,
                      height: 1.2,
                      shadows: shadows,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: hasWeather && widgetCount == 2 ? 4 : 6),
                  // Large Time
                  Text(
                    time,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: hasWeather && widgetCount == 2 ? 40 : (widgetCount == 1 ? 60 : (widgetCount == 2 ? 50 : 42)),
                      fontWeight: FontWeight.w200,
                      color: textColor,
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
        // Compact digital clock - fully constrained
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
                  colors: [
                    textColor.withOpacity(0.15),
                    textColor.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: textColor.withOpacity(0.25),
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
                      color: textColor,
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
                      color: textColor.withOpacity(0.85),
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
            textColor,
            false,
          ),
        );
      case 'time-analog-large':
        return SizedBox(
          width: hasWeather && widgetCount == 2 ? 80 : (widgetCount == 1 ? 130 : (widgetCount == 2 ? 105 : 85)),
          height: hasWeather && widgetCount == 2 ? 80 : (widgetCount == 1 ? 130 : (widgetCount == 2 ? 105 : 85)),
          child: _buildModernAnalogClock(
            hasWeather && widgetCount == 2 ? 80 : (widgetCount == 1 ? 130 : (widgetCount == 2 ? 105 : 85)),
            textColor,
            true,
          ),
        );
      case 'time-text-date':
        // Premium text-based clock - fully constrained
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
                  // Time in premium style
                  Text(
                    time,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: hasWeather && widgetCount == 2 ? 36 : (widgetCount == 1 ? 54 : (widgetCount == 2 ? 44 : 36)),
                      fontWeight: FontWeight.w200,
                      color: textColor,
                      letterSpacing: -1.0,
                      height: 0.95,
                      shadows: shadows,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  SizedBox(height: hasWeather && widgetCount == 2 ? 4 : 8),
                  // Day of week
                  Text(
                    DateFormat('EEEE').format(now),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: hasWeather && widgetCount == 2 ? 13 : 16,
                      fontWeight: FontWeight.w600,
                      color: textColor.withOpacity(0.95),
                      letterSpacing: 0.6,
                      shadows: shadows,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: hasWeather && widgetCount == 2 ? 1 : 2),
                  // Date
                  Text(
                    DateFormat('MMMM d, y').format(now),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: hasWeather && widgetCount == 2 ? 9 : 12,
                      fontWeight: FontWeight.w400,
                      color: textColor.withOpacity(0.85),
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

  Widget _buildModernAnalogClock(double size, Color color, bool showMarkers) {
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
          colors: [
            color.withOpacity(0.12),
            color.withOpacity(0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
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

  Widget _buildWeatherWidget(String widgetType, Color textColor, bool hasBackground) {
    final isDark = deviceState.theme == 'dark';
    final shadows = hasBackground ? [
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
    ] : null;

    final config = _getAdaptiveConfig();
    final double scale = (config['scale'] as num).toDouble();
    final bool weatherPriority = config['weatherPriority'] as bool;
    final bool compact = config['compact'] as bool;
    final int widgetCount = config['widgetCount'] as int;
    final bool hasTime = config['hasTime'] as bool;
    
    // Apply priority boost if weather is prioritized
    final double weatherScale = weatherPriority ? scale * 1.15 : scale;

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
                color: textColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: textColor.withOpacity(0.15),
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
                color: textColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: textColor.withOpacity(0.12),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Weather icon
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: textColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: textColor.withOpacity(0.15),
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
                  // Temperature
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
                          color: textColor.withOpacity(0.6),
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
                color: textColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: textColor.withOpacity(0.12),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Large weather icon
                  Container(
                    padding: EdgeInsets.all(hasTime && widgetCount == 2 ? 14 : 18 * weatherScale),
                    decoration: BoxDecoration(
                      color: textColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: textColor.withOpacity(0.15),
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
                  // Temperature
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
                  // Condition text
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14 * weatherScale,
                      vertical: 6 * weatherScale,
                    ),
                    decoration: BoxDecoration(
                      color: textColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: textColor.withOpacity(0.15),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      deviceState.weather.condition,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: hasTime && widgetCount == 2 ? 12 : 13 * weatherScale,
                        fontWeight: FontWeight.w700,
                        color: textColor.withOpacity(0.85),
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

    final config = _getAdaptiveConfig();
    final int widgetCount = config['widgetCount'] as int;

    switch (widgetType) {
      case 'music-mini':
        // Compact boxy mini music widget - fully constrained
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
                  colors: [
                    textColor.withOpacity(0.18),
                    textColor.withOpacity(0.10),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: textColor.withOpacity(0.25),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Album art
                  if (deviceState.music.albumArt != null)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
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
                              color: textColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.album_rounded,
                              color: textColor,
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
                        color: textColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.album_rounded,
                        color: textColor,
                        size: 20,
                      ),
                    ),
                  const SizedBox(height: 7),
                  // Song info
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
                            color: textColor.withOpacity(0.7),
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
                  // Play/Pause icon
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
        // Enhanced full music widget - fully constrained
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
                  colors: [
                    textColor.withOpacity(0.12),
                    textColor.withOpacity(0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: textColor.withOpacity(0.15),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Album art
                  if (deviceState.music.albumArt != null)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
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
                              color: textColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.music_note_rounded,
                              color: textColor,
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
                        color: textColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.music_note_rounded,
                        color: textColor,
                        size: 32,
                      ),
                    ),
                  const SizedBox(height: 10),
                  // Track title
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
                  // Artist name
                  Text(
                    deviceState.music.artist,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w600,
                      color: textColor.withOpacity(0.7),
                      shadows: shadows,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 9),
                  // Playback controls
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.skip_previous_rounded,
                        color: textColor.withOpacity(0.75),
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
                        color: textColor.withOpacity(0.75),
                        size: 22,
                      ),
                    ],
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
    final config = _getAdaptiveConfig();
    final double scale = (config['scale'] as num).toDouble();
    final bool compact = config['compact'] as bool;

    switch (widgetType) {
      case 'battery-status':
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 * scale : 12 * scale, 
            vertical: compact ? 6 * scale : 8 * scale
          ),
          decoration: BoxDecoration(
            color: textColor.withOpacity(0.1),
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
                border: Border.all(color: textColor.withOpacity(0.3), width: 2),
                color: textColor.withOpacity(0.05),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3 * scale),
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

  Widget _buildPhotoWidget(String widgetType, Color textColor, bool hasBackground) {
    // Photo widget is just for enabling background image
    // The actual photo is shown as background, not as a widget
    return const SizedBox.shrink();
  }

  Widget _buildNavigationWidget(String widgetType, Color textColor, bool hasBackground) {
    if (!deviceState.navigation.ridingMode && !deviceState.navigation.isNavigating) return const SizedBox();

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

    final config = _getAdaptiveConfig();
    final int widgetCount = config['widgetCount'] as int;

    // Get direction icon - enhanced for Google Maps directions
    IconData getDirectionIcon() {
      final direction = deviceState.navigation.direction.toLowerCase();
      if (direction.contains('left')) {
        if (direction.contains('slight')) return Icons.turn_slight_left;
        if (direction.contains('sharp')) return Icons.turn_sharp_left;
        if (direction.contains('u-turn')) return Icons.u_turn_left;
        return Icons.turn_left;
      } else if (direction.contains('right')) {
        if (direction.contains('slight')) return Icons.turn_slight_right;
        if (direction.contains('sharp')) return Icons.turn_sharp_right;
        return Icons.turn_right;
      } else if (direction.contains('straight') || direction.contains('continue')) {
        return Icons.arrow_upward;
      } else if (direction.contains('roundabout')) {
        return Icons.roundabout_right;
      } else if (direction.contains('merge')) {
        return Icons.merge;
      } else if (direction.contains('exit')) {
        return Icons.exit_to_app;
      }
      return Icons.navigation;
    }

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
                color: textColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: textColor.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Direction icon
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: textColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: textColor.withOpacity(0.2),
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
                      // Distance and direction
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
                                color: textColor.withOpacity(0.7),
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
                  // Show destination if available
                  if (deviceState.navigation.destination != null && deviceState.navigation.destination!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: textColor.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 9,
                            color: textColor.withOpacity(0.6),
                          ),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              deviceState.navigation.destination!,
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w600,
                                color: textColor.withOpacity(0.7),
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
                color: textColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: textColor.withOpacity(0.15),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Direction icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: textColor.withOpacity(0.12),
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
                  // Direction text
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
                  // Distance
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
                  // ETA and Speed
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: textColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 10,
                              color: textColor.withOpacity(0.7),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              deviceState.navigation.eta,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: textColor.withOpacity(0.8),
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
                            color: textColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.speed_rounded,
                                size: 10,
                                color: textColor.withOpacity(0.7),
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${deviceState.navigation.currentSpeed!.toStringAsFixed(0)} km/h',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: textColor.withOpacity(0.8),
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
        );
      default:
        return const SizedBox();
    }
  }

  Color _getWeatherColor(String condition) {
    switch (condition.toLowerCase()) {
      case 'sunny':
      case 'clear':
        return const Color(0xFFF59E0B); // Amber/Orange
      case 'cloudy':
      case 'partly cloudy':
        return const Color(0xFF6B7280); // Gray
      case 'rainy':
      case 'rain':
        return const Color(0xFF3B82F6); // Blue
      case 'stormy':
      case 'thunderstorm':
        return const Color(0xFF6366F1); // Indigo
      case 'snowy':
      case 'snow':
        return const Color(0xFF06B6D4); // Cyan
      default:
        return const Color(0xFF8B5CF6); // Purple
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

// Modern analog clock painter with refined design
class ModernAnalogClockPainter extends CustomPainter {
  final int hour;
  final int minute;
  final int second;
  final Color color;
  final bool showMarkers;

  ModernAnalogClockPainter({
    required this.hour,
    required this.minute,
    required this.second,
    required this.color,
    required this.showMarkers,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw hour markers
    if (showMarkers) {
      final markerPaint = Paint()
        ..color = color.withOpacity(0.3)
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < 12; i++) {
        final angle = (i * 30) * math.pi / 180;
        final startRadius = radius * 0.85;
        final endRadius = i % 3 == 0 ? radius * 0.75 : radius * 0.80; // Longer markers at 12, 3, 6, 9
        
        canvas.drawLine(
          Offset(
            center.dx + startRadius * math.sin(angle),
            center.dy - startRadius * math.cos(angle),
          ),
          Offset(
            center.dx + endRadius * math.sin(angle),
            center.dy - endRadius * math.cos(angle),
          ),
          markerPaint,
        );
      }
    }

    // Draw hour hand with gradient effect
    final hourAngle = (hour * 30 + minute * 0.5) * math.pi / 180;
    final hourPaint = Paint()
      ..color = color
      ..strokeWidth = 3.5
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
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(
        center.dx + radius * 0.72 * math.sin(minuteAngle),
        center.dy - radius * 0.72 * math.cos(minuteAngle),
      ),
      minutePaint,
    );

    // Draw center circle with gradient effect
    final centerCirclePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 5, centerCirclePaint);
    
    // Outer ring for center
    final centerRingPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, 7, centerRingPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Legacy clock painter for backward compatibility
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
