import 'package:flutter/material.dart';
import '../models/device_state.dart';
import '../widgets/device_preview.dart';
import '../widgets/floating_nav_bar.dart'; // Import bottom nav bar
import 'watch_customization_screen.dart'; // Watch mode customization
import 'carry_customization_screen.dart'; // Carry mode customization
import 'tag_customization_screen.dart'; // Tag mode customization
import 'profile_screen.dart';
import 'display_themes_screen.dart'; // Import display themes screen
import 'add_device_screen.dart'; // Import add device screen
import 'find_device_screen.dart'; // Import find device screen
import '../models/widget_card.dart'; // Import the new public WidgetCard
import '../services/gps_service.dart'; // Import GpsService
import '../services/music_service.dart'; // Import MusicService
import '../services/navigation_service.dart'; // Import NavigationService
import '../state/device_state_notifier.dart'; // Import deviceStateNotifier
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

final List<WidgetCard> allWidgetCards = [
    // Time Widgets
    WidgetCard(id: 'time-digital-large', title: 'Large Digital', description: 'Bold time display', icon: Icons.watch, color: const Color(0xFF6366F1)),
    WidgetCard(id: 'time-digital-small', title: 'Small Digital', description: 'Compact time', icon: Icons.timer_outlined, color: const Color(0xFF8B5CF6)),
    WidgetCard(id: 'time-analog-small', title: 'Small Analog', description: 'Classic watch', icon: Icons.watch_later_outlined, color: const Color(0xFFA855F7)),
    WidgetCard(id: 'time-analog-large', title: 'Large Analog', description: 'Traditional clock', icon: Icons.schedule, color: const Color(0xFFC026D3)),
    WidgetCard(id: 'time-text-date', title: 'Date & Time', description: 'With calendar', icon: Icons.calendar_today, color: const Color(0xFFD946EF)),
    // Weather Widgets
    WidgetCard(id: 'weather-icon', title: 'Weather Icon', description: 'Condition only', icon: Icons.wb_sunny, color: const Color(0xFFF59E0B)),
    WidgetCard(id: 'weather-temp-icon', title: 'Temperature', description: 'Temp with icon', icon: Icons.thermostat, color: const Color(0xFFEF4444)),
    WidgetCard(id: 'weather-full', title: 'Full Forecast', description: 'Detailed weather', icon: Icons.cloud_queue, color: const Color(0xFF3B82F6)),
    // Music Widgets
    WidgetCard(id: 'music-mini', title: 'Mini Player', description: 'Track name only', icon: Icons.music_note, color: const Color(0xFFEC4899)),
    WidgetCard(id: 'music-full', title: 'Now Playing', description: 'Full controls', icon: Icons.queue_music, color: const Color(0xFFDB2777)),
    // Photo Widget
    WidgetCard(id: 'photo-widget', title: 'Custom Photo', description: 'Personal image', icon: Icons.add_photo_alternate, color: const Color(0xFF7C3AED)),
    // Navigation Widgets
    WidgetCard(id: 'nav-compact', title: 'Quick Nav', description: 'Distance only', icon: Icons.near_me, color: const Color(0xFF1A73E8)),
    WidgetCard(id: 'nav-full', title: 'Turn-by-Turn', description: 'Full directions', icon: Icons.directions, color: const Color(0xFF0E62C7)),
  ];

class _DashboardScreenState extends ConsumerState<DashboardScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late GpsService _gpsService;
  late MusicService _musicService; // Declare MusicService
  late NavigationService _navigationService; // Declare NavigationService

  @override
  void initState() {
    super.initState();
    
    // Reduce animation duration for better performance
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeController.forward();
    _slideController.forward();

    _gpsService = GpsService(
      onGpsDataUpdated: (speed, totalDistance, nextTurn, remainingDistance, direction) {
        ref.read(deviceStateNotifierProvider.notifier).updateNavigationState(
          isNavigating: true,
          currentSpeed: speed,
          distance: totalDistance < 1000 ? '${totalDistance.toStringAsFixed(0)} m' : '${(totalDistance / 1000).toStringAsFixed(2)} km',
          direction: nextTurn,
          eta: direction,
        );
      },
      onPermissionDenied: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );

    _musicService = MusicService(
      onMusicDataUpdated: (title, artist, isPlaying, albumArt) {
        ref.read(deviceStateNotifierProvider.notifier).updateMusicState(
          trackTitle: title,
          artist: artist,
          isPlaying: isPlaying,
          albumArt: albumArt,
        );
      },
      onPermissionDenied: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );

    _navigationService = NavigationService(
      onNavigationDataUpdated: (isNavigating, direction, distance, ctx) {
        if (isNavigating) {
          _gpsService.startGPSTracking(ctx);
        } else {
          _gpsService.stopGPSTracking();
        }
        ref.read(deviceStateNotifierProvider.notifier).updateNavigationState(
          isNavigating: isNavigating,
          direction: direction,
          distance: distance,
        );
      },
      onPermissionDenied: (message) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );
    
    // Start music detection
    _musicService.startMusicDetection(context);
    
    // Start navigation detection
    _navigationService.startNavigationDetection(context);
  }
  
  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _musicService.dispose(); // Dispose the MusicService
    _navigationService.dispose(); // Dispose the NavigationService
    _gpsService.dispose(); // Dispose the GpsService
    super.dispose();
  }

  // Find My Device handler
  void _handleFindDevice(DeviceState deviceState) {
    // Navigate to Find Device screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const FindDeviceScreen()),
    );
  }

  // _updateDeviceState method is no longer needed because the state is managed by Riverpod.
  // void _updateDeviceState(DeviceState newState) {
  //   setState(() {
  //     deviceState = newState;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    final deviceState = ref.watch(deviceStateNotifierProvider);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFEFF6FF),
                  const Color(0xFFE0E7FF).withValues(alpha: 0.8),
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: 24.0,
                    right: 24.0,
                    top: 16.0,
                    bottom: 100.0, // Extra padding for bottom nav bar
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 24),
                      // Device Preview centered - Removed heavy animation
                      Center(
                        child: DevicePreview(
                          deviceState: deviceState,
                          width: 200,
                          allWidgetCards: allWidgetCards,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Edit Device Widget Button
                      _buildEditDeviceWidgetButton(deviceState),
                      const SizedBox(height: 32),
                      // Customization sections below device
                      _buildCustomizationSections(deviceState),
                      const SizedBox(height: 32),
                      _buildFooter(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.person, size: 30),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ProfileScreen()),
                  );
                },
              ),
            ),
          ),
          
          // Floating Bottom Navigation Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavBar(
              currentIndex: 0,
              onFindDevice: () {
                _handleFindDevice(deviceState);
              },
              onAddDevice: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddDeviceScreen(),
                  ),
                );
              },
              onDisplayThemes: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DisplayThemesScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }



// ... (rest of the file)

  Widget _buildEditDeviceWidgetButton(DeviceState deviceState) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          // ============================================================
          // MODE-BASED NAVIGATION LOGIC
          // ============================================================
          // Routes to different customization screens based on device mode:
          // - 'watch' → WatchCustomizationScreen (full customization)
          // - 'carry' → CarryCustomizationScreen (music/nav focused)
          // - 'tag'   → TagCustomizationScreen (minimal tracking)
          // ============================================================
          
          Widget customizationScreen;
          
          switch (deviceState.deviceMode) {
            case 'watch':
              // Watch mode: Full widget customization
              customizationScreen = WatchCustomizationScreen(
                allWidgetCards: allWidgetCards,
                initialDeviceState: deviceState,
              );
              break;
            
            case 'carry':
              // Carry mode: Music & navigation focused
              customizationScreen = CarryCustomizationScreen(
                allWidgetCards: allWidgetCards,
                initialDeviceState: deviceState,
              );
              break;
            
            case 'tag':
              // Tag mode: Minimal tracking display
              customizationScreen = TagCustomizationScreen(
                allWidgetCards: allWidgetCards,
                initialDeviceState: deviceState,
              );
              break;
            
            default:
              // Fallback to watch mode if invalid mode
              customizationScreen = WatchCustomizationScreen(
                allWidgetCards: allWidgetCards,
                initialDeviceState: deviceState,
              );
          }

          // Navigate to the selected customization screen
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => customizationScreen),
          );

          // Update global state if changes were saved
          if (result != null && result is DeviceState) {
            ref.read(deviceStateNotifierProvider.notifier).updateDeviceState(result);
          }
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

  Widget _buildCustomizationSections(DeviceState deviceState) {
    return Column(
      children: [
        _buildThemeSection(deviceState),
        const SizedBox(height: 24),
      ],
    );
  }



  Widget _buildThemeSection(DeviceState deviceState) {
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
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
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
                          const Color(0xFF6366F1).withValues(alpha: 0.15),
                          const Color(0xFF8B5CF6).withValues(alpha: 0.15),
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
                              : const Color(0xFF6366F1)).withValues(alpha: 0.3),
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
                          ref.read(deviceStateNotifierProvider.notifier).setAODEnabled(!deviceState.aod.enabled);
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
              const SizedBox(height: 20),
              // Device Mode Label
              Row(
                children: [
                  Icon(
                    Icons.devices_rounded,
                    color: Colors.grey.shade600,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Device Mode',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Device Mode Toggle Buttons
              Row(
                children: [
                  Expanded(child: _buildModeOption('Tag', 'tag', Icons.label)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildModeOption('Carry', 'carry', Icons.backpack)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildModeOption('Watch', 'watch', Icons.watch)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(String label, String theme) {
    final deviceState = ref.watch(deviceStateNotifierProvider); // Watch the deviceState
    final isSelected = deviceState.theme == theme;
    return GestureDetector(
      onTap: () => ref.read(deviceStateNotifierProvider.notifier).setTheme(theme),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 10), // Reduced padding
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
          borderRadius: BorderRadius.circular(12), // Reduced border radius
          border: Border.all(
            color: isSelected ? const Color(0xFF6366F1).withValues(alpha: 0.3) : Colors.grey.shade200,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                    blurRadius: 10, // Reduced blur
                    spreadRadius: 0,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4, // Reduced blur
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
              fontSize: 14, // Reduced font size
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeOption(String label, String mode, IconData icon) {
    final deviceState = ref.watch(deviceStateNotifierProvider);
    final isSelected = deviceState.deviceMode == mode;
    return GestureDetector(
      onTap: () => ref.read(deviceStateNotifierProvider.notifier).setDeviceMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF10B981),
                    Color(0xFF059669),
                  ],
                )
              : LinearGradient(
                  colors: [
                    Colors.grey.shade100,
                    Colors.grey.shade50,
                  ],
                ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF10B981).withValues(alpha: 0.3) : Colors.grey.shade200,
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.3),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 12,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return const SizedBox.shrink();
  }
}