import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/device_state_notifier.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notifications = true;
  bool _autoSync = true;
  bool _batteryOptimization = false;
  bool _highRefreshRate = true;
  bool _hapticFeedback = true;
  double _brightnessLevel = 0.8;
  String _language = 'English';
  String _timeFormat = '24-hour';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notifications = prefs.getBool('notificationsEnabled') ?? true;
      _autoSync = prefs.getBool('autoSync') ?? true;
      _batteryOptimization = prefs.getBool('batteryOptimization') ?? false;
      _highRefreshRate = prefs.getBool('highRefreshRate') ?? true;
      _hapticFeedback = prefs.getBool('hapticFeedback') ?? true;
      _brightnessLevel = prefs.getDouble('brightnessLevel') ?? 0.8;
      _language = prefs.getString('language') ?? 'English';
      _timeFormat = prefs.getString('timeFormat') ?? '24-hour';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceState = ref.watch(deviceStateNotifierProvider);
    final isDark = deviceState.theme == 'dark';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Premium Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
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
                  // Screen title
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.settings, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Settings',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Help button
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
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Configure app and device settings'),
                            backgroundColor: const Color(0xFF6366F1),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      },
                      icon: const Icon(Icons.help_outline, color: Color(0xFF6366F1)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
          // Device Name Setting
          _buildSectionCard(
            isDark: isDark,
            title: 'Device',
            icon: Icons.devices,
            children: [
              ListTile(
                leading: const Icon(Icons.badge, color: Colors.blue),
                title: Text(
                  'Custom Device Name',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
                subtitle: Text(
                  deviceState.customName.isEmpty ? 'Tap to set name' : deviceState.customName,
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                trailing: const Icon(Icons.edit, size: 20),
                onTap: () {
                  _showDeviceNameDialog();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Display Settings
          _buildSectionCard(
            isDark: isDark,
            title: 'Display',
            icon: Icons.display_settings,
            children: [
              SwitchListTile(
                title: Text(
                  'Dark Mode',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
                subtitle: Text(
                  'Use dark theme',
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                value: deviceState.theme == 'dark',
                onChanged: (bool value) {
                  ref.read(deviceStateNotifierProvider.notifier).setTheme(value ? 'dark' : 'light');
                  _saveSetting('darkMode', value);
                },
                secondary: Icon(
                  Icons.dark_mode,
                  color: Colors.blue,
                ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.brightness_6, color: Colors.blue),
                title: Text(
                  'Brightness',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${(_brightnessLevel * 100).toInt()}%',
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                    Slider(
                      value: _brightnessLevel,
                      onChanged: (value) {
                        setState(() {
                          _brightnessLevel = value;
                        });
                      },
                      onChangeEnd: (value) {
                        _saveSetting('brightnessLevel', value);
                      },
                    ),
                  ],
                ),
              ),
              const Divider(),
              SwitchListTile(
                title: Text(
                  'High Refresh Rate',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
                subtitle: Text(
                  'Enable 90Hz/120Hz display',
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                value: _highRefreshRate,
                onChanged: (bool value) {
                  setState(() {
                    _highRefreshRate = value;
                  });
                  _saveSetting('highRefreshRate', value);
                },
                secondary: const Icon(Icons.speed, color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Notification Settings
          _buildSectionCard(
            isDark: isDark,
            title: 'Notifications',
            icon: Icons.notifications,
            children: [
              SwitchListTile(
                title: Text(
                  'Enable Notifications',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
                subtitle: Text(
                  'Receive app notifications',
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                value: _notifications,
                onChanged: (bool value) {
                  setState(() {
                    _notifications = value;
                  });
                  _saveSetting('notificationsEnabled', value);
                },
                secondary: const Icon(Icons.notifications_active, color: Colors.blue),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.music_note, color: Colors.blue),
                title: Text(
                  'Music Notifications',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
                subtitle: Text(
                  'Detect playing music',
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.navigation, color: Colors.blue),
                title: Text(
                  'Navigation Notifications',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
                subtitle: Text(
                  'Detect map navigation',
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Connectivity & Sync
          _buildSectionCard(
            isDark: isDark,
            title: 'Connectivity',
            icon: Icons.sync,
            children: [
              SwitchListTile(
                title: Text(
                  'Auto Sync',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
                subtitle: Text(
                  'Automatically sync device data',
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                value: _autoSync,
                onChanged: (bool value) {
                  setState(() {
                    _autoSync = value;
                  });
                  _saveSetting('autoSync', value);
                },
                secondary: const Icon(Icons.sync, color: Colors.blue),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.bluetooth, color: Colors.blue),
                title: Text(
                  'Bluetooth Connection',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
                subtitle: Text(
                  'Connected: PhotoTag Device',
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Connected',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                ),
                onTap: () {
                  _showBluetoothDialog();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Performance Settings
          _buildSectionCard(
            isDark: isDark,
            title: 'Performance',
            icon: Icons.speed,
            children: [
              SwitchListTile(
                title: Text(
                  'Battery Optimization',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
                subtitle: Text(
                  'Reduce background activity',
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                value: _batteryOptimization,
                onChanged: (bool value) {
                  setState(() {
                    _batteryOptimization = value;
                  });
                  _saveSetting('batteryOptimization', value);
                },
                secondary: const Icon(Icons.battery_saver, color: Colors.blue),
              ),
              const Divider(),
              SwitchListTile(
                title: Text(
                  'Haptic Feedback',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
                subtitle: Text(
                  'Vibration on interactions',
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                value: _hapticFeedback,
                onChanged: (bool value) {
                  setState(() {
                    _hapticFeedback = value;
                  });
                  _saveSetting('hapticFeedback', value);
                },
                secondary: const Icon(Icons.vibration, color: Colors.blue),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Language & Region
          _buildSectionCard(
            isDark: isDark,
            title: 'Language & Region',
            icon: Icons.language,
            children: [
              ListTile(
                leading: const Icon(Icons.translate, color: Colors.blue),
                title: Text(
                  'Language',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
                subtitle: Text(
                  _language,
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showLanguageDialog();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.access_time, color: Colors.blue),
                title: Text(
                  'Time Format',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
                subtitle: Text(
                  _timeFormat,
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  _showTimeFormatDialog();
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Data & Storage
          _buildSectionCard(
            isDark: isDark,
            title: 'Data & Storage',
            icon: Icons.storage,
            children: [
              ListTile(
                leading: const Icon(Icons.cloud_download, color: Colors.blue),
                title: Text(
                  'Backup Data',
                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                ),
                subtitle: Text(
                  'Last backup: Today, 12:30 PM',
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                onTap: () {
                  _showBackupDialog();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text(
                  'Clear Cache',
                  style: TextStyle(color: Colors.red),
                ),
                subtitle: Text(
                  '128 MB cached data',
                  style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                ),
                onTap: () {
                  _showClearCacheDialog();
                },
              ),
            ],
          ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required bool isDark,
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: Colors.blue, size: 24),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  void _showLanguageDialog() {
    final languages = ['English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese'];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: languages.map((lang) {
            return RadioListTile<String>(
              title: Text(lang),
              value: lang,
              groupValue: _language,
              onChanged: (value) {
                setState(() {
                  _language = value!;
                });
                _saveSetting('language', value!);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showTimeFormatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Time Format'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('12-hour'),
              value: '12-hour',
              groupValue: _timeFormat,
              onChanged: (value) {
                setState(() {
                  _timeFormat = value!;
                });
                _saveSetting('timeFormat', value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('24-hour'),
              value: '24-hour',
              groupValue: _timeFormat,
              onChanged: (value) {
                setState(() {
                  _timeFormat = value!;
                });
                _saveSetting('timeFormat', value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBluetoothDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bluetooth Devices'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Connected Devices:'),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.devices, color: Colors.blue),
              title: const Text('PhotoTag Device'),
              subtitle: const Text('Connected'),
              trailing: const Icon(Icons.check_circle, color: Colors.green),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Scanning for devices...')),
              );
            },
            child: const Text('Scan'),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Data'),
        content: const Text('Do you want to backup your data now?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Backing up data...'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Backup'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('This will remove 128 MB of cached data. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showDeviceNameDialog() {
    final TextEditingController nameController = TextEditingController(
      text: ref.read(deviceStateNotifierProvider).customName,
    );
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Device Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Device Name',
            hintText: 'Enter custom name (e.g., My CoreTag)',
            border: OutlineInputBorder(),
          ),
          maxLength: 20,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameController.text.trim();
              ref.read(deviceStateNotifierProvider.notifier).setCustomName(newName);
              _saveSetting('deviceCustomName', newName);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(newName.isEmpty ? 'Device name cleared' : 'Device name set to: $newName'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}