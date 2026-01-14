import 'package:flutter/material.dart';
import '../models/device_state.dart';
import '../models/custom_widget_state.dart'; // Needed for adding/removing CustomWidgetState
import '../models/widget_card.dart'; // Still needed for allWidgetCards

class NewCustomizationPanel extends StatefulWidget {
  final DeviceState deviceState;
  final Function(DeviceState) onUpdate;
  final String? selectedWidgetId;
  final List<WidgetCard> allWidgetCards;
  final VoidCallback? onChooseBackgroundImage;

  const NewCustomizationPanel({
    super.key,
    required this.deviceState,
    required this.onUpdate,
    this.selectedWidgetId,
    required this.allWidgetCards,
    this.onChooseBackgroundImage,
  });

  @override
  State<NewCustomizationPanel> createState() => _NewCustomizationPanelState();
}

class _NewCustomizationPanelState extends State<NewCustomizationPanel> {
  // No longer need _categories, _pageController, _selectedIndex

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300.0), // Limit the width
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTitleRow(),
                const SizedBox(height: 12),
                _buildBackgroundOption(),
                const SizedBox(height: 6),
                _buildMusicOption(),
                const SizedBox(height: 6),
                _buildWeatherOption(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF6366F1).withValues(alpha: 0.15),
                  const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: Color(0xFF6366F1),
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Customize',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundOption() {
    return _buildOptionRow(
      icon: Icons.photo_size_select_actual_outlined,
      label: 'Background',
      control: Transform.scale(
        scale: 0.8,
        child: IconButton(
          icon: const Icon(Icons.add_a_photo_outlined, color: Color(0xFF6366F1)),
          onPressed: widget.onChooseBackgroundImage,
        ),
      ),
    );
  }

  Widget _buildMusicOption() {
    return _buildOptionRow(
      icon: Icons.music_video_outlined,
      label: 'Music Widget',
      control: Transform.scale(
        scale: 0.8,
        child: Switch.adaptive(
          value: widget.deviceState.widgets.any((w) => w.id.startsWith('music-')),
          onChanged: (bool newValue) {
            List<CustomWidgetState> updatedWidgets = List.from(widget.deviceState.widgets);
            if (newValue) {
              if (!updatedWidgets.any((w) => w.id.startsWith('music-'))) {
                updatedWidgets.add(CustomWidgetState(id: 'music-mini'));
              }
            } else {
              updatedWidgets.removeWhere((w) => w.id.startsWith('music-'));
            }
            widget.onUpdate(widget.deviceState.copyWith(widgets: updatedWidgets));
          },
          activeColor: const Color(0xFF6366F1),
        ),
      ),
    );
  }

  Widget _buildWeatherOption() {
    return _buildOptionRow(
      icon: Icons.cloud_outlined,
      label: 'Weather Widget',
      control: Transform.scale(
        scale: 0.8,
        child: Switch.adaptive(
          value: widget.deviceState.widgets.any((w) => w.id.startsWith('weather-')),
          onChanged: (bool newValue) {
            List<CustomWidgetState> updatedWidgets = List.from(widget.deviceState.widgets);
            if (newValue) {
              if (!updatedWidgets.any((w) => w.id.startsWith('weather-'))) {
                updatedWidgets.add(CustomWidgetState(id: 'weather-icon'));
              }
            } else {
              updatedWidgets.removeWhere((w) => w.id.startsWith('weather-'));
            }
            widget.onUpdate(widget.deviceState.copyWith(widgets: updatedWidgets));
          },
          activeColor: const Color(0xFF6366F1),
        ),
      ),
    );
  }

  Widget _buildOptionRow({required IconData icon, required String label, required Widget control}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
              ),
            ),
          ),
          control,
        ],
      ),
    );
  }
}
