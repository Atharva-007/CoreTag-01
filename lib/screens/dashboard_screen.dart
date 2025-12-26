import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
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
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
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
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade300, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.wallpaper, color: Colors.blue.shade700, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Background Photo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (deviceState.backgroundImage == null)
                      InkWell(
                        onTap: _pickBackgroundImage,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.add_photo_alternate_outlined, 
                                size: 40, 
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tap to select photo',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          Container(
                            height: 120,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(deviceState.backgroundImage!),
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: Colors.grey.shade200,
                                  child: Icon(Icons.broken_image, size: 40, color: Colors.grey.shade400),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _pickBackgroundImage,
                                  icon: const Icon(Icons.edit_outlined, size: 18),
                                  label: const Text('Change'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.blue.shade700,
                                    side: BorderSide(color: Colors.blue.shade300, width: 1.5),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    _updateDeviceState(deviceState.copyWith(backgroundImage: null));
                                  },
                                  icon: const Icon(Icons.close, size: 18),
                                  label: const Text('Remove'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red.shade700,
                                    side: BorderSide(color: Colors.red.shade300, width: 1.5),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
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
                      },
                      activeColor: const Color(0xFF6366F1),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                    ),
                    if (deviceState.navigation.ridingMode) ...[
                      const SizedBox(height: 8),
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
      _updateDeviceState(deviceState.copyWith(backgroundImage: image.path));
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
            itemCount: widgets.length + 1,
            itemBuilder: (context, index) {
              if (index == widgets.length) {
                // None card
                final prefix = widgets.isNotEmpty ? widgets[0].id.split('-')[0] + '-' : '';
                final hasWidget = deviceState.widgets.any((w) => w.startsWith(prefix));
                
                return _buildWidgetCardItem(
                  _WidgetCard(
                    id: '',
                    title: 'None',
                    description: 'Remove widget',
                    icon: Icons.close,
                    color: Colors.red.shade400,
                  ),
                  isSelected: !hasWidget,
                  onTap: () {
                    if (prefix.isNotEmpty) {
                      final newWidgets = deviceState.widgets
                          .where((w) => !w.startsWith(prefix))
                          .toList();
                      _updateDeviceState(deviceState.copyWith(widgets: newWidgets));
                    }
                  },
                );
              }
              
              final widget = widgets[index];
              final isSelected = deviceState.widgets.contains(widget.id);
              
              return _buildWidgetCardItem(
                widget,
                isSelected: isSelected,
                onTap: () {
                  final prefix = widget.id.split('-')[0] + '-';
                  final newWidgets = deviceState.widgets
                      .where((w) => !w.startsWith(prefix))
                      .toList();
                  newWidgets.add(widget.id);
                  _updateDeviceState(deviceState.copyWith(widgets: newWidgets));
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
                  newWidgets.add(option.$2);
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
            GestureDetector(
              onTap: () {
                final newWidgets = deviceState.widgets
                    .where((w) => !w.startsWith(prefix))
                    .toList();
                _updateDeviceState(deviceState.copyWith(widgets: newWidgets));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: currentWidget.isEmpty ? Colors.red.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: currentWidget.isEmpty ? Colors.red.shade300 : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  'None',
                  style: TextStyle(
                    fontSize: 13,
                    color: currentWidget.isEmpty ? Colors.red : Colors.black87,
                    fontWeight: currentWidget.isEmpty ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return FadeTransition(
      opacity: _fadeController,
      child: Text(
        'Built with Flutter',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
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
