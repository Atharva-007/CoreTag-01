import 'package:flutter/material.dart';
import 'dart:async';
import '../models/device_state.dart';
import '../widgets/device_preview.dart';
import '../models/widget_card.dart';
import '../models/custom_widget_state.dart';

/// Enhanced Tag Mode Customization Screen
/// 
/// Ultra-minimal mode for tracking items (keys, bags, pets, etc.).
/// Features:
/// - Live device preview with animations
/// - Tag name customization
/// - Location tracking toggle
/// - Battery monitoring
/// - Find device alert system
/// - Minimal, focused UI
/// 
/// Navigation Flow:
/// Dashboard (Tag mode) → Edit Widgets → TagCustomizationScreen
class TagCustomizationScreen extends StatefulWidget {
  final List<WidgetCard> allWidgetCards;
  final DeviceState initialDeviceState;

  const TagCustomizationScreen({
    super.key,
    required this.allWidgetCards,
    required this.initialDeviceState,
  });

  @override
  State<TagCustomizationScreen> createState() => _TagCustomizationScreenState();
}

class _TagCustomizationScreenState extends State<TagCustomizationScreen> 
    with TickerProviderStateMixin {
  late DeviceState deviceState;
  late AnimationController _pulseController;
  late AnimationController _previewAnimationController;
  late TextEditingController _tagNameController;
  String? _selectedWidgetId;
  
  // Tag mode specific settings
  bool _locationTrackingEnabled = true;
  bool _lowPowerMode = true;
  bool _findDeviceAlert = false;
  String _lastSeenLocation = 'Home';
  DateTime _lastSeenTime = DateTime.now();
  final int _batteryLevel = 85;

  @override
  void initState() {
    super.initState();
    deviceState = widget.initialDeviceState;
    _tagNameController = TextEditingController(
      text: deviceState.customName.isEmpty ? 'My Tag' : deviceState.customName,
    );
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _previewAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    // Initialize with tag-mode appropriate minimal widgets
    _initializeTagModeWidgets();
    
    _previewAnimationController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _previewAnimationController.dispose();
    _tagNameController.dispose();
    super.dispose();
  }

  void _initializeTagModeWidgets() {
    // Tag mode uses minimal widgets - just time
    if (deviceState.widgets.isEmpty || 
        !deviceState.widgets.any((w) => w.id.startsWith('time-'))) {
      final defaultWidgets = [
        CustomWidgetState(id: 'time-digital-small'),
      ];
      setState(() {
        deviceState = deviceState.copyWith(widgets: defaultWidgets);
      });
    }
  }

  void _onWidgetSelected(String? widgetId) {
    setState(() {
      _selectedWidgetId = widgetId;
    });
  }

  void _triggerFindDevice() {
    setState(() {
      _findDeviceAlert = true;
    });
    
    // Show alert dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.notifications_active, color: Color(0xFFF59E0B), size: 28),
            SizedBox(width: 12),
            Text('Find Device Alert'),
          ],
        ),
        content: const Text(
          'The device will flash and beep to help you locate it.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _findDeviceAlert = false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Simulate device alert
              Future.delayed(const Duration(seconds: 3), () {
                if (mounted) {
                  setState(() => _findDeviceAlert = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Device alert stopped'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF59E0B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Activate'),
          ),
        ],
      ),
    );
  }

  void _updateTagName(String name) {
    setState(() {
      deviceState = deviceState.copyWith(customName: name);
    });
    _previewAnimationController.reset();
    _previewAnimationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Premium Header with back and save buttons (matching watch customization screen)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button (cancel changes)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back, color: Colors.black),
                    ),
                  ),
                  // Mode indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.sell, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Tag Mode',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Save button (apply changes)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withValues(alpha: 0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context, deviceState),
                      icon: const Icon(Icons.check, color: Color(0xFFF59E0B)),
                    ),
                  ),
                ],
              ),
            ),
            // Main content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    // Device Preview with animation
                    FadeTransition(
                      opacity: _previewAnimationController,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.9, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _previewAnimationController,
                            curve: Curves.easeOutBack,
                          ),
                        ),
                        child: Hero(
                          tag: 'device_preview',
                          child: DevicePreview(
                            deviceState: deviceState,
                            selectedWidgetId: _selectedWidgetId,
                            onWidgetSelected: _onWidgetSelected,
                            width: 200,
                            allWidgetCards: widget.allWidgetCards,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Find Device Button
                    _buildFindDeviceButton(),
                    const SizedBox(height: 32),
                    // Tag Information Panel
                    _buildTagInfoPanel(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFindDeviceButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: _findDeviceAlert ? 1.0 + (_pulseController.value * 0.1) : 1.0,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _findDeviceAlert
                      ? [const Color(0xFFEF4444), const Color(0xFFDC2626)]
                      : [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: (_findDeviceAlert 
                        ? const Color(0xFFEF4444) 
                        : const Color(0xFFF59E0B)).withValues(alpha: 0.4),
                    blurRadius: _findDeviceAlert ? 20 : 12,
                    spreadRadius: _findDeviceAlert ? 2 : 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _triggerFindDevice,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _findDeviceAlert ? Icons.notifications_active : Icons.notifications,
                          color: Colors.white,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _findDeviceAlert ? 'Alert Active!' : 'Find My Tag',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTagInfoPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag Name Card
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Tag Name', Icons.label),
                const SizedBox(height: 16),
                TextField(
                  controller: _tagNameController,
                  onChanged: _updateTagName,
                  decoration: InputDecoration(
                    hintText: 'Enter tag name',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    prefixIcon: const Icon(Icons.edit, color: Color(0xFFF59E0B)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFF59E0B), width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Location Info Card
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Location', Icons.location_on),
                const SizedBox(height: 16),
                _buildInfoRow(
                  icon: Icons.place,
                  label: 'Last Seen',
                  value: _lastSeenLocation,
                  color: const Color(0xFF3B82F6),
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.access_time,
                  label: 'Time',
                  value: _formatLastSeen(),
                  color: const Color(0xFF8B5CF6),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        _lastSeenTime = DateTime.now();
                        _lastSeenLocation = 'Current Location';
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Location updated successfully'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: const Icon(Icons.my_location),
                    label: const Text('Update Location'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Battery Status Card
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Battery', Icons.battery_full),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$_batteryLevel%',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getBatteryStatus(),
                            style: TextStyle(
                              fontSize: 14,
                              color: _getBatteryColor(),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getBatteryColor().withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getBatteryIcon(),
                        color: _getBatteryColor(),
                        size: 48,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _batteryLevel / 100,
                    backgroundColor: Colors.grey.shade200,
                    color: _getBatteryColor(),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Settings Card
          _buildCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Settings', Icons.settings),
                const SizedBox(height: 16),
                _buildToggleTile(
                  title: 'Location Tracking',
                  subtitle: 'Track device location',
                  value: _locationTrackingEnabled,
                  onChanged: (value) {
                    setState(() => _locationTrackingEnabled = value);
                  },
                  icon: Icons.location_on,
                ),
                const SizedBox(height: 12),
                _buildToggleTile(
                  title: 'Low Power Mode',
                  subtitle: 'Extend battery life',
                  value: _lowPowerMode,
                  onChanged: (value) {
                    setState(() => _lowPowerMode = value);
                  },
                  icon: Icons.battery_saver,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFFF59E0B), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFF59E0B), size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  String _formatLastSeen() {
    final now = DateTime.now();
    final difference = now.difference(_lastSeenTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }

  String _getBatteryStatus() {
    if (_batteryLevel > 50) return 'Good';
    if (_batteryLevel > 20) return 'Medium';
    return 'Low - Charge Soon';
  }

  Color _getBatteryColor() {
    if (_batteryLevel > 50) return const Color(0xFF10B981);
    if (_batteryLevel > 20) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  IconData _getBatteryIcon() {
    if (_batteryLevel > 75) return Icons.battery_full;
    if (_batteryLevel > 50) return Icons.battery_5_bar;
    if (_batteryLevel > 25) return Icons.battery_3_bar;
    return Icons.battery_1_bar;
  }
}
