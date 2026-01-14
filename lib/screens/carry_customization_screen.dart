import 'package:flutter/material.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../models/device_state.dart';
import '../widgets/device_preview.dart';
import '../models/widget_card.dart';
import '../models/custom_widget_state.dart';

/// Enhanced Carry Mode Customization Screen
/// 
/// Optimized for music and navigation while on-the-go.
/// Features:
/// - Live device preview with real-time updates
/// - Music widget customization (size, style, color)
/// - Navigation widget customization
/// - Background image selection
/// - Widget opacity and size controls
/// - Smooth animations and transitions
/// 
/// Navigation Flow:
/// Dashboard (Carry mode) → Edit Widgets → CarryCustomizationScreen
class CarryCustomizationScreen extends StatefulWidget {
  final List<WidgetCard> allWidgetCards;
  final DeviceState initialDeviceState;

  const CarryCustomizationScreen({
    super.key,
    required this.allWidgetCards,
    required this.initialDeviceState,
  });

  @override
  State<CarryCustomizationScreen> createState() => _CarryCustomizationScreenState();
}

class _CarryCustomizationScreenState extends State<CarryCustomizationScreen> 
    with TickerProviderStateMixin {
  late DeviceState deviceState;
  late TabController _tabController;
  late AnimationController _previewAnimationController;
  String? _selectedWidgetId;
  
  // Carry mode specific settings
  bool _musicControlEnabled = true;
  bool _navigationEnabled = true;
  String _selectedMusicWidget = 'music-mini';
  String _selectedNavWidget = 'nav-compact';

  @override
  void initState() {
    super.initState();
    deviceState = widget.initialDeviceState;
    _tabController = TabController(length: 3, vsync: this);
    
    _previewAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Initialize with carry-mode appropriate widgets
    _initializeCarryModeWidgets();
    
    // Check initial widget states
    _musicControlEnabled = deviceState.widgets.any((w) => w.id.startsWith('music-'));
    _navigationEnabled = deviceState.widgets.any((w) => w.id.startsWith('nav-'));
    
    // Determine selected widget variants
    final musicWidget = deviceState.widgets.firstWhere(
      (w) => w.id.startsWith('music-'),
      orElse: () => CustomWidgetState(id: 'music-mini'),
    );
    _selectedMusicWidget = musicWidget.id;
    
    final navWidget = deviceState.widgets.firstWhere(
      (w) => w.id.startsWith('nav-'),
      orElse: () => CustomWidgetState(id: 'nav-compact'),
    );
    _selectedNavWidget = navWidget.id;
    
    _previewAnimationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _previewAnimationController.dispose();
    super.dispose();
  }

  void _initializeCarryModeWidgets() {
    // Add default carry mode widgets if none exist
    if (deviceState.widgets.isEmpty) {
      final defaultWidgets = [
        CustomWidgetState(id: 'time-digital-small'),
        CustomWidgetState(id: 'music-mini'),
        CustomWidgetState(id: 'nav-compact'),
      ];
      setState(() {
        deviceState = deviceState.copyWith(widgets: defaultWidgets);
      });
    }
  }

  void _updateDeviceState(DeviceState newState) {
    setState(() {
      deviceState = newState;
    });
    _previewAnimationController.reset();
    _previewAnimationController.forward();
  }

  void _onWidgetSelected(String? widgetId) {
    setState(() {
      _selectedWidgetId = widgetId;
    });
  }

  void _toggleMusicWidget(bool enabled) {
    setState(() {
      _musicControlEnabled = enabled;
      
      final newWidgets = deviceState.widgets.where((w) => !w.id.startsWith('music-')).toList();
      if (enabled) {
        newWidgets.add(CustomWidgetState(id: _selectedMusicWidget));
      }
      deviceState = deviceState.copyWith(widgets: newWidgets);
    });
    _previewAnimationController.reset();
    _previewAnimationController.forward();
  }

  void _changeMusicWidgetStyle(String widgetId) {
    setState(() {
      _selectedMusicWidget = widgetId;
      if (_musicControlEnabled) {
        final newWidgets = deviceState.widgets.where((w) => !w.id.startsWith('music-')).toList();
        newWidgets.add(CustomWidgetState(id: widgetId));
        deviceState = deviceState.copyWith(widgets: newWidgets);
      }
    });
    _previewAnimationController.reset();
    _previewAnimationController.forward();
  }

  void _toggleNavigationWidget(bool enabled) {
    setState(() {
      _navigationEnabled = enabled;
      
      final newWidgets = deviceState.widgets.where((w) => !w.id.startsWith('nav-')).toList();
      if (enabled) {
        newWidgets.add(CustomWidgetState(id: _selectedNavWidget));
      }
      deviceState = deviceState.copyWith(widgets: newWidgets);
    });
    _previewAnimationController.reset();
    _previewAnimationController.forward();
  }

  void _changeNavigationWidgetStyle(String widgetId) {
    setState(() {
      _selectedNavWidget = widgetId;
      if (_navigationEnabled) {
        final newWidgets = deviceState.widgets.where((w) => !w.id.startsWith('nav-')).toList();
        newWidgets.add(CustomWidgetState(id: widgetId));
        deviceState = deviceState.copyWith(widgets: newWidgets);
      }
    });
    _previewAnimationController.reset();
    _previewAnimationController.forward();
  }

  Future<void> _pickBackgroundImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Background',
            toolbarColor: const Color(0xFFEC4899),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Background',
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          deviceState = deviceState.copyWith(backgroundImage: croppedFile.path);
        });
      }
    }
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
                        colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.directions_walk, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Carry Mode',
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
                      icon: const Icon(Icons.check, color: Color(0xFFEC4899)),
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
                    // Customization Panel
                    _buildCustomizationPanel(),
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

  Widget _buildCustomizationPanel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Tab Bar
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFFEC4899),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFFEC4899),
                indicatorWeight: 3,
                tabs: const [
                  Tab(icon: Icon(Icons.music_note), text: 'Music'),
                  Tab(icon: Icon(Icons.navigation), text: 'Navigation'),
                  Tab(icon: Icon(Icons.settings), text: 'Settings'),
                ],
              ),
            ),
            // Tab Views
            SizedBox(
              height: 400,
              child: TabBarView(
                controller: _tabController,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildMusicTab(),
                  _buildNavigationTab(),
                  _buildSettingsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Music Widget', Icons.music_note),
          const SizedBox(height: 16),
          
          _buildToggleCard(
            title: 'Enable Music Widget',
            subtitle: 'Show music controls on device',
            value: _musicControlEnabled,
            onChanged: _toggleMusicWidget,
            icon: Icons.music_note,
            color: const Color(0xFFEC4899),
          ),
          
          if (_musicControlEnabled) ...[
            const SizedBox(height: 20),
            _buildSectionTitle('Widget Style', Icons.style),
            const SizedBox(height: 12),
            
            _buildStyleSelector(
              options: [
                {'id': 'music-mini', 'label': 'Mini', 'icon': Icons.music_note_outlined},
                {'id': 'music-full', 'label': 'Full', 'icon': Icons.queue_music},
              ],
              selectedId: _selectedMusicWidget,
              onSelected: _changeMusicWidgetStyle,
            ),
            
            const SizedBox(height: 20),
            _buildInfoCard(
              title: 'Current Track',
              subtitle: deviceState.music.trackTitle,
              icon: Icons.album,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              title: 'Artist',
              subtitle: deviceState.music.artist,
              icon: Icons.person,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNavigationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Navigation Widget', Icons.navigation),
          const SizedBox(height: 16),
          
          _buildToggleCard(
            title: 'Enable Navigation',
            subtitle: 'Show directions on device',
            value: _navigationEnabled,
            onChanged: _toggleNavigationWidget,
            icon: Icons.navigation,
            color: const Color(0xFF3B82F6),
          ),
          
          if (_navigationEnabled) ...[
            const SizedBox(height: 20),
            _buildSectionTitle('Widget Style', Icons.style),
            const SizedBox(height: 12),
            
            _buildStyleSelector(
              options: [
                {'id': 'nav-compact', 'label': 'Compact', 'icon': Icons.near_me},
                {'id': 'nav-full', 'label': 'Full', 'icon': Icons.directions},
              ],
              selectedId: _selectedNavWidget,
              onSelected: _changeNavigationWidgetStyle,
            ),
            
            const SizedBox(height: 20),
            _buildInfoCard(
              title: 'Next Turn',
              subtitle: deviceState.navigation.direction,
              icon: Icons.turn_right,
            ),
            const SizedBox(height: 12),
            _buildInfoCard(
              title: 'Distance',
              subtitle: deviceState.navigation.distance,
              icon: Icons.straighten,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Background', Icons.wallpaper),
          const SizedBox(height: 16),
          
          _buildActionCard(
            title: 'Choose Background',
            subtitle: deviceState.backgroundImage != null 
                ? 'Custom image set' 
                : 'No background image',
            icon: Icons.image,
            onTap: _pickBackgroundImage,
          ),
          
          if (deviceState.backgroundImage != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: _buildActionCard(
                title: 'Remove Background',
                subtitle: 'Use solid color',
                icon: Icons.delete,
                onTap: () {
                  setState(() {
                    deviceState = deviceState.copyWith(backgroundImage: null);
                  });
                },
                color: Colors.red,
              ),
            ),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Quick Tips', Icons.lightbulb_outline),
          const SizedBox(height: 12),
          
          _buildTipCard(
            'Tap widgets on the preview to select them',
            Icons.touch_app,
          ),
          const SizedBox(height: 8),
          _buildTipCard(
            'Music widget auto-shows when playing',
            Icons.music_note,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFEC4899).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFFEC4899), size: 20),
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

  Widget _buildToggleCard({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: color,
          ),
        ],
      ),
    );
  }

  Widget _buildStyleSelector({
    required List<Map<String, dynamic>> options,
    required String selectedId,
    required ValueChanged<String> onSelected,
  }) {
    return Row(
      children: options.map((option) {
        final isSelected = option['id'] == selectedId;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => onSelected(option['id']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
                        )
                      : null,
                  color: isSelected ? null : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? const Color(0xFFEC4899) 
                        : Colors.grey.shade300,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFFEC4899).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  children: [
                    Icon(
                      option['icon'],
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      size: 24,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      option['label'],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 16,
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

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    Color? color,
  }) {
    final cardColor = color ?? const Color(0xFFEC4899);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: cardColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildTipCard(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEC4899).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFEC4899).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFFEC4899), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
