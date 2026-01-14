import 'package:flutter/material.dart';
import '../../models/device_state.dart';

class BackgroundOptionsPanel extends StatefulWidget {
  final DeviceState deviceState;
  final Function(DeviceState) onUpdate;
  final VoidCallback? onChooseImage; // New callback

  const BackgroundOptionsPanel({
    super.key,
    required this.deviceState,
    required this.onUpdate,
    this.onChooseImage, // Initialize new callback
  });

  @override
  State<BackgroundOptionsPanel> createState() => _BackgroundOptionsPanelState();
}

class _BackgroundOptionsPanelState extends State<BackgroundOptionsPanel> {
  @override
  Widget build(BuildContext context) {
    bool hasBackgroundImage = widget.deviceState.backgroundImage != null;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0), // Added padding for text
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Enable Background Image',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Switch(
                    value: hasBackgroundImage,
                    onChanged: (bool newValue) {
                      if (newValue) {
                        // If enabling and no image is set, prompt to choose
                        if (widget.deviceState.backgroundImage == null) {
                          widget.onChooseImage?.call();
                        }
                        // If already has image, just keep it enabled
                      } else {
                        // If disabling, remove image
                        widget.onUpdate(widget.deviceState.copyWith(backgroundImage: null));
                      }
                    },
                  ),
                ],
              ),
            ),
            if (hasBackgroundImage) ...[
              const SizedBox(height: 16), // Increased spacing
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: widget.onChooseImage, // Use the callback if provided
                  icon: const Icon(Icons.image),
                  label: const Text('Change Image'), // Changed label from 'Choose Image'
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Matched with NewCustomizationPanel's borderRadius
                    ),
                    elevation: 8, // Increased elevation for more depth
                    shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.4), // Custom shadow color
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => widget.onUpdate(widget.deviceState.copyWith(backgroundImage: null)),
                  icon: const Icon(Icons.delete),
                  label: const Text('Remove Image'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade400,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20), // Matched with NewCustomizationPanel's borderRadius
                    ),
                    elevation: 8, // Increased elevation for more depth
                    shadowColor: Colors.red.shade400.withValues(alpha: 0.4), // Custom shadow color
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}