import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../models/device_state.dart';

class CustomizationPanel extends StatefulWidget {
  final DeviceState deviceState;
  final Function(DeviceState) onUpdate;
  final VoidCallback onClose;

  const CustomizationPanel({
    super.key,
    required this.deviceState,
    required this.onUpdate,
    required this.onClose,
  });

  @override
  State<CustomizationPanel> createState() => _CustomizationPanelState();
}

class _CustomizationPanelState extends State<CustomizationPanel> {
  late DeviceState _currentState;

  @override
  void initState() {
    super.initState();
    _currentState = widget.deviceState;
  }

  void _updateState(DeviceState newState) {
    setState(() {
      _currentState = newState;
    });
    widget.onUpdate(newState);
  }

  Future<void> _pickBackgroundImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      _updateState(_currentState.copyWith(backgroundImage: image.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(-5, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Customize Device',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: widget.onClose,
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildThemeSection(),
                  const SizedBox(height: 24),
                  _buildWidgetsSection(),
                  const SizedBox(height: 24),
                  _buildBackgroundSection(),
                  const SizedBox(height: 24),
                  _buildMusicSection(),
                  const SizedBox(height: 24),
                  _buildWeatherSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Theme',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildThemeOption('Light', 'light'),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildThemeOption('Dark', 'dark'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThemeOption(String label, String theme) {
    final isSelected = _currentState.theme == theme;
    return GestureDetector(
      onTap: () => _updateState(_currentState.copyWith(theme: theme)),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
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
        const Text(
          'Widgets',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildWidgetCategory('Time', 'time-', [
          ('Digital Large', 'time-digital-large'),
          ('Digital Small', 'time-digital-small'),
          ('Analog Small', 'time-analog-small'),
          ('Analog Large', 'time-analog-large'),
          ('Date & Time', 'time-text-date'),
        ]),
        const SizedBox(height: 12),
        _buildWidgetCategory('Weather', 'weather-', [
          ('Icon Only', 'weather-icon'),
          ('Temp + Icon', 'weather-temp-icon'),
          ('Full Weather', 'weather-full'),
        ]),
        const SizedBox(height: 12),
        _buildWidgetCategory('Music', 'music-', [
          ('Mini Player', 'music-mini'),
          ('Full Player', 'music-full'),
        ]),
        const SizedBox(height: 12),
        _buildWidgetCategory('Battery', 'battery-', [
          ('Status Text', 'battery-status'),
          ('Battery Bar', 'battery-bar'),
        ]),
      ],
    );
  }

  Widget _buildWidgetCategory(String title, String prefix, List<(String, String)> options) {
    final currentWidget = _currentState.widgets.firstWhere(
      (w) => w.startsWith(prefix),
      orElse: () => '',
    );

    // Check if music or navigation is active
    bool hasMusicWidget = _currentState.widgets.any((w) => w.startsWith('music-'));
    bool hasNavigation = _currentState.widgets.any((w) => w.startsWith('nav-') && _currentState.navigation.ridingMode);
    
    // Disable clock/time and weather widgets when music or navigation is active
    bool isDisabled = false;
    if ((prefix == 'time-' || prefix == 'weather-') && (hasMusicWidget || hasNavigation)) {
      isDisabled = true;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDisabled ? Colors.grey.shade400 : Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Opacity(
          opacity: isDisabled ? 0.4 : 1.0,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...options.map((option) {
                final isSelected = currentWidget == option.$2;
                return GestureDetector(
                  onTap: isDisabled ? null : () {
                    final newWidgets = _currentState.widgets
                        .where((w) => !w.startsWith(prefix))
                        .toList();
                    newWidgets.add(option.$2);
                    _updateState(_currentState.copyWith(widgets: newWidgets));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF6366F1) : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      option.$1,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }),
              // None option
              GestureDetector(
                onTap: isDisabled ? null : () {
                  final newWidgets = _currentState.widgets
                      .where((w) => !w.startsWith(prefix))
                      .toList();
                  _updateState(_currentState.copyWith(widgets: newWidgets));
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: currentWidget.isEmpty ? Colors.red.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: currentWidget.isEmpty ? Colors.red.shade300 : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    'None',
                    style: TextStyle(
                      fontSize: 12,
                      color: currentWidget.isEmpty ? Colors.red : Colors.black87,
                      fontWeight: currentWidget.isEmpty ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Background',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickBackgroundImage,
                icon: const Icon(Icons.image),
                label: const Text('Choose Image'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (_currentState.backgroundImage != null) ...[
              const SizedBox(width: 12),
              IconButton(
                onPressed: () => _updateState(_currentState.copyWith(backgroundImage: null)),
                icon: const Icon(Icons.delete),
                color: Colors.red,
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMusicSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Music',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Track Title',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (value) {
            _updateState(_currentState.copyWith(
              music: _currentState.music.copyWith(trackTitle: value),
            ));
          },
          controller: TextEditingController(text: _currentState.music.trackTitle)
            ..selection = TextSelection.collapsed(offset: _currentState.music.trackTitle.length),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Artist',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          onChanged: (value) {
            _updateState(_currentState.copyWith(
              music: _currentState.music.copyWith(artist: value),
            ));
          },
          controller: TextEditingController(text: _currentState.music.artist)
            ..selection = TextSelection.collapsed(offset: _currentState.music.artist.length),
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Playing'),
          value: _currentState.music.isPlaying,
          onChanged: (value) {
            _updateState(_currentState.copyWith(
              music: _currentState.music.copyWith(isPlaying: value),
            ));
          },
          activeColor: const Color(0xFF6366F1),
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildWeatherSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weather',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _currentState.weather.condition,
          decoration: const InputDecoration(
            labelText: 'Condition',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          items: ['Sunny', 'Cloudy', 'Rainy', 'Stormy', 'Snowy']
              .map((condition) => DropdownMenuItem(
                    value: condition,
                    child: Text(condition),
                  ))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              _updateState(_currentState.copyWith(
                weather: _currentState.weather.copyWith(condition: value),
              ));
            }
          },
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: const InputDecoration(
            labelText: 'Temperature (°C)',
            border: OutlineInputBorder(),
            isDense: true,
          ),
          keyboardType: TextInputType.number,
          onChanged: (value) {
            final temp = int.tryParse(value) ?? 24;
            _updateState(_currentState.copyWith(
              weather: _currentState.weather.copyWith(temperature: temp),
            ));
          },
          controller: TextEditingController(text: _currentState.weather.temperature.toString())
            ..selection = TextSelection.collapsed(offset: _currentState.weather.temperature.toString().length),
        ),
      ],
    );
  }
}
