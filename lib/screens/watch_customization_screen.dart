import 'package:flutter/material.dart';

import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../models/device_state.dart';
import '../widgets/device_preview.dart';
import '../widgets/new_customization_panel.dart';
import '../models/widget_card.dart';
import '../models/custom_widget_state.dart';

/// Watch Mode Customization Screen
/// 
/// This screen handles customization specifically for Watch mode.
/// Features:
/// - Full widget customization (time, weather, music, navigation, photo)
/// - Background image selection
/// - Real-time device preview
/// - State persistence on save
/// 
/// Navigation Flow:
/// Dashboard (Watch mode) → Edit Widgets → WatchCustomizationScreen
class WatchCustomizationScreen extends StatefulWidget {
  final List<WidgetCard> allWidgetCards;
  final DeviceState initialDeviceState;

  const WatchCustomizationScreen({
    super.key,
    required this.allWidgetCards,
    required this.initialDeviceState,
  });

  @override
  State<WatchCustomizationScreen> createState() => _WatchCustomizationScreenState();
}

class _WatchCustomizationScreenState extends State<WatchCustomizationScreen> {
  late DeviceState deviceState;
  String? _selectedWidgetId;

  @override
  void initState() {
    super.initState();
    deviceState = widget.initialDeviceState;
  }

  @override
  void dispose() {
    super.dispose();
  }

  /// Updates the device state when customization changes
  void _onDeviceStateChanged(DeviceState newState) {
    setState(() {
      deviceState = newState;
    });
  }

  /// Handles widget selection from the customization panel
  /// Replaces widgets in the same category to prevent duplicates
  void _onWidgetSelected(String? newWidgetId) {
    if (newWidgetId == null) {
      setState(() {
        _selectedWidgetId = null;
      });
      return;
    }

    // Extract category prefix (e.g., 'time', 'weather', 'music')
    final categoryPrefix = newWidgetId.split('-').first;
    
    // Remove existing widgets from the same category
    final newWidgets = deviceState.widgets.where((w) => !w.id.startsWith(categoryPrefix)).toList();
    
    // Add the newly selected widget
    newWidgets.add(CustomWidgetState(id: newWidgetId));
    
    setState(() {
      _selectedWidgetId = newWidgetId;
      deviceState = deviceState.copyWith(widgets: newWidgets);
    });
  }

  /// Opens image picker and cropper for custom background
  Future<void> _pickCustomPhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Background',
            toolbarColor: Colors.lightBlueAccent,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ],
          ),
          IOSUiSettings(
            title: 'Crop Background',
            aspectRatioPresets: [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ],
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
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with back and save buttons
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
                          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.watch, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Watch Mode',
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
                        icon: const Icon(Icons.check, color: Color(0xFF6366F1)),
                      ),
                    ),
                  ],
                ),
              ),
              // Device preview with current customization
              SizedBox(
                height: 433.0,
                child: Center(
                  child: DevicePreview(
                    deviceState: deviceState,
                    selectedWidgetId: _selectedWidgetId,
                    onWidgetSelected: _onWidgetSelected,
                    width: 200,
                    allWidgetCards: widget.allWidgetCards,
                  ),
                ),
              ),
              // Customization panel (background, widgets, options)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: NewCustomizationPanel(
                  deviceState: deviceState,
                  onUpdate: _onDeviceStateChanged,
                  selectedWidgetId: _selectedWidgetId,
                  allWidgetCards: widget.allWidgetCards,
                  onChooseBackgroundImage: _pickCustomPhoto,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
