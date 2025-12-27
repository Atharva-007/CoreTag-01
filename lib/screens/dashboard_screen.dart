import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:crop_image/crop_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import '../models/device_state.dart';
import '../widgets/device_preview.dart';
import '../widgets/feature_card.dart';
import '../widgets/customization_panel.dart';
import 'themes_widgets_screen.dart';
import 'aod_settings_screen.dart';
import 'music_control_screen.dart';
import 'navigation_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  
  DeviceState deviceState = DeviceState(
    isConnected: true,
    battery: 85,
    theme: 'dark',
    widgets: ['time-digital-large'],
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
  );

  bool _showCustomizationPanel = false;

  // Custom photo crop state
  File? _customPhoto;
  File? _croppedCustomPhoto;
  bool _showCustomPhotoCrop = false;
  late final CropController _customPhotoCropController;
  
  // Edit device widget state
  bool _showEditDeviceWidget = false;
  
  // Widget customization state
  double _widgetSizeScale = 1.0;
  double _widgetOpacity = 1.0;
  double _widgetFontSize = 14.0;
  Color _widgetColor = Colors.blue;
  double _widgetAnimationSpeed = 1.0;
  bool _showWidgetPicker = false;
  bool _showResizeControls = false;
  bool _showColorPicker = false;
  String? _selectedWidgetForEdit; // Track which widget is being edited
  String _selectedWidget = 'Clock'; // Current widget being previewed in edit mode
  
  // Transformation state for wallpaper
  double _wallpaperScale = 1.0;
  Offset _wallpaperOffset = Offset.zero;
  int _rotationAngle = 0; // 0, 90, 180, 270
  bool _isFlippedHorizontally = false;
  double _baseScale = 1.0;

  // GPS tracking state
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _lastPosition;
  double _currentSpeed = 0.0;
  double _totalDistance = 0.0;
  String _nextTurn = 'Continue straight';
  double _nextTurnDistance = 0.5; // km
  double _remainingDistance = 5.2; // km

  // Music detection state
  static const musicEventChannel = EventChannel('com.example.coretag/music_stream');
  static const musicMethodChannel = MethodChannel('com.example.coretag/music');
  StreamSubscription? _musicStreamSubscription;
  
  // Navigation detection state
  static const navEventChannel = EventChannel('com.example.coretag/navigation_stream');
  static const navMethodChannel = MethodChannel('com.example.coretag/navigation');
  StreamSubscription? _navigationStreamSubscription;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _customPhotoCropController = CropController(
      aspectRatio: 9 / 19.5,
      defaultCrop: const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
    );
    _fadeController.forward();
    _slideController.forward();
    
    // Start music detection
    _startMusicDetection();
    
    // Start navigation detection
    _startNavigationDetection();
  }

  // Start detecting currently playing music
  Future<void> _startMusicDetection() async {
    try {
      // Check if notification listener permission is granted
      final hasPermission = await musicMethodChannel.invokeMethod('checkPermission');
      
      if (!hasPermission) {
        // Request permission
        await musicMethodChannel.invokeMethod('requestPermission');
      }
      
      // Listen to music stream
      _musicStreamSubscription = musicEventChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          if (event is Map && mounted) {
            setState(() {
              final title = event['title'] ?? 'Unknown Track';
              final artist = event['artist'] ?? 'Unknown Artist';
              final isPlaying = event['isPlaying'] ?? false;
              
              // Update device state with music info
              deviceState = deviceState.copyWith(
                music: MusicState(
                  isPlaying: isPlaying,
                  trackTitle: title,
                  artist: artist,
                ),
              );
            });
          }
        },
        onError: (error) {
          print('Music stream error: $error');
        },
      );
    } catch (e) {
      print('Failed to start music detection: $e');
    }
  }
  
  // Start detecting Google Maps navigation
  Future<void> _startNavigationDetection() async {
    try {
      // Check if notification listener permission is granted
      final hasPermission = await navMethodChannel.invokeMethod('checkPermission');
      
      if (!hasPermission) {
        // Request permission
        await navMethodChannel.invokeMethod('requestPermission');
      }
      
      // Listen to navigation stream
      _navigationStreamSubscription = navEventChannel.receiveBroadcastStream().listen(
        (dynamic event) {
          if (event is Map && mounted) {
            setState(() {
              final isNavigating = event['isNavigating'] ?? false;
              final ridingMode = event['ridingMode'] ?? false;
              final direction = event['direction'] ?? '';
              final distance = event['distance'] ?? '';
              final eta = event['eta'] ?? '';
              final nextTurn = event['nextTurn'] ?? '';
              final currentStreet = event['currentStreet'];
              final destination = event['destination'];
              
              // Update device state with navigation info
              deviceState = deviceState.copyWith(
                navigation: NavigationState(
                  isNavigating: isNavigating,
                  ridingMode: ridingMode,
                  direction: direction,
                  distance: distance,
                  eta: eta,
                  nextTurn: nextTurn,
                  currentStreet: currentStreet,
                  destination: destination,
                ),
              );
            });
          }
        },
        onError: (error) {
          print('Navigation stream error: $error');
        },
      );
    } catch (e) {
      print('Failed to start navigation detection: $e');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _customPhotoCropController.dispose();
    _positionStreamSubscription?.cancel();
    _musicStreamSubscription?.cancel();
    _navigationStreamSubscription?.cancel();
    super.dispose();
  }

  // Start GPS tracking
  Future<void> _startGPSTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enable location services'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission denied'),
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission permanently denied. Enable in settings.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
      return;
    }

    // Start listening to position updates
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Update every 5 meters
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      _updateGPSData(position);
    });
  }

  // Stop GPS tracking
  void _stopGPSTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _lastPosition = null;
    _totalDistance = 0.0;
    _currentSpeed = 0.0;
    
    setState(() {
      deviceState = deviceState.copyWith(
        navigation: deviceState.navigation.copyWith(
          isNavigating: false,
          currentSpeed: 0.0,
          distance: '0 km',
          direction: '',
        ),
      );
    });
  }

  // Update GPS data
  void _updateGPSData(Position position) {
    double speed = position.speed * 3.6; // Convert m/s to km/h
    
    // Calculate distance if we have a previous position
    if (_lastPosition != null) {
      double distanceInMeters = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );
      _totalDistance += distanceInMeters;
      
      // Update remaining distance (simulate decreasing)
      if (_remainingDistance > 0) {
        _remainingDistance -= (distanceInMeters / 1000);
        if (_remainingDistance < 0) _remainingDistance = 0;
      }
      
      // Update next turn distance (simulate decreasing)
      if (_nextTurnDistance > 0) {
        _nextTurnDistance -= (distanceInMeters / 1000);
        if (_nextTurnDistance < 0.05) {
          // Simulate next instruction
          _nextTurnDistance = 0.8 + (DateTime.now().millisecond % 5) * 0.2;
          final turns = ['Turn right', 'Turn left', 'Continue straight', 'Take exit', 'Keep right'];
          _nextTurn = turns[DateTime.now().second % turns.length];
        }
      }
    }

    _lastPosition = position;
    _currentSpeed = speed;

    // Format distance
    String formattedDistance;
    if (_totalDistance < 1000) {
      formattedDistance = '${_totalDistance.toStringAsFixed(0)} m';
    } else {
      formattedDistance = '${(_totalDistance / 1000).toStringAsFixed(2)} km';
    }

    // Determine direction based on heading
    String direction = _getDirectionFromHeading(position.heading);

    setState(() {
      deviceState = deviceState.copyWith(
        navigation: deviceState.navigation.copyWith(
          isNavigating: true,
          currentSpeed: speed,
          distance: formattedDistance,
          direction: direction,
        ),
      );
    });
  }

  // Get direction from heading
  String _getDirectionFromHeading(double heading) {
    if (heading < 0) return 'Unknown';
    
    if (heading >= 337.5 || heading < 22.5) return 'North';
    if (heading >= 22.5 && heading < 67.5) return 'Northeast';
    if (heading >= 67.5 && heading < 112.5) return 'East';
    if (heading >= 112.5 && heading < 157.5) return 'Southeast';
    if (heading >= 157.5 && heading < 202.5) return 'South';
    if (heading >= 202.5 && heading < 247.5) return 'Southwest';
    if (heading >= 247.5 && heading < 292.5) return 'West';
    if (heading >= 292.5 && heading < 337.5) return 'Northwest';
    
    return 'Unknown';
  }

  void _updateDeviceState(DeviceState newState) {
    setState(() {
      deviceState = newState;
    });
  }

  void _toggleCustomizationPanel() {
    setState(() {
      _showCustomizationPanel = !_showCustomizationPanel;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Show edit device widget screen
    if (_showEditDeviceWidget) {
      return _buildEditDeviceWidgetScreen();
    }
    
    // Show crop screen if in crop mode
    if (_showCustomPhotoCrop) {
      return _buildCustomPhotoCropScreen();
    }
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFEFF6FF),
              const Color(0xFFE0E7FF).withOpacity(0.8),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // Device Preview centered
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, -40 * (1 - value)),
                        child: Opacity(
                          opacity: value,
                          child: Transform.scale(
                            scale: 0.9 + (0.1 * value),
                            child: Center(
                              child: DevicePreview(deviceState: deviceState),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // Edit Device Widget Button
                  _buildEditDeviceWidgetButton(),
                  const SizedBox(height: 32),
                  // Customization sections below device
                  _buildCustomizationSections(),
                  const SizedBox(height: 32),
                  _buildFooter(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomizationSections() {
    return Column(
      children: [
        _buildThemeSection(),
        const SizedBox(height: 24),
        _buildWidgetsSection(),
      ],
    );
  }

  Widget _buildThemeSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              spreadRadius: -2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6366F1).withOpacity(0.15),
                          const Color(0xFF8B5CF6).withOpacity(0.15),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.palette_rounded, 
                      color: Color(0xFF6366F1), 
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Theme',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  // AOD Toggle Button - Small, inline
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          deviceState.aod.enabled 
                              ? const Color(0xFF10B981) 
                              : const Color(0xFF6366F1),
                          deviceState.aod.enabled
                              ? const Color(0xFF059669)
                              : const Color(0xFF8B5CF6),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: (deviceState.aod.enabled 
                              ? const Color(0xFF10B981) 
                              : const Color(0xFF6366F1)).withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _updateDeviceState(deviceState.copyWith(
                            aod: deviceState.aod.copyWith(
                              enabled: !deviceState.aod.enabled,
                            ),
                          ));
                        },
                        borderRadius: BorderRadius.circular(18),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                deviceState.aod.enabled 
                                    ? Icons.visibility_rounded
                                    : Icons.visibility_off_rounded,
                                color: Colors.white,
                                size: 15,
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                'AOD',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(child: _buildThemeOption('Light', 'light')),
                  const SizedBox(width: 12),
                  Expanded(child: _buildThemeOption('Dark', 'dark')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(String label, String theme) {
    final isSelected = deviceState.theme == theme;
    return GestureDetector(
      onTap: () => _updateDeviceState(deviceState.copyWith(theme: theme)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF6366F1),
                    Color(0xFF8B5CF6),
                  ],
                )
              : LinearGradient(
                  colors: [
                    Colors.grey.shade100,
                    Colors.grey.shade50,
                  ],
                ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF6366F1).withOpacity(0.3) : Colors.grey.shade200,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withOpacity(0.3),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              fontSize: 15,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Icon(Icons.widgets, color: Color(0xFF6366F1), size: 24),
              const SizedBox(width: 12),
              const Text(
                'Widgets',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.swipe, size: 14, color: Color(0xFF6366F1)),
                    const SizedBox(width: 4),
                    Text(
                      'Swipe to explore',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Time Widgets Carousel
        _buildWidgetCarousel('Clock & Time', Icons.access_time, [
          _WidgetCard(
            id: 'time-digital-large',
            title: 'Large Digital',
            description: 'Bold time display',
            icon: Icons.watch,
            color: const Color(0xFF6366F1),
          ),
          _WidgetCard(
            id: 'time-digital-small',
            title: 'Small Digital',
            description: 'Compact time',
            icon: Icons.timer_outlined,
            color: const Color(0xFF8B5CF6),
          ),
          _WidgetCard(
            id: 'time-analog-small',
            title: 'Small Analog',
            description: 'Classic watch',
            icon: Icons.watch_later_outlined,
            color: const Color(0xFFA855F7),
          ),
          _WidgetCard(
            id: 'time-analog-large',
            title: 'Large Analog',
            description: 'Traditional clock',
            icon: Icons.schedule,
            color: const Color(0xFFC026D3),
          ),
          _WidgetCard(
            id: 'time-text-date',
            title: 'Date & Time',
            description: 'With calendar',
            icon: Icons.calendar_today,
            color: const Color(0xFFD946EF),
          ),
        ]),
        const SizedBox(height: 24),
        // Weather Widgets Carousel
        _buildWidgetCarousel('Weather & Temperature', Icons.wb_sunny, [
          _WidgetCard(
            id: 'weather-icon',
            title: 'Weather Icon',
            description: 'Condition only',
            icon: Icons.wb_sunny,
            color: const Color(0xFFF59E0B),
          ),
          _WidgetCard(
            id: 'weather-temp-icon',
            title: 'Temperature',
            description: 'Temp with icon',
            icon: Icons.thermostat,
            color: const Color(0xFFEF4444),
          ),
          _WidgetCard(
            id: 'weather-full',
            title: 'Full Forecast',
            description: 'Detailed weather',
            icon: Icons.cloud_queue,
            color: const Color(0xFF3B82F6),
          ),
        ]),
        const SizedBox(height: 24),
        // Music Widgets Carousel
        _buildWidgetCarousel('Music Player', Icons.headphones, [
          _WidgetCard(
            id: 'music-mini',
            title: 'Mini Player',
            description: 'Track name only',
            icon: Icons.music_note,
            color: const Color(0xFFEC4899),
          ),
          _WidgetCard(
            id: 'music-full',
            title: 'Now Playing',
            description: 'Full controls',
            icon: Icons.queue_music,
            color: const Color(0xFFDB2777),
          ),
        ]),
        const SizedBox(height: 24),
        // Photo Widget Carousel
        _buildWidgetCarousel('Wallpaper & Photo', Icons.wallpaper, [
          _WidgetCard(
            id: 'photo-widget',
            title: 'Custom Photo',
            description: 'Personal image',
            icon: Icons.add_photo_alternate,
            color: const Color(0xFF7C3AED),
          ),
        ]),
        const SizedBox(height: 24),
        // Navigation Widgets Carousel
        _buildWidgetCarousel('GPS Navigation', Icons.map, [
          _WidgetCard(
            id: 'nav-compact',
            title: 'Quick Nav',
            description: 'Distance only',
            icon: Icons.near_me,
            color: const Color(0xFF1A73E8),
          ),
          _WidgetCard(
            id: 'nav-full',
            title: 'Turn-by-Turn',
            description: 'Full directions',
            icon: Icons.directions,
            color: const Color(0xFF0E62C7),
          ),
        ]),
        const SizedBox(height: 12),
        // Photo Upload Section
        if (deviceState.widgets.any((w) => w.startsWith('photo-')))

        // Navigation Settings
        if (deviceState.widgets.any((w) => w.startsWith('nav-')))
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      title: const Text('Navigation', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      value: deviceState.navigation.ridingMode,
                      onChanged: (value) {
                        _updateDeviceState(deviceState.copyWith(
                          navigation: deviceState.navigation.copyWith(ridingMode: value),
                        ));
                        
                        // Auto-start GPS tracking when enabled
                        if (value && !deviceState.navigation.isNavigating) {
                          _startGPSTracking();
                        } else if (!value && deviceState.navigation.isNavigating) {
                          _stopGPSTracking();
                        }
                      },
                      activeColor: const Color(0xFF6366F1),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                    if (deviceState.navigation.ridingMode) ...[
                      const SizedBox(height: 8),
                      // GPS Tracking Toggle Button
                      ElevatedButton.icon(
                        onPressed: () {
                          if (deviceState.navigation.isNavigating) {
                            _stopGPSTracking();
                          } else {
                            _startGPSTracking();
                          }
                        },
                        icon: Icon(
                          deviceState.navigation.isNavigating ? Icons.stop : Icons.my_location,
                          size: 18,
                        ),
                        label: Text(
                          deviceState.navigation.isNavigating ? 'Stop GPS Tracking' : 'Start GPS Tracking',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: deviceState.navigation.isNavigating 
                            ? Colors.red.shade400 
                            : const Color(0xFF1A73E8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Live GPS Data Display
                      if (deviceState.navigation.isNavigating) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Speed',
                                        style: TextStyle(fontSize: 11, color: Colors.grey),
                                      ),
                                      Text(
                                        '${deviceState.navigation.currentSpeed?.toStringAsFixed(1) ?? '0.0'} km/h',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1A73E8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Distance',
                                        style: TextStyle(fontSize: 11, color: Colors.grey),
                                      ),
                                      Text(
                                        deviceState.navigation.distance,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1A73E8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Direction',
                                        style: TextStyle(fontSize: 11, color: Colors.grey),
                                      ),
                                      Text(
                                        deviceState.navigation.direction,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF1A73E8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Next Turn Information
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.turn_right, color: Colors.blue.shade700, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _nextTurn,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.blue.shade900,
                                            ),
                                          ),
                                          Text(
                                            'in ${_nextTurnDistance.toStringAsFixed(1)} km',
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.blue.shade700,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              // Remaining Distance
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Remaining:',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    '${_remainingDistance.toStringAsFixed(1)} km',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      DropdownButtonFormField<String>(
                        value: deviceState.navigation.direction,
                        decoration: InputDecoration(
                          labelText: 'Turn Direction',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          isDense: true,
                          contentPadding: const EdgeInsets.all(12),
                          prefixIcon: const Icon(Icons.navigation, color: Color(0xFF6366F1)),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Turn Left', child: Row(children: [Icon(Icons.turn_left, color: Colors.blue), SizedBox(width: 8), Text('Turn Left')])),
                          DropdownMenuItem(value: 'Turn Right', child: Row(children: [Icon(Icons.turn_right, color: Colors.blue), SizedBox(width: 8), Text('Turn Right')])),
                          DropdownMenuItem(value: 'Keep Straight', child: Row(children: [Icon(Icons.arrow_upward, color: Colors.blue), SizedBox(width: 8), Text('Keep Straight')])),
                          DropdownMenuItem(value: 'U-Turn', child: Row(children: [Icon(Icons.u_turn_left, color: Colors.blue), SizedBox(width: 8), Text('U-Turn')])),
                          DropdownMenuItem(value: 'Slight Left', child: Row(children: [Icon(Icons.turn_slight_left, color: Colors.blue), SizedBox(width: 8), Text('Slight Left')])),
                          DropdownMenuItem(value: 'Slight Right', child: Row(children: [Icon(Icons.turn_slight_right, color: Colors.blue), SizedBox(width: 8), Text('Slight Right')])),
                          DropdownMenuItem(value: 'Sharp Left', child: Row(children: [Icon(Icons.turn_sharp_left, color: Colors.blue), SizedBox(width: 8), Text('Sharp Left')])),
                          DropdownMenuItem(value: 'Sharp Right', child: Row(children: [Icon(Icons.turn_sharp_right, color: Colors.blue), SizedBox(width: 8), Text('Sharp Right')])),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            _updateDeviceState(deviceState.copyWith(
                              navigation: deviceState.navigation.copyWith(direction: value),
                            ));
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Distance',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                isDense: true,
                                contentPadding: const EdgeInsets.all(12),
                              ),
                              onChanged: (value) {
                                _updateDeviceState(deviceState.copyWith(
                                  navigation: deviceState.navigation.copyWith(distance: value),
                                ));
                              },
                              controller: TextEditingController(text: deviceState.navigation.distance)
                                ..selection = TextSelection.collapsed(offset: deviceState.navigation.distance.length),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'ETA',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                isDense: true,
                                contentPadding: const EdgeInsets.all(12),
                              ),
                              onChanged: (value) {
                                _updateDeviceState(deviceState.copyWith(
                                  navigation: deviceState.navigation.copyWith(eta: value),
                                ));
                              },
                              controller: TextEditingController(text: deviceState.navigation.eta)
                                ..selection = TextSelection.collapsed(offset: deviceState.navigation.eta.length),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
      ],
    );
  }

  Future<void> _pickBackgroundImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _customPhoto = File(image.path);
        _showCustomPhotoCrop = true;
      });
    }
  }

  Widget _buildWidgetCarousel(String category, IconData categoryIcon, List<_WidgetCard> widgets) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Icon(categoryIcon, color: Colors.grey.shade600, size: 16),
              const SizedBox(width: 8),
              Text(
                category,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 145,
          child: PageView.builder(
            controller: PageController(viewportFraction: 0.38),
            physics: const BouncingScrollPhysics(),
            padEnds: false,
            itemCount: widgets.length,
            itemBuilder: (context, index) {
              final widget = widgets[index];
              final isSelected = deviceState.widgets.contains(widget.id);
              
              return _buildWidgetCardItem(
                widget,
                isSelected: isSelected,
                onTap: () async {
                  // Special handling for photo-widget to open crop screen
                  if (widget.id == 'photo-widget') {
                    await _pickCustomPhoto();
                  } else {
                    final prefix = widget.id.split('-')[0] + '-';
                    
                    // Double-click to unselect: if already selected, remove it
                    if (isSelected) {
                      final newWidgets = deviceState.widgets
                          .where((w) => !w.startsWith(prefix))
                          .toList();
                      
                      // If removing navigation widget, disable ridingMode and stop GPS
                      if (widget.id.startsWith('nav-')) {
                        _stopGPSTracking();
                        _updateDeviceState(deviceState.copyWith(
                          widgets: newWidgets,
                          navigation: deviceState.navigation.copyWith(ridingMode: false),
                        ));
                      } else {
                        _updateDeviceState(deviceState.copyWith(widgets: newWidgets));
                      }
                    } else {
                      // First click: select widget
                      final newWidgets = deviceState.widgets
                          .where((w) => !w.startsWith(prefix))
                          .toList();
                      newWidgets.add(widget.id);
                      
                      // If selecting navigation widget, enable ridingMode and start GPS
                      if (widget.id.startsWith('nav-')) {
                        _updateDeviceState(deviceState.copyWith(
                          widgets: newWidgets,
                          navigation: deviceState.navigation.copyWith(ridingMode: true),
                        ));
                        _startGPSTracking();
                      } else {
                        _updateDeviceState(deviceState.copyWith(widgets: newWidgets));
                      }
                    }
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWidgetCardItem(_WidgetCard widget, {required bool isSelected, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8, left: 8, top: 4, bottom: 4),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          width: 130,
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.color,
                      widget.color.withOpacity(0.85),
                    ],
                  )
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      Colors.grey.shade50,
                    ],
                  ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected ? widget.color.withOpacity(0.3) : Colors.grey.shade200,
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 1,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: widget.color.withOpacity(0.15),
                      blurRadius: 12,
                      spreadRadius: -2,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      spreadRadius: -2,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(22),
              splashColor: widget.color.withOpacity(0.1),
              highlightColor: widget.color.withOpacity(0.05),
              child: Stack(
                children: [
                  // Shine effect for selected cards
                  if (isSelected)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 30,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(0.25),
                              Colors.white.withOpacity(0),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(22),
                            topRight: Radius.circular(22),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Icon
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? Colors.white.withOpacity(0.25) 
                                : widget.color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Icon(
                            widget.icon,
                            color: isSelected ? Colors.white : widget.color,
                            size: 28,
                          ),
                        ),
                        // Text
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isSelected ? Colors.white : Colors.black87,
                                letterSpacing: 0.3,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              widget.description,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: isSelected 
                                    ? Colors.white.withOpacity(0.92) 
                                    : Colors.grey.shade600,
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Checkmark for selected
                  if (isSelected)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.check_rounded,
                                size: 14,
                                color: widget.color,
                              ),
                            ),
                          );
                        },
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

  Widget _buildWidgetCategory(String title, String prefix, List<(String, String)> options) {
    final currentWidget = deviceState.widgets.firstWhere(
      (w) => w.startsWith(prefix),
      orElse: () => '',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...options.map((option) {
              final isSelected = currentWidget == option.$2;
              return GestureDetector(
                onTap: () {
                  final newWidgets = deviceState.widgets
                      .where((w) => !w.startsWith(prefix))
                      .toList();
                  
                  // Double-click to unselect: if already selected, don't add it back (remove it)
                  if (!isSelected) {
                    newWidgets.add(option.$2);
                  }
                  
                  _updateDeviceState(deviceState.copyWith(widgets: newWidgets));
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    option.$1,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return SizedBox.shrink();
  }

  // Pick custom photo for background
  Future<void> _pickCustomPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _customPhoto = File(image.path);
        _showCustomPhotoCrop = true;
      });
    }
  }

  // Build custom photo crop screen
  Widget _buildCustomPhotoCropScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content - Virtual device preview with interactive wallpaper
            Center(
              child: Container(
                width: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black.withOpacity(0.2),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: AspectRatio(
                      aspectRatio: 9 / 19.5,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: GestureDetector(
                          onScaleStart: (details) {
                            _baseScale = _wallpaperScale;
                          },
                          onScaleUpdate: (details) {
                            setState(() {
                              _wallpaperScale = (_baseScale * details.scale).clamp(0.5, 3.0);
                              _wallpaperOffset += details.focalPointDelta;
                            });
                          },
                          child: Container(
                            color: Colors.black,
                            child: _customPhoto != null
                                ? Transform(
                                    transform: Matrix4.identity()
                                      ..translate(_wallpaperOffset.dx, _wallpaperOffset.dy)
                                      ..scale(_wallpaperScale)
                                      ..rotateZ(_rotationAngle * pi / 180)
                                      ..scale(_isFlippedHorizontally ? -1.0 : 1.0, 1.0),
                                    alignment: Alignment.center,
                                    child: Image.file(
                                      _customPhoto!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  )
                                : Container(color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),


            // Top - Back button (left)
            Positioned(
              top: 16,
              left: 16,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    setState(() {
                      _showCustomPhotoCrop = false;
                      _customPhoto = null;
                      _wallpaperScale = 1.0;
                      _wallpaperOffset = Offset.zero;
                      _rotationAngle = 0;
                      _isFlippedHorizontally = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.black87, size: 18),
                  ),
                ),
              ),
            ),

            // Top - Apply button (right)
            Positioned(
              top: 16,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () async {
                    if (_customPhoto != null) {
                      try {
                        final croppedFile = await _captureTransformedImage();
                        if (croppedFile != null) {
                          setState(() {
                            _croppedCustomPhoto = croppedFile;
                            _showCustomPhotoCrop = false;
                            deviceState = deviceState.copyWith(
                              backgroundImage: croppedFile.path,
                            );
                            _customPhoto = null;
                            _wallpaperScale = 1.0;
                            _wallpaperOffset = Offset.zero;
                            _rotationAngle = 0;
                            _isFlippedHorizontally = false;
                          });
                        }
                      } catch (e) {
                        print('Error applying cropped image: $e');
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade400,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.check_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),

            // Bottom - Control buttons
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildCropActionButton(Icons.flip_rounded, 'Flip', () {
                        setState(() {
                          _isFlippedHorizontally = !_isFlippedHorizontally;
                        });
                      }),
                      Container(width: 1, height: 16, color: Colors.black.withOpacity(0.06)),
                      _buildCropActionButton(Icons.rotate_right_rounded, 'Rotate', () {
                        setState(() {
                          _rotationAngle = (_rotationAngle + 90) % 360;
                        });
                      }),
                      Container(width: 1, height: 16, color: Colors.black.withOpacity(0.06)),
                      _buildCropActionButton(Icons.refresh_rounded, 'Reset', () {
                        setState(() {
                          _wallpaperScale = 1.0;
                          _wallpaperOffset = Offset.zero;
                          _rotationAngle = 0;
                          _isFlippedHorizontally = false;
                        });
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<ui.Image?> _getPreviewImage() async {
    try {
      if (_customPhoto != null && _customPhotoCropController != null) {
        return await _customPhotoCropController.croppedBitmap();
      }
    } catch (e) {
      print('Error getting preview: $e');
    }
    return null;
  }

  Future<File?> _captureTransformedImage() async {
    if (_customPhoto == null) return null;
    
    try {
      // Load the original image
      final bytes = await _customPhoto!.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final originalImage = frame.image;
      
      // Calculate virtual device dimensions (9:19.5 ratio)
      const deviceWidth = 360.0;
      const deviceHeight = 780.0;
      
      // Create a picture recorder to draw the transformed image
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, deviceWidth, deviceHeight));
      
      // Fill with black background
      canvas.drawRect(
        Rect.fromLTWH(0, 0, deviceWidth, deviceHeight),
        Paint()..color = Colors.black,
      );
      
      // Save canvas state
      canvas.save();
      
      // Apply transformations in correct order
      // 1. Translate to center
      canvas.translate(deviceWidth / 2, deviceHeight / 2);
      
      // 2. Apply flip if needed
      if (_isFlippedHorizontally) {
        canvas.scale(-1.0, 1.0);
      }
      
      // 3. Apply rotation
      canvas.rotate(_rotationAngle * pi / 180);
      
      // 4. Apply user's pan and zoom
      canvas.translate(_wallpaperOffset.dx, _wallpaperOffset.dy);
      canvas.scale(_wallpaperScale);
      
      // 5. Draw image centered
      final imageWidth = originalImage.width.toDouble();
      final imageHeight = originalImage.height.toDouble();
      final imageAspect = imageWidth / imageHeight;
      final deviceAspect = deviceWidth / deviceHeight;
      
      double drawWidth, drawHeight;
      if (imageAspect > deviceAspect) {
        drawHeight = deviceHeight;
        drawWidth = deviceHeight * imageAspect;
      } else {
        drawWidth = deviceWidth;
        drawHeight = deviceWidth / imageAspect;
      }
      
      canvas.drawImageRect(
        originalImage,
        Rect.fromLTWH(0, 0, imageWidth, imageHeight),
        Rect.fromCenter(
          center: Offset.zero,
          width: drawWidth,
          height: drawHeight,
        ),
        Paint(),
      );
      
      // Restore canvas
      canvas.restore();
      
      // Convert to image
      final picture = recorder.endRecording();
      final img = await picture.toImage(deviceWidth.toInt(), deviceHeight.toInt());
      final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
      
      if (pngBytes == null) return null;
      
      // Save to file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/cropped_wallpaper_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes.buffer.asUint8List());
      
      return file;
    } catch (e) {
      print('Error capturing transformed image: $e');
      return null;
    }
  }

  Widget _buildCropNavButton(IconData icon, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade500,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildCropActionButton(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.black87, size: 16),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCropActionButtonOld(IconData icon, String label, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _buildEditDeviceWidgetButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _showEditDeviceWidget = true;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade400,
                      Colors.blue.shade600,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.edit,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Edit Widgets',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditDeviceWidgetScreen() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black, size: 18),
          ),
          onPressed: () {
            setState(() {
              _showEditDeviceWidget = false;
            });
          },
        ),
        title: const Text(
          'Customize Widgets',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Main Scrollable Content
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 20, bottom: 250),
                child: Column(
                  children: [
                    // Compact Virtual Device (Smaller)
                    Container(
                      width: 260,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            blurRadius: 30,
                            spreadRadius: 3,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(32),
                        child: AspectRatio(
                          aspectRatio: 9 / 19.5,
                          child: Stack(
                            children: [
                              // Background
                              if (_croppedCustomPhoto != null)
                                Positioned.fill(
                                  child: Image.file(
                                    _croppedCustomPhoto!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              
                              // Swipeable Live Widget Preview
                              Center(
                                child: GestureDetector(
                                  onHorizontalDragEnd: (details) {
                                    if (details.primaryVelocity! > 0) {
                                      // Swipe right - previous widget
                                      setState(() {
                                        if (_selectedWidget == 'Time & Date') _selectedWidget = 'Clock';
                                        else if (_selectedWidget == 'Quick Navigation') _selectedWidget = 'Time & Date';
                                        else if (_selectedWidget == 'Turn-by-Turn') _selectedWidget = 'Quick Navigation';
                                        else if (_selectedWidget == 'Clock') _selectedWidget = 'Turn-by-Turn';
                                      });
                                    } else if (details.primaryVelocity! < 0) {
                                      // Swipe left - next widget
                                      setState(() {
                                        if (_selectedWidget == 'Clock') _selectedWidget = 'Time & Date';
                                        else if (_selectedWidget == 'Time & Date') _selectedWidget = 'Quick Navigation';
                                        else if (_selectedWidget == 'Quick Navigation') _selectedWidget = 'Turn-by-Turn';
                                        else if (_selectedWidget == 'Turn-by-Turn') _selectedWidget = 'Clock';
                                      });
                                    }
                                  },
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 220,
                                      maxHeight: 200,
                                    ),
                                    child: Transform.scale(
                                      scale: _widgetSizeScale,
                                      child: Opacity(
                                        opacity: _widgetOpacity,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: _widgetColor.withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          padding: const EdgeInsets.all(16),
                                          child: _buildLiveWidgetPreview(),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Swipe Indicator
                              Positioned(
                                bottom: 15,
                                left: 0,
                                right: 0,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.arrow_back_ios, size: 10, color: Colors.white.withOpacity(0.6)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Swipe to change widget',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withOpacity(0.5),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(Icons.arrow_forward_ios, size: 10, color: Colors.white.withOpacity(0.6)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Floating Bottom Panel
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildWidgetCustomizationPanel(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLiveWidgetPreview() {
    switch (_selectedWidget) {
      case 'Clock':
        return _buildClockWidget();
      case 'Time & Date':
        return _buildDateTimeWidget();
      case 'Quick Navigation':
        return _buildQuickNavigationWidget();
      case 'Turn-by-Turn':
        return _buildTurnByTurnWidget();
      default:
        return _buildClockWidget();
    }
  }
  
  Widget _buildWidgetCustomizationPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Widget Customization',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          
          // Quick Actions Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickActionButton(
                  Icons.photo_outlined,
                  'Photo',
                  () async {
                    setState(() {
                      _showEditDeviceWidget = false;
                    });
                    await _pickCustomPhoto();
                  },
                ),
                _buildQuickActionButton(
                  Icons.layers_outlined,
                  'Widgets',
                  () {
                    setState(() {
                      _showWidgetPicker = !_showWidgetPicker;
                    });
                  },
                ),
                _buildQuickActionButton(
                  Icons.format_size,
                  'Resize',
                  () {
                    setState(() {
                      _showResizeControls = !_showResizeControls;
                    });
                  },
                ),
                _buildQuickActionButton(
                  Icons.palette_outlined,
                  'Color',
                  () {
                    setState(() {
                      _showColorPicker = !_showColorPicker;
                    });
                  },
                ),
              ],
            ),
          ),
          
          Divider(height: 1, color: Colors.grey.shade200),
          
          // Scrollable Controls
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 180),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Compact Size Slider
                  _buildCompactSlider(
                    'Size',
                    Icons.aspect_ratio,
                    _widgetSizeScale,
                    0.5,
                    2.5,
                    (value) => setState(() => _widgetSizeScale = value),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Compact Opacity Slider
                  _buildCompactSlider(
                    'Opacity',
                    Icons.opacity,
                    _widgetOpacity,
                    0.3,
                    1.0,
                    (value) => setState(() => _widgetOpacity = value),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Font Size Slider
                  _buildCompactSlider(
                    'Font Size',
                    Icons.text_fields,
                    _widgetFontSize,
                    10.0,
                    24.0,
                    (value) => setState(() => _widgetFontSize = value),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Color Pills
                  Row(
                    children: [
                      Icon(Icons.palette, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Colors.white,
                              Colors.blue,
                              Colors.red,
                              Colors.green,
                              Colors.orange,
                              Colors.purple,
                              Colors.pink,
                              Colors.teal,
                            ].map((color) {
                              final isSelected = _widgetColor == color;
                              return GestureDetector(
                                onTap: () => setState(() => _widgetColor = color),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? Colors.black : Colors.grey.shade300,
                                      width: isSelected ? 2.5 : 1.5,
                                    ),
                                    boxShadow: isSelected
                                        ? [
                                            BoxShadow(
                                              color: color.withOpacity(0.4),
                                              blurRadius: 8,
                                              spreadRadius: 1,
                                            ),
                                          ]
                                        : [],
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                                      : null,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActionButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 24, color: Colors.blue),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCompactSlider(
    String label,
    IconData icon,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              activeTrackColor: Colors.blue,
              inactiveTrackColor: Colors.grey.shade200,
              thumbColor: Colors.blue,
              overlayColor: Colors.blue.withOpacity(0.2),
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 35,
          child: Text(
            value.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildCustomSlider(String title, IconData icon, double value, double min, double max, ValueChanged<double> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: Colors.blue),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: Colors.blue,
            inactiveTrackColor: Colors.blue.withOpacity(0.2),
            thumbColor: Colors.blue,
            overlayColor: Colors.blue.withOpacity(0.2),
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildResizableWidget(String widgetId) {
    // Apply customization to widgets
    return Positioned(
      top: 100,
      left: 50,
      child: Transform.scale(
        scale: _widgetSizeScale,
        child: Opacity(
          opacity: _widgetOpacity,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedWidgetForEdit = widgetId;
              });
            },
            onPanUpdate: (details) {
              // Handle drag to reposition widget
              setState(() {
                // You can implement position tracking here
              });
            },
            child: Container(
              padding: EdgeInsets.all(12 * _widgetSizeScale),
              decoration: BoxDecoration(
                color: _widgetColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedWidgetForEdit == widgetId 
                      ? _widgetColor 
                      : _widgetColor.withOpacity(0.3),
                  width: _selectedWidgetForEdit == widgetId ? 2.5 : 1.5,
                ),
                boxShadow: _selectedWidgetForEdit == widgetId
                    ? [
                        BoxShadow(
                          color: _widgetColor.withOpacity(0.3),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: Text(
                widgetId,
                style: TextStyle(
                  fontSize: _widgetFontSize,
                  color: _widgetColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget Card Data Class
class _WidgetCard {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  _WidgetCard({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
